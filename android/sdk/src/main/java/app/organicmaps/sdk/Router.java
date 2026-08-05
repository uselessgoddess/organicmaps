package app.organicmaps.sdk;

import androidx.annotation.NonNull;

public enum Router
{
  Vehicle(0),
  Pedestrian(1),
  Bicycle(2),
  Transit(3),
  Ruler(4);

  public static final int DEFAULT_ROUTE_SPEED_PERCENTAGE = 100;
  public static final int DEFAULT_WIND_SPEED_KMPH = 10;
  public static final int MIN_WIND_SPEED_KMPH = 5;
  public static final int MAX_WIND_SPEED_KMPH = 100;
  public static final int WIND_SPEED_STEP_KMPH = 5;
  public static final int WIND_DIRECTION_STEP_DEGREES = 45;

  Router(int type)
  {
    this.type = type;
  }

  public static void set(@NonNull Router routerType)
  {
    nativeSet(routerType.type);
  }

  public static Router get()
  {
    return valueOf(nativeGet());
  }

  public static Router getLastUsed()
  {
    return valueOf(nativeGetLastUsed());
  }

  public static Router getBest(double srcLat, double srcLon, double dstLat, double dstLon)
  {
    return Router.values()[nativeGetBest(srcLat, srcLon, dstLat, dstLon)];
  }

  public static boolean isRouteSpeedSettingSupported()
  {
    return nativeIsRouteSpeedSettingSupported();
  }

  public static int getRouteSpeedPercentage()
  {
    return nativeGetRouteSpeedPercentage();
  }

  public static void setRouteSpeedPercentage(int percentage)
  {
    nativeSetRouteSpeedPercentage(percentage);
  }

  public static boolean isBicycleWindSettingSupported()
  {
    return nativeIsBicycleWindSettingSupported();
  }

  public static boolean isBicycleWindEnabled()
  {
    return nativeIsBicycleWindEnabled();
  }

  public static int getBicycleWindSpeedKmph()
  {
    return nativeGetBicycleWindSpeedKmph();
  }

  public static int getBicycleWindDirectionDegrees()
  {
    return nativeGetBicycleWindDirectionDegrees();
  }

  public static void setBicycleRouteSettings(int speedPercentage, boolean windEnabled, int windSpeedKmph,
                                             int windDirectionDegrees)
  {
    nativeSetBicycleRouteSettings(speedPercentage, windEnabled, windSpeedKmph, windDirectionDegrees);
  }

  public static Router valueOf(int type)
  {
    return Router.values()[type];
  }

  private final int type;

  private static native void nativeSet(int routerType);

  private static native int nativeGet();

  private static native int nativeGetLastUsed();

  private static native int nativeGetBest(double srcLat, double srcLon, double dstLat, double dstLon);

  private static native boolean nativeIsRouteSpeedSettingSupported();

  private static native int nativeGetRouteSpeedPercentage();

  private static native void nativeSetRouteSpeedPercentage(int percentage);

  private static native boolean nativeIsBicycleWindSettingSupported();

  private static native boolean nativeIsBicycleWindEnabled();

  private static native int nativeGetBicycleWindSpeedKmph();

  private static native int nativeGetBicycleWindDirectionDegrees();

  private static native void nativeSetBicycleRouteSettings(int speedPercentage, boolean windEnabled, int windSpeedKmph,
                                                           int windDirectionDegrees);
}
