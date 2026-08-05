#import "MWMRoutingOptions.h"

#include <CoreApi/Framework.h>

#include "routing/route_speed_settings.hpp"
#include "routing/routing_options.hpp"

@interface MWMRoutingOptions ()
{
  routing::RoutingOptions _options;
  BOOL _routeSpeedSettingSupported;
  NSInteger _routeSpeedPercentage;
  double _routeDefaultCruisingSpeedKMpH;
  BOOL _bicycleWindSettingSupported;
  BOOL _bicycleWindEnabled;
  NSInteger _bicycleWindSpeedMpS;
  NSInteger _bicycleWindDirectionDegrees;
}

@end

@implementation MWMRoutingOptions

- (instancetype)init
{
  self = [super init];
  if (self)
  {
    _options = routing::RoutingOptions::LoadCarOptionsFromSettings();
    auto const & routingManager = GetFramework().GetRoutingManager();
    _routeSpeedSettingSupported = routingManager.IsRouteSpeedSettingSupported();
    _routeSpeedPercentage = _routeSpeedSettingSupported ? routingManager.GetRouteSpeedPercentage()
                                                        : routing::RouteSpeedSettings::kDefaultPercentage;
    _routeDefaultCruisingSpeedKMpH =
        _routeSpeedSettingSupported ? routingManager.GetRouteDefaultCruisingSpeedKMpH() : 0.0;
    _bicycleWindSettingSupported = routingManager.IsBicycleWindSettingSupported();
    if (_bicycleWindSettingSupported)
    {
      _bicycleWindEnabled = routingManager.IsBicycleWindEnabled();
      _bicycleWindSpeedMpS = routingManager.GetBicycleWindSpeedMpS();
      _bicycleWindDirectionDegrees = routingManager.GetBicycleWindDirectionDegrees();
    }
    else
    {
      _bicycleWindEnabled = NO;
      _bicycleWindSpeedMpS = routing::RouteSpeedSettings::kDefaultWindSpeedMpS;
      _bicycleWindDirectionDegrees = 0;
    }
  }

  return self;
}

- (BOOL)avoidToll
{
  return _options.Has(routing::RoutingOptions::Road::Toll);
}

- (void)setAvoidToll:(BOOL)avoid
{
  [self setOption:(routing::RoutingOptions::Road::Toll) enabled:avoid];
}

- (BOOL)avoidDirty
{
  return _options.Has(routing::RoutingOptions::Road::Dirty);
}

- (void)setAvoidDirty:(BOOL)avoid
{
  [self setOption:(routing::RoutingOptions::Road::Dirty) enabled:avoid];
}

- (BOOL)avoidFerry
{
  return _options.Has(routing::RoutingOptions::Road::Ferry);
}

- (void)setAvoidFerry:(BOOL)avoid
{
  [self setOption:(routing::RoutingOptions::Road::Ferry) enabled:avoid];
}

- (BOOL)avoidMotorway
{
  return _options.Has(routing::RoutingOptions::Road::Motorway);
}

- (void)setAvoidMotorway:(BOOL)avoid
{
  [self setOption:(routing::RoutingOptions::Road::Motorway) enabled:avoid];
}

- (BOOL)hasOptions
{
  if (self.routeSpeedSettingSupported)
  {
    return self.routeSpeedPercentage != self.class.defaultRouteSpeedPercentage ||
           (self.bicycleWindSettingSupported && self.bicycleWindEnabled);
  }
  return self.avoidToll || self.avoidDirty || self.avoidFerry || self.avoidMotorway;
}

- (BOOL)routeSpeedSettingSupported
{
  return _routeSpeedSettingSupported;
}

- (NSInteger)routeSpeedPercentage
{
  return _routeSpeedPercentage;
}

- (void)setRouteSpeedPercentage:(NSInteger)percentage
{
  _routeSpeedPercentage = percentage;
}

- (double)routeDefaultCruisingSpeedKMpH
{
  return _routeDefaultCruisingSpeedKMpH;
}

