#import "GyroManager.h"
#import "KudanCV.h"

static GyroManager *gyroManager;


@implementation GyroManager

+ (GyroManager *)getInstance
{
    if (gyroManager == nil) {
        gyroManager = [[GyroManager alloc] init];
    }
    return gyroManager;
}

- (void)initialise
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 0.05;
    }
    
    CMAttitudeReferenceFrame gyroReferenceFrame = CMAttitudeReferenceFrameXArbitraryCorrectedZVertical;

    CMDeviceMotion *deviceMotion = _motionManager.deviceMotion;

    self.referenceAttitude = deviceMotion.attitude;
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:gyroReferenceFrame];
}


- (void)deinitialise
{
    [_motionManager stopDeviceMotionUpdates];
    
    _motionManager = nil;
}


//  ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++ ++++
// Some matrix functions which might be needed for doing thigns with the gyro orientation

KudanQuaternion matrixToQuaternion(KudanMatrix3 matrix)
{
    // convert the matrix to a quaternion:
    float w = sqrt(1.0 + matrix(0, 0) + matrix(1, 1) + matrix(2, 2)) / 2.0;
    float w4 = (4.0 * w);
    float x = (matrix(1, 2) - matrix(2, 1)) / w4;
    float y = (matrix(2, 0) - matrix(0, 2)) / w4;
    float z = (matrix(0, 1) - matrix(1, 0)) / w4;
    
    return KudanQuaternion(-x, y, -z, w);
}

KudanMatrix3 getRotationMatrixX(double angle)
{
    double sinr = sin(angle);
    double cosr = cos(angle);
    
    KudanMatrix3 R;
    R(0,0) = 1;
    R(0,1) = 0;
    R(0,2) = 0;
    
    R(1,0) = 0;
    R(1,1) = cosr;
    R(1,2) = -sinr;
    
    R(2,0) = 0;
    R(2,1) = sinr;
    R(2,2) = cosr;
    
    return R;
}

KudanMatrix3 getRotationMatrixY(double angle)
{
    double sinr = sin(angle);
    double cosr = cos(angle);
    
    KudanMatrix3 R;
    R(0,0) = cosr;
    R(0,1) = 0;
    R(0,2) = sinr;
    
    R(1,0) = 0;
    R(1,1) = 1;
    R(1,2) = 0;
    
    R(2,0) = -sinr;
    R(2,1) = 0;
    R(2,2) = cosr;
    
    return R;
}

KudanMatrix3 getRotationMatrixZ(double angle)
{
    double sinr = sin(angle);
    double cosr = cos(angle);
    
    KudanMatrix3 R;
    R(0,0) = cosr;
    R(0,1) = -sinr;
    R(0,2) = 0;
    
    R(1,0) = sinr;
    R(1,1) = cosr;
    R(1,2) = 0;
    
    R(2,0) = 0;
    R(2,1) = 0;
    R(2,2) = 1;

    return R;
}

KudanMatrix3 multiply(KudanMatrix3 B, KudanMatrix3 A)
{
    KudanMatrix3 C;
    for (int j = 0; j < 3; j++) {
        for (int i = 0; i < 3; i++) {
            // dot product of row i of A and col j of B
            for (int k = 0; k < 3; k++) {
                C(i,j) += A(i,k)*B(k,j);
            }
        }
    }
    return C;
}

- (KudanQuaternion)getGyroOrientation
{
    if (_motionManager.deviceMotion == nil) {
        return KudanQuaternion();
    }
    
    CMAttitude *attitude = _motionManager.deviceMotion.attitude;
    CMRotationMatrix rot = attitude.rotationMatrix;
    
    KudanMatrix3 matrix = KudanMatrix3();
    matrix(0, 0) = rot.m11;
    matrix(0, 1) = rot.m21;
    matrix(0, 2) = rot.m31;
    matrix(1, 0) = rot.m12;
    matrix(1, 1) = rot.m22;
    matrix(1, 2) = rot.m32;
    matrix(2, 0) = rot.m13;
    matrix(2, 1) = rot.m23;
    matrix(2, 2) = rot.m33;
    
    //rotate by 90 degrees around the Z axis
    KudanMatrix3 RZ = getRotationMatrixZ(M_PI / 2);
    matrix = multiply(RZ, matrix);
    
    return KudanQuaternion(matrixToQuaternion(matrix));
}

- (KudanQuaternion)getOrientation
{
    return [self getGyroOrientation];
}

@end
