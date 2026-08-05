#pragma once

#include "routing/vehicle_mask.hpp"

namespace routing
{
/// \brief Personal speed the user keeps and, for bicycles, the wind they ride in. Both correct the
/// estimated time of arrival only: the route itself is chosen exactly as before.
struct RouteSpeedSettings
{
  /// Cruising speed on flat pavement, km/h. 0 means "use the profile default".
  double m_cruisingSpeedKMpH = 0.0;
  /// Wind speed, m/s. 0 means "do not take the wind into account".
  int m_windSpeedMpS = 0;
  /// Compass direction the wind blows from, degrees.
  int m_windDirectionDegrees = 0;

  bool operator==(RouteSpeedSettings const &) const = default;
};

/// \brief Cruising speeds the UI offers for a vehicle type, km/h.
struct CruisingSpeedRange
{
  double m_min;
  double m_max;
  double m_step;
  double m_default;
};

int constexpr kMaxWindSpeedMpS = 20;
int constexpr kWindDirectionStepDegrees = 45;

/// Only muscle-powered routers have a personal speed, and only cyclists are noticeably slowed by wind.
bool IsRouteSpeedSupported(VehicleType vehicleType);
bool IsWindSupported(VehicleType vehicleType);

CruisingSpeedRange GetCruisingSpeedRange(VehicleType vehicleType);
RouteSpeedSettings LoadRouteSpeedSettings(VehicleType vehicleType);
void SaveRouteSpeedSettings(VehicleType vehicleType, RouteSpeedSettings const & settings);
}  // namespace routing
