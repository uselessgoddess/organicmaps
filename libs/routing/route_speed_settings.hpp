#pragma once

#include "routing/vehicle_mask.hpp"

namespace routing
{
struct BicycleWindSettings;

class RouteSpeedSettings
{
public:
  static int constexpr kDefaultPercentage = 100;
  static int constexpr kMinPercentage = 50;
  static int constexpr kMaxPercentage = 200;
  static int constexpr kStepPercentage = 5;
  static int constexpr kDefaultWindSpeedKMpH = 10;
  static int constexpr kMinWindSpeedKMpH = 5;
  static int constexpr kMaxWindSpeedKMpH = 100;
  static int constexpr kWindSpeedStepKMpH = 5;
  static int constexpr kWindDirectionStepDegrees = 45;

  static bool IsSupported(VehicleType vehicleType);
  static int Load(VehicleType vehicleType);
  static void Save(VehicleType vehicleType, int percentage);
  static double GetFactor(VehicleType vehicleType);
  static BicycleWindSettings LoadBicycleWind();
  static void SaveBicycleWind(BicycleWindSettings const & wind);
};

struct BicycleWindSettings
{
  bool m_enabled = false;
  int m_speedKMpH = RouteSpeedSettings::kDefaultWindSpeedKMpH;
  int m_directionDegrees = 0;

  bool operator==(BicycleWindSettings const &) const = default;
};
}  // namespace routing
