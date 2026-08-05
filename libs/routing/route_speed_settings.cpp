#include "routing/route_speed_settings.hpp"

#include "platform/settings.hpp"

#include "base/assert.hpp"

#include <string_view>

namespace routing
{
namespace
{
std::string_view constexpr kPedestrianRouteSpeedKey = "routing_speed_percentage_pedestrian";
std::string_view constexpr kBicycleRouteSpeedKey = "routing_speed_percentage_bicycle";
std::string_view constexpr kBicycleWindEnabledKey = "routing_wind_enabled_bicycle";
std::string_view constexpr kBicycleWindSpeedKey = "routing_wind_speed_mps_bicycle";
std::string_view constexpr kBicycleWindDirectionKey = "routing_wind_direction_degrees_bicycle";
// Reference speeds shown in the UI. Route-specific ETA speeds are still adjusted by the saved factor.
double constexpr kPedestrianCruisingSpeedKMpH = 5.0;
double constexpr kBicycleCruisingSpeedKMpH = 20.0;

std::string_view GetSettingsKey(VehicleType vehicleType)
{
  CHECK(RouteSpeedSettings::IsSupported(vehicleType), (vehicleType));
  return vehicleType == VehicleType::Pedestrian ? kPedestrianRouteSpeedKey : kBicycleRouteSpeedKey;
}
}  // namespace

bool RouteSpeedSettings::IsSupported(VehicleType vehicleType)
{
  return vehicleType == VehicleType::Pedestrian || vehicleType == VehicleType::Bicycle;
}

int RouteSpeedSettings::Load(VehicleType vehicleType)
{
  CHECK(IsSupported(vehicleType), (vehicleType));

  int percentage = kDefaultPercentage;
  if (!settings::Get(GetSettingsKey(vehicleType), percentage) || percentage < kMinPercentage ||
      percentage > kMaxPercentage || percentage % kStepPercentage != 0)
  {
    return kDefaultPercentage;
  }
  return percentage;
}

void RouteSpeedSettings::Save(VehicleType vehicleType, int percentage)
{
  CHECK(IsSupported(vehicleType), (vehicleType));
  CHECK_GREATER_OR_EQUAL(percentage, kMinPercentage, ());
  CHECK_LESS_OR_EQUAL(percentage, kMaxPercentage, ());
  CHECK_EQUAL(percentage % kStepPercentage, 0, ());
  settings::Set(GetSettingsKey(vehicleType), percentage);
}

double RouteSpeedSettings::GetFactor(VehicleType vehicleType)
{
  return Load(vehicleType) / 100.0;
}

double RouteSpeedSettings::GetDefaultCruisingSpeedKMpH(VehicleType vehicleType)
{
  CHECK(IsSupported(vehicleType), (vehicleType));
  return vehicleType == VehicleType::Pedestrian ? kPedestrianCruisingSpeedKMpH : kBicycleCruisingSpeedKMpH;
}

double RouteSpeedSettings::PercentageToCruisingSpeedKMpH(VehicleType vehicleType, int percentage)
{
  CHECK_GREATER_OR_EQUAL(percentage, kMinPercentage, ());
  CHECK_LESS_OR_EQUAL(percentage, kMaxPercentage, ());
  CHECK_EQUAL(percentage % kStepPercentage, 0, ());
  return GetDefaultCruisingSpeedKMpH(vehicleType) * percentage / 100.0;
}

BicycleWindSettings RouteSpeedSettings::LoadBicycleWind()
{
  BicycleWindSettings wind;
  settings::TryGet(kBicycleWindEnabledKey, wind.m_enabled);
  settings::TryGet(kBicycleWindSpeedKey, wind.m_speedMpS);
  settings::TryGet(kBicycleWindDirectionKey, wind.m_directionDegrees);

  if (wind.m_speedMpS < kMinWindSpeedMpS || wind.m_speedMpS > kMaxWindSpeedMpS ||
      wind.m_speedMpS % kWindSpeedStepMpS != 0 || wind.m_directionDegrees < 0 || wind.m_directionDegrees >= 360 ||
      wind.m_directionDegrees % kWindDirectionStepDegrees != 0)
  {
    return {};
  }
  return wind;
}

void RouteSpeedSettings::SaveBicycleWind(BicycleWindSettings const & wind)
{
  CHECK_GREATER_OR_EQUAL(wind.m_speedMpS, kMinWindSpeedMpS, ());
  CHECK_LESS_OR_EQUAL(wind.m_speedMpS, kMaxWindSpeedMpS, ());
  CHECK_EQUAL(wind.m_speedMpS % kWindSpeedStepMpS, 0, ());
  CHECK_GREATER_OR_EQUAL(wind.m_directionDegrees, 0, ());
  CHECK_LESS(wind.m_directionDegrees, 360, ());
  CHECK_EQUAL(wind.m_directionDegrees % kWindDirectionStepDegrees, 0, ());

  settings::Set(kBicycleWindEnabledKey, wind.m_enabled);
  settings::Set(kBicycleWindSpeedKey, wind.m_speedMpS);
  settings::Set(kBicycleWindDirectionKey, wind.m_directionDegrees);
}
}  // namespace routing
