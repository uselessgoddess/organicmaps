#include "testing/testing.hpp"

#include "routing/edge_estimator.hpp"
#include "routing/geometry.hpp"

#include "routing_common/maxspeed_conversion.hpp"

#include "geometry/point_with_altitude.hpp"

#include "platform/measurement_utils.hpp"

#include <cmath>

namespace
{
using namespace routing;

double const kTan = 0.1;
geometry::Altitude const kAlt = 100.0;
auto const kPurposes = {EdgeEstimator::Purpose::Weight, EdgeEstimator::Purpose::ETA};
constexpr double kAccuracyEps = 1e-5;

// Climb penalty on plain surface (tangent = 0) must be 1.0 for ETA and Weight estimations.
UNIT_TEST(ClimbPenalty_ZeroTangent)
{
  double const zeroTangent = 0.0;

  for (auto const & purpose : kPurposes)
  {
    TEST_EQUAL(GetCarClimbPenalty(purpose, zeroTangent, kAlt), 1.0, ());
    TEST_EQUAL(GetBicycleClimbPenalty(purpose, zeroTangent, kAlt), 1.0, ());
    TEST_EQUAL(GetPedestrianClimbPenalty(purpose, zeroTangent, kAlt), 1.0, ());
  }
}

// Descent penalty for pedestrians and bicycles must be less then the ascent penalty.
UNIT_TEST(ClimbPenalty_DescentLessThenAscent)
{
  for (auto const & purpose : kPurposes)
  {
    double const ascPenaltyPedestrian = GetPedestrianClimbPenalty(purpose, kTan, kAlt);
    double const descPenaltyPedestrian = GetPedestrianClimbPenalty(purpose, -kTan, kAlt);
    TEST_LESS(descPenaltyPedestrian, ascPenaltyPedestrian, ());

    double const ascPenaltyBicycle = GetBicycleClimbPenalty(purpose, kTan, kAlt);
    double const descPenaltyBicycle = GetBicycleClimbPenalty(purpose, -kTan, kAlt);
    TEST_LESS(descPenaltyBicycle, ascPenaltyBicycle, ());
  }
}

// Descent penalty for cars must be equal to the ascent penalty.
UNIT_TEST(ClimbPenalty_DescentEqualsAscent)
{
  for (auto const & purpose : kPurposes)
  {
    double const ascPenaltyCar = GetCarClimbPenalty(purpose, kTan, kAlt);
    double const descPenaltyCar = GetCarClimbPenalty(purpose, -kTan, kAlt);
    TEST_EQUAL(ascPenaltyCar, 1.0, ());
    TEST_EQUAL(descPenaltyCar, 1.0, ());
  }
}

// Climb penalty high above the sea level (higher then 2.5 km) should be very significant.
UNIT_TEST(ClimbPenalty_HighAboveSeaLevel)
{
  for (auto const & purpose : kPurposes)
  {
    double const penalty2500 = GetPedestrianClimbPenalty(purpose, kTan, 2500);
    double const penalty4000 = GetPedestrianClimbPenalty(purpose, kTan, 4000);
    double const penalty5500 = GetPedestrianClimbPenalty(purpose, kTan, 5500);
    double const penalty7000 = GetPedestrianClimbPenalty(purpose, kTan, 7000);

    TEST_GREATER_OR_EQUAL(penalty2500, 2.0, ());
    TEST_GREATER_OR_EQUAL(penalty4000, penalty2500 + 1.0, ());
    TEST_GREATER_OR_EQUAL(penalty5500, penalty4000 + 1.0, ());
    TEST_GREATER_OR_EQUAL(penalty7000, penalty5500 + 1.0, ());

    double const penalty2500Bicyclce = GetBicycleClimbPenalty(purpose, kTan, 2500);

    TEST_GREATER_OR_EQUAL(penalty2500Bicyclce, 6.0, ());
    TEST_ALMOST_EQUAL_ABS(GetCarClimbPenalty(purpose, kTan, 2500), 1.0, kAccuracyEps, ());
  }
}

void TestRouteSpeedFactor(VehicleType vehicleType)
{
  auto const estimator = EdgeEstimator::Create(vehicleType, 5.0, SpeedKMpH(5.0), nullptr, nullptr, nullptr);
  ms::LatLon const from(0.0, 0.0);
  ms::LatLon const to(0.0, 0.001);

  double const weight = estimator->CalcOffroad(from, to, EdgeEstimator::Purpose::Weight);
  double const eta = estimator->CalcOffroad(from, to, EdgeEstimator::Purpose::ETA);
  double const ferryEta = estimator->GetFerryLandingPenalty(EdgeEstimator::Purpose::ETA);
  RoadGeometry const road(false /* oneWay */, Maxspeed(measurement_utils::Units::Metric, 5, kInvalidSpeed),
                          {{0.0, 0.0}, {0.0, 0.001}});
  Segment const segment(kFakeNumMwmId, 0 /* featureId */, 0 /* segmentIdx */, true /* forward */);
  double const segmentWeight = estimator->CalcSegmentWeight(segment, road, EdgeEstimator::Purpose::Weight);
  double const segmentEta = estimator->CalcSegmentWeight(segment, road, EdgeEstimator::Purpose::ETA);

  estimator->SetRouteSpeedFactor(1.25);

  TEST_ALMOST_EQUAL_ABS(estimator->CalcOffroad(from, to, EdgeEstimator::Purpose::Weight), weight, kAccuracyEps, ());
  TEST_ALMOST_EQUAL_ABS(estimator->CalcOffroad(from, to, EdgeEstimator::Purpose::ETA), eta / 1.25, kAccuracyEps, ());
  TEST_ALMOST_EQUAL_ABS(estimator->GetFerryLandingPenalty(EdgeEstimator::Purpose::ETA), ferryEta, kAccuracyEps, ());
  TEST_ALMOST_EQUAL_ABS(estimator->CalcSegmentWeight(segment, road, EdgeEstimator::Purpose::Weight), segmentWeight,
                        kAccuracyEps, ());
  TEST_ALMOST_EQUAL_ABS(estimator->CalcSegmentWeight(segment, road, EdgeEstimator::Purpose::ETA), segmentEta / 1.25,
                        kAccuracyEps, ());
}

UNIT_TEST(RouteSpeedFactor_AffectsEtaOnly)
{
  TestRouteSpeedFactor(VehicleType::Pedestrian);
  TestRouteSpeedFactor(VehicleType::Bicycle);
}
}  // namespace
