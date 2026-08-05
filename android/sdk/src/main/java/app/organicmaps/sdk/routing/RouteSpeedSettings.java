package app.organicmaps.sdk.routing;

import androidx.annotation.Nullable;

/**
 * The personal speed the user keeps and, for bicycles, the wind they ride in, together with the
 * limits the UI has to respect. Both correct the estimated time of arrival only: the route itself is
 * chosen exactly as before.
 */
public final class RouteSpeedSettings
{
  public static final int WIND_DIRECTION_STEP_DEGREES = 45;
  public static final int DEFAULT_WIND_SPEED_MPS = 3;

  /** Cruising speed on flat pavement, km/h. */
  public final double cruisingSpeedKmph;
  /** Wind speed, m/s. 0 means the wind is not taken into account. */
  public final int windSpeedMps;
  /** Compass direction the wind blows from, degrees. */
  public final int windDirectionDegrees;
  public final double minSpeedKmph;
  public final double maxSpeedKmph;
  public final double speedStepKmph;
  /** The speed the routing profile itself predicts, i.e. the one that keeps the original ETA. */
  public final double defaultSpeedKmph;
  /** Highest wind speed the user can set, m/s. 0 means this vehicle has no wind setting. */
  public final int maxWindSpeedMps;

  // Called from JNI.
  public RouteSpeedSettings(double cruisingSpeedKmph, int windSpeedMps, int windDirectionDegrees, double minSpeedKmph,
                            double maxSpeedKmph, double speedStepKmph, double defaultSpeedKmph, int maxWindSpeedMps)
  {
    this.cruisingSpeedKmph = cruisingSpeedKmph;
    this.windSpeedMps = windSpeedMps;
    this.windDirectionDegrees = windDirectionDegrees;
    this.minSpeedKmph = minSpeedKmph;
    this.maxSpeedKmph = maxSpeedKmph;
    this.speedStepKmph = speedStepKmph;
    this.defaultSpeedKmph = defaultSpeedKmph;
    this.maxWindSpeedMps = maxWindSpeedMps;
  }

  public boolean isWindSupported()
  {
    return maxWindSpeedMps > 0;
  }

  /** @return how many settings the user has changed from their defaults, shown as a badge. */
  public int changedCount()
  {
    return (cruisingSpeedKmph == defaultSpeedKmph ? 0 : 1) + (windSpeedMps > 0 ? 1 : 0);
  }

  /** @return the settings of the current router, or null if it has no personal speed (car, transit). */
  @Nullable
  public static native RouteSpeedSettings nativeGet();

  public static native void nativeSet(double cruisingSpeedKmph, int windSpeedMps, int windDirectionDegrees);
}
