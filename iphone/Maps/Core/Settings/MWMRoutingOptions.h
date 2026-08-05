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
@property(nonatomic, readonly) BOOL bicycleWindSettingSupported;
@property(nonatomic) BOOL bicycleWindEnabled;
@property(nonatomic) NSInteger bicycleWindSpeedKMpH;
@property(nonatomic) NSInteger bicycleWindDirectionDegrees;
@property(nonatomic, readonly) BOOL hasOptions;

@property(class, nonatomic, readonly) NSInteger defaultRouteSpeedPercentage;
@property(class, nonatomic, readonly) NSInteger minimumRouteSpeedPercentage;
@property(class, nonatomic, readonly) NSInteger maximumRouteSpeedPercentage;
@property(class, nonatomic, readonly) NSInteger routeSpeedPercentageStep;
@property(class, nonatomic, readonly) NSInteger defaultBicycleWindSpeedKMpH;
@property(class, nonatomic, readonly) NSInteger minimumBicycleWindSpeedKMpH;
@property(class, nonatomic, readonly) NSInteger maximumBicycleWindSpeedKMpH;
@property(class, nonatomic, readonly) NSInteger bicycleWindSpeedStepKMpH;
@property(class, nonatomic, readonly) NSInteger bicycleWindDirectionStepDegrees;

- (void)save;

@end

NS_ASSUME_NONNULL_END
