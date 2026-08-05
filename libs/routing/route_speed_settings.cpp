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
}  // namespace routing
