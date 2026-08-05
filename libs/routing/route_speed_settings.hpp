#pragma once

#include "routing/vehicle_mask.hpp"

namespace routing
{
class RouteSpeedSettings
{
public:
  static int constexpr kDefaultPercentage = 100;
  static int constexpr kMinPercentage = 50;
  static int constexpr kMaxPercentage = 200;
  static int constexpr kStepPercentage = 5;

  static bool IsSupported(VehicleType vehicleType);
  static int Load(VehicleType vehicleType);
  static void Save(VehicleType vehicleType, int percentage);
  static double GetFactor(VehicleType vehicleType);
};
}  // namespace routing
