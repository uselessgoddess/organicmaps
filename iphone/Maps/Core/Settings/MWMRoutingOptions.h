#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(RoutingOptions)
@interface MWMRoutingOptions : NSObject

@property(nonatomic) BOOL avoidToll;
@property(nonatomic) BOOL avoidDirty;
@property(nonatomic) BOOL avoidFerry;
@property(nonatomic) BOOL avoidMotorway;
@property(nonatomic, readonly) BOOL routeSpeedSettingSupported;
@property(nonatomic) NSInteger routeSpeedPercentage;
@property(nonatomic, readonly) BOOL hasOptions;

@property(class, nonatomic, readonly) NSInteger defaultRouteSpeedPercentage;
@property(class, nonatomic, readonly) NSInteger minimumRouteSpeedPercentage;
@property(class, nonatomic, readonly) NSInteger maximumRouteSpeedPercentage;
@property(class, nonatomic, readonly) NSInteger routeSpeedPercentageStep;

- (void)save;

@end

NS_ASSUME_NONNULL_END
