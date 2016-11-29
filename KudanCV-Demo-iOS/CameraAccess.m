//
//  VideoDevice.m
//  Interface_iOS_Example
//
//  Copyright © 2016 Kudan. All rights reserved.
//

#import "CameraAccess.h"
#import <UIKit/UIKit.h>


static CameraAccess *cameraStream;

@interface CameraAccess()
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_device;
    dispatch_queue_t _backgroundqueue;
    BOOL finished;
}

@end

@implementation CameraAccess

+ (CameraAccess *)getInstance
{
    if (cameraStream == nil) {
        cameraStream = [[CameraAccess alloc] init];
    }
    return cameraStream;
}

- (void)initialise
{
    _captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = nil;
    NSError *error = nil;
    
    for (AVCaptureDevice *dev in [AVCaptureDevice devices]) {
        // Discard non-cameras.
        if ([dev hasMediaType:AVMediaTypeVideo] == NO)
            continue;
        if (dev.position == AVCaptureDevicePositionBack) {
            device = dev;
            break;
        }
    }
    
    if (device == nil) {
        NSLog(@"error: couldn't find suitable camera.");
        return;
    }
    
    _device = device;
    
    // Set continuous autofocus.
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    if ([device isFocusModeSupported:focusMode]) {
        [device lockForConfiguration:&error];
        [device setFocusMode:focusMode];
        [device unlockForConfiguration];
    } else {
        NSLog(@"warning: continuous autofocus not supported.");
    }
    
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (deviceInput == nil) {
        NSLog(@"error initialising device input: %@", error);
        return;
    }
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    NSMutableDictionary *videoSettings = [[NSMutableDictionary alloc] init];
    videoSettings[(NSString *)kCVPixelBufferPixelFormatTypeKey] = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    dataOutput.videoSettings = videoSettings;
    
    _backgroundqueue = dispatch_queue_create("bgqueue", NULL);
    [dataOutput setSampleBufferDelegate:self queue:_backgroundqueue];
    
    [_captureSession addInput:deviceInput];
    [_captureSession addOutput:dataOutput];
    
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    _width = 0;
    _height = 0;
    _delegates = [NSArray new];
}

- (void)focus
{
    AVCaptureFocusMode focusMode = AVCaptureFocusModeAutoFocus;
    
    
    NSError *error = nil;
    if ([_device isFocusModeSupported:focusMode]) {
        [_device lockForConfiguration:&error];
        [_device setFocusMode:focusMode];
        
        double framerateCap = 30;
        
        [_device setActiveVideoMinFrameDuration:CMTimeMake(1, framerateCap)];
        [_device setActiveVideoMaxFrameDuration:CMTimeMake(1, framerateCap)];
        
        [_device unlockForConfiguration];
    }
}

- (void)deinitialise
{
    _captureSession = nil;
}

- (void)start
{
    [_captureSession startRunning];
}

- (void)stop
{
    [_captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    finished = NO;
    
    CFRetain(sampleBuffer);
    
    
    double timeStamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer));
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFRetain(imageBuffer);
    CVPixelBufferRef pixBuffer = imageBuffer;
    
    _width = CVPixelBufferGetWidth(pixBuffer);
    _height = CVPixelBufferGetHeight(pixBuffer);
    
    
    CVReturn lockResult = CVPixelBufferLockBaseAddress(pixBuffer, 0);
    if (lockResult == kCVReturnSuccess) {
        
        void *ypBuffer = CVPixelBufferGetBaseAddressOfPlane(pixBuffer, 0);
        void *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(pixBuffer, 1);
        
        _padding = CVPixelBufferGetBytesPerRowOfPlane(pixBuffer, 0) - _width;
        
        // Wrap data buffer in NSData.
        NSData *ypData =        [NSData dataWithBytesNoCopy:ypBuffer length:CVPixelBufferGetDataSize(pixBuffer) freeWhenDone:NO];
        NSData *cbCrData =      [NSData dataWithBytesNoCopy:cbCrBuffer length:CVPixelBufferGetDataSize(pixBuffer) freeWhenDone:NO];
        
        
        for (NSValue *value in _delegates) {
            
            id<CameraFrameEvent> delegate = value.pointerValue;
            
            if ([delegate respondsToSelector:@selector(cameraFrameReceived:timeStamp:width:height:padding:)]) {
                [delegate cameraFrameReceived:ypData timeStamp:timeStamp width:_width height:_height padding:_padding];
            }
        }
        
        // Release data.
        ypData = nil;
        cbCrData = nil;
    }
    
    CVPixelBufferUnlockBaseAddress(pixBuffer, 0);
    
    CFRelease(imageBuffer);
    CFRelease(sampleBuffer);
    finished = YES;
}


- (void)addDelegate:(id<CameraFrameEvent>)delegate
{
    NSValue *value = [NSValue valueWithNonretainedObject:delegate];
    _delegates = [_delegates arrayByAddingObject:value];
}

- (void)removeDelegate:(id<CameraFrameEvent>)delegate
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_delegates];
    for (NSValue *value in array) {
        id<CameraFrameEvent> d = value.pointerValue;
        if (d == delegate) {
            [array removeObject:d];
            break;
        }
        _delegates = array;
    }
}

- (void)removeDelegates
{
    while (!finished){
        self.delegates = [NSArray new];
    }
}

@end
