#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The personal speed the user keeps and, for bicycles, the wind they ride in, together with the
/// limits the UI has to respect. Both correct the estimated time of arrival only: the route itself is
/// chosen exactly as before.
NS_SWIFT_NAME(RouteSpeedSettings)
@interface MWMRouteSpeedSettings : NSObject

/// Cruising speed on flat pavement, km/h.
@property(nonatomic) double cruisingSpeedKMpH;
/// Wind speed, m/s. 0 means the wind is not taken into account.
@property(nonatomic) NSInteger windSpeedMpS;
/// Compass direction the wind blows from, degrees.
@property(nonatomic) NSInteger windDirectionDegrees;

@property(nonatomic, readonly) double minimumSpeedKMpH;
@property(nonatomic, readonly) double maximumSpeedKMpH;
@property(nonatomic, readonly) double speedStepKMpH;
/// The speed the routing profile itself predicts, i.e. the one that keeps the original ETA.
@property(nonatomic, readonly) double defaultSpeedKMpH;
/// The highest wind speed the user can set, m/s. 0 means this vehicle has no wind setting.
@property(nonatomic, readonly) NSInteger maximumWindSpeedMpS;
@property(nonatomic, readonly) BOOL windSupported;
/// How many settings the user has changed from their defaults, shown as a badge.
@property(nonatomic, readonly) NSInteger changedCount;

@property(class, nonatomic, readonly) NSInteger defaultWindSpeedMpS;
@property(class, nonatomic, readonly) NSInteger windDirectionStepDegrees;

/// The settings of the current router, or nil if it has no personal speed (car, transit).
+ (nullable instancetype)current;

- (void)save;

@end

NS_ASSUME_NONNULL_END
