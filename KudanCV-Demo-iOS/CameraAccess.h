//
//  VideoDevice.h
//  Interface_iOS_Example
//
//  Copyright © 2016 Kudan. All rights reserved.
//
//  This file just contains a simple way to get the camera data in iOS. It's not important for understanding how to use the marker tracker



#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 Protocol for camera events.
 */
@protocol CameraFrameEvent <NSObject>

@optional
/**
 The camera received a new frame.
 
 @param data Contains the camera image data buffer in the format defined by cameraDataFormat.
 @param timeStamp the time the frame was captured.
 @param width height Size of image
 @param padding Padding of the image (usually 0)
 */
- (void)cameraFrameReceived:(NSData *)data timeStamp:(NSTimeInterval)timeStamp width:(float)width height:(float)height padding:(float)padding;

@end


/**
 This is a fairly minimal class for getting access to the iOS camera stream
 Once the camera image has been read (greyscale only, stored as NSData) any delegates are given these data
 */
@interface CameraAccess : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 Get the manager singleton.
 @return the singleton instance.
 */
+ (CameraAccess *)getInstance;



/**
 Initialise the camera. This is usually handled automatically.
 */
- (void)initialise;

/**
 Deinitialise the camera. This is usually handled automatically.
 */
- (void)deinitialise;

/**
 Start the camera stream. This is usually handled automatically.
 */
- (void)start;

/**
 Stop the camera stream. This is usually handled automatically.
 */
- (void)stop;

- (void)addDelegate:(id<CameraFrameEvent>)delegate;
- (void)removeDelegate:(id<CameraFrameEvent>)delegate;

/**
 The width of the camera image in pixels.
 */
@property (nonatomic) float width;

/**
 The height of the camera image in pixels.
 */
@property (nonatomic) float height;

@property (nonatomic) float padding;


/**
 Array containing the delegates.
 */
@property (nonatomic) NSArray *delegates;


/**
 Removes delegates for Events
 */
- (void)removeDelegates;

@end



