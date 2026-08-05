#import "MWMRoutingOptions.h"

#include <CoreApi/Framework.h>

#include "routing/route_speed_settings.hpp"
#include "routing/routing_options.hpp"

@interface MWMRoutingOptions ()
{
  routing::RoutingOptions _options;
  BOOL _routeSpeedSettingSupported;
  NSInteger _routeSpeedPercentage;
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
    return self.routeSpeedPercentage != self.class.defaultRouteSpeedPercentage;
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
  GetFramework().GetRoutingManager().SetRouteSpeedPercentage(static_cast<int>(percentage));
  _routeSpeedPercentage = percentage;
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

- (void)save
{
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
         (!self.routeSpeedSettingSupported || another.routeSpeedPercentage == self.routeSpeedPercentage);
}

@end
