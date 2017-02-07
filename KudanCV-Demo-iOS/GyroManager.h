#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

class KudanQuaternion;

@interface GyroManager : NSObject

@property (nonatomic, readonly) CMMotionManager *motionManager;
@property (nonatomic) CMAttitude *referenceAttitude;
@property (nonatomic) NSMutableArray *delegates;

/**
 Get the manager singleton.
 @return the singleton instance.
 */
+ (GyroManager *)getInstance;

- (void)initialise;

- (KudanQuaternion)getOrientation;

@end
