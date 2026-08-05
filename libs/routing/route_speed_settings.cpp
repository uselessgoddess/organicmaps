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
std::string_view constexpr kBicycleWindSpeedKey = "routing_wind_speed_kmph_bicycle";
std::string_view constexpr kBicycleWindDirectionKey = "routing_wind_direction_degrees_bicycle";

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

BicycleWindSettings RouteSpeedSettings::LoadBicycleWind()
{
  BicycleWindSettings wind;
  settings::TryGet(kBicycleWindEnabledKey, wind.m_enabled);
  settings::TryGet(kBicycleWindSpeedKey, wind.m_speedKMpH);
  settings::TryGet(kBicycleWindDirectionKey, wind.m_directionDegrees);

  if (wind.m_speedKMpH < kMinWindSpeedKMpH || wind.m_speedKMpH > kMaxWindSpeedKMpH ||
      wind.m_speedKMpH % kWindSpeedStepKMpH != 0 || wind.m_directionDegrees < 0 || wind.m_directionDegrees >= 360 ||
      wind.m_directionDegrees % kWindDirectionStepDegrees != 0)
  {
    return {};
  }
  return wind;
}

void RouteSpeedSettings::SaveBicycleWind(BicycleWindSettings const & wind)
{
  CHECK_GREATER_OR_EQUAL(wind.m_speedKMpH, kMinWindSpeedKMpH, ());
  CHECK_LESS_OR_EQUAL(wind.m_speedKMpH, kMaxWindSpeedKMpH, ());
  CHECK_EQUAL(wind.m_speedKMpH % kWindSpeedStepKMpH, 0, ());
  CHECK_GREATER_OR_EQUAL(wind.m_directionDegrees, 0, ());
  CHECK_LESS(wind.m_directionDegrees, 360, ());
  CHECK_EQUAL(wind.m_directionDegrees % kWindDirectionStepDegrees, 0, ());

  settings::Set(kBicycleWindEnabledKey, wind.m_enabled);
  settings::Set(kBicycleWindSpeedKey, wind.m_speedKMpH);
  settings::Set(kBicycleWindDirectionKey, wind.m_directionDegrees);
}
}  // namespace routing