- (BOOL)bicycleWindSettingSupported
{
  return _bicycleWindSettingSupported;
}

- (BOOL)bicycleWindEnabled
{
  return _bicycleWindEnabled;
}

- (void)setBicycleWindEnabled:(BOOL)enabled
{
  _bicycleWindEnabled = enabled;
}

- (NSInteger)bicycleWindSpeedMpS
{
  return _bicycleWindSpeedMpS;
}

- (void)setBicycleWindSpeedMpS:(NSInteger)speedMpS
{
  _bicycleWindSpeedMpS = speedMpS;
}

- (NSInteger)bicycleWindDirectionDegrees
{
  return _bicycleWindDirectionDegrees;
}

- (void)setBicycleWindDirectionDegrees:(NSInteger)directionDegrees
{
  _bicycleWindDirectionDegrees = directionDegrees;
}

+ (NSInteger)defaultRouteSpeedPercentage
{
  return routing::RouteSpeedSettings::kDefaultPercentage;
}

+ (NSInteger)minimumRouteSpeedPercentage
{
  return routing::RouteSpeedSettings::kMinPercentage;
}

+ (NSInteger)maximumRouteSpeedPercentage
{
  return routing::RouteSpeedSettings::kMaxPercentage;
}

+ (NSInteger)routeSpeedPercentageStep
{
  return routing::RouteSpeedSettings::kStepPercentage;
}

+ (NSInteger)defaultBicycleWindSpeedMpS
{
  return routing::RouteSpeedSettings::kDefaultWindSpeedMpS;
}

+ (NSInteger)minimumBicycleWindSpeedMpS
{
  return routing::RouteSpeedSettings::kMinWindSpeedMpS;
}

+ (NSInteger)maximumBicycleWindSpeedMpS
{
  return routing::RouteSpeedSettings::kMaxWindSpeedMpS;
}

+ (NSInteger)bicycleWindSpeedStepMpS
{
  return routing::RouteSpeedSettings::kWindSpeedStepMpS;
}

+ (NSInteger)bicycleWindDirectionStepDegrees
{
  return routing::RouteSpeedSettings::kWindDirectionStepDegrees;
}

- (void)save
{
  auto & routingManager = GetFramework().GetRoutingManager();
  if (self.bicycleWindSettingSupported)
  {
    routingManager.SetBicycleRouteSettings(static_cast<int>(self.routeSpeedPercentage), self.bicycleWindEnabled,
                                           static_cast<int>(self.bicycleWindSpeedMpS),
                                           static_cast<int>(self.bicycleWindDirectionDegrees));
    return;
  }
  if (self.routeSpeedSettingSupported)
  {
    routingManager.SetRouteSpeedPercentage(static_cast<int>(self.routeSpeedPercentage));
    return;
  }
  routing::RoutingOptions::SaveCarOptionsToSettings(_options);
}

- (void)setOption:(routing::RoutingOptions::Road)option enabled:(BOOL)enabled
{
  if (enabled)
    _options.Add(option);
  else
    _options.Remove(option);
}

- (BOOL)isEqual:(id)object
{
  if (![object isMemberOfClass:self.class])
    return NO;
  MWMRoutingOptions * another = (MWMRoutingOptions *)object;
  return another.avoidToll == self.avoidToll && another.avoidDirty == self.avoidDirty &&
         another.avoidFerry == self.avoidFerry && another.avoidMotorway == self.avoidMotorway &&
         another.routeSpeedSettingSupported == self.routeSpeedSettingSupported &&
         (!self.routeSpeedSettingSupported || another.routeSpeedPercentage == self.routeSpeedPercentage) &&
         another.bicycleWindSettingSupported == self.bicycleWindSettingSupported &&
         (!self.bicycleWindSettingSupported ||
          (another.bicycleWindEnabled == self.bicycleWindEnabled &&
           another.bicycleWindSpeedMpS == self.bicycleWindSpeedMpS &&
           another.bicycleWindDirectionDegrees == self.bicycleWindDirectionDegrees));
}

@end
