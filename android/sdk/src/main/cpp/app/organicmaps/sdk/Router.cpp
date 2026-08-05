#include "app/organicmaps/sdk/core/jni_helper.hpp"

#include "app/organicmaps/sdk/Framework.hpp"

#include "indexer/map_style.hpp"

extern "C"
{
JNIEXPORT void Java_app_organicmaps_sdk_Router_nativeSet(JNIEnv *, jclass, jint routerType)
{
  using Type = routing::RouterType;
  Type type;
  switch (routerType)
  {
  case 0: type = Type::Vehicle; break;
  case 1: type = Type::Pedestrian; break;
  case 2: type = Type::Bicycle; break;
  case 3: type = Type::Transit; break;
  case 4: type = Type::Ruler; break;
  default: ASSERT(false, (routerType)); return;
  }
  frm()->GetRoutingManager().SetRouter(type);
}

JNIEXPORT jint Java_app_organicmaps_sdk_Router_nativeGet(JNIEnv *, jclass)
{
  return static_cast<jint>(frm()->GetRoutingManager().GetRouter());
}

JNIEXPORT jint Java_app_organicmaps_sdk_Router_nativeGetLastUsed(JNIEnv *, jclass)
{
  return static_cast<jint>(frm()->GetRoutingManager().GetLastUsedRouter());
}

JNIEXPORT jint Java_app_organicmaps_sdk_Router_nativeGetBest(JNIEnv *, jclass, jdouble srcLat, jdouble srcLon,
                                                             jdouble dstLat, jdouble dstLon)
{
  return static_cast<jint>(frm()->GetRoutingManager().GetBestRouter(mercator::FromLatLon(srcLat, srcLon),
                                                                    mercator::FromLatLon(dstLat, dstLon)));
}

JNIEXPORT jboolean Java_app_organicmaps_sdk_Router_nativeIsRouteSpeedSettingSupported(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().IsRouteSpeedSettingSupported();
}

JNIEXPORT jint Java_app_organicmaps_sdk_Router_nativeGetRouteSpeedPercentage(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().GetRouteSpeedPercentage();
}

JNIEXPORT jdouble Java_app_organicmaps_sdk_Router_nativeGetRouteDefaultCruisingSpeedKmph(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().GetRouteDefaultCruisingSpeedKMpH();
}

JNIEXPORT void Java_app_organicmaps_sdk_Router_nativeSetRouteSpeedPercentage(JNIEnv *, jclass, jint percentage)
{
  frm()->GetRoutingManager().SetRouteSpeedPercentage(percentage);
}

JNIEXPORT jboolean Java_app_organicmaps_sdk_Router_nativeIsBicycleWindSettingSupported(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().IsBicycleWindSettingSupported();
}

JNIEXPORT jboolean Java_app_organicmaps_sdk_Router_nativeIsBicycleWindEnabled(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().IsBicycleWindEnabled();
}

JNIEXPORT jint Java_app_organicmaps_sdk_Router_nativeGetBicycleWindSpeedMps(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().GetBicycleWindSpeedMpS();
}

JNIEXPORT jint Java_app_organicmaps_sdk_Router_nativeGetBicycleWindDirectionDegrees(JNIEnv *, jclass)
{
  return frm()->GetRoutingManager().GetBicycleWindDirectionDegrees();
}

JNIEXPORT void Java_app_organicmaps_sdk_Router_nativeSetBicycleRouteSettings(JNIEnv *, jclass, jint speedPercentage,
                                                                             jboolean windEnabled, jint windSpeedMps,
                                                                             jint windDirectionDegrees)
{
  frm()->GetRoutingManager().SetBicycleRouteSettings(speedPercentage, windEnabled, windSpeedMps, windDirectionDegrees);
}
}
