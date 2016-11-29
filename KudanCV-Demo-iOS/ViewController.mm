#import "ViewController.h"
#import "Drawing.h"
#import "Interface.h"
#import <fstream>

enum TrackerState {
    Uninitialised,
    ImageDetection,
    ImageTracking,
    ArbiTrackRunning
};

@interface ViewController ()
{
    std::shared_ptr<KudanImageTracker> imageTracker;
    std::vector<std::shared_ptr<KudanImageTrackable>> trackables;

    
    std::shared_ptr<KudanArbiTracker> arbiTracker;
    
    TrackerState trackerState;
    TrackerState nextState;
    
    
    CGPoint trackedCentre;
    CGPoint trackedCorner0;
    CGPoint trackedCorner1;
    CGPoint trackedCorner2;
    CGPoint trackedCorner3;
    NSString *trackedName;
    
    Quadrilateral *trackerRectangle;
    Grid *arbitrackGrid;
    

    CGPoint arbitrackCentre;
    
    CGPoint arbitrackCorner0;
    CGPoint arbitrackCorner1;
    CGPoint arbitrackCorner2;
    CGPoint arbitrackCorner3;
    
    float arbitrackScale;
    
    
    KudanVector3 trackedPosition;
    KudanQuaternion trackedOrientation;
}

@end

@implementation ViewController


// ==== Utility functions ====

unsigned char *imageDataFromUIImage(UIImage *image)
{
    // This follows the older matFromUIImage function to turn a UIImage into OpenCV data
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    
    // The step value originally came from mat.step[0] after initialising a matrix as: cv::Mat mat(rows, cols, CV_8UC4);
    // For a four channel matrix, step[0] == cols*4
    size_t step = cols*4;
    
    // Allocate the image data memory explicitly instead of using cv::Mat
    // Four channel image so need to allocate enough space
    unsigned char *data = new unsigned char[int(rows*cols*4)];
    
    CGContextRef contextRef = CGBitmapContextCreate(data, cols, rows, 8, step, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return data;
}

+ (UIImage*)uiImageFromData:(NSData *)data width:(float)width height:(float)height padding:(float)padding
{
    CGColorSpaceRef colorSpace;
    colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    
    CGImageRef imageRef = CGImageCreate(width,                                      //width
                                        height,                                     //height
                                        8,                                          //bits per component
                                        8 * 1,                                      //bits per pixel (assume greyscale)
                                        width,                                      //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


// ==== Demo ====



/**
 This sets up this MarkerTracker class as a delegate of the CameraAccess class, so it will be informed when there is a new frame */
- (void)initialiseCamera
{
    CameraAccess *cam = [CameraAccess getInstance];
    [cam initialise];
    
    [cam addDelegate:self];
    
    [cam start];
}




- (void)viewDidLoad
{
    trackerState = Uninitialised;
    nextState = Uninitialised;

    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // initialise camera first to get the paramters (in principle)

    [self initialiseCamera];
    [self initialiseTracker];
    [self initialiseArbitrack];
    
    trackerRectangle = [Quadrilateral new];
    [trackerRectangle initialise:self.cameraImageView];
    
    arbitrackGrid = [Grid new];
    [arbitrackGrid initialise:self.cameraImageView];
    
    
    self.trackerLabel.hidden = true;
    self.arbitrackLabel.hidden = true;
    [trackerRectangle hide];
    [arbitrackGrid hide];
}

/** This is called because it is a delegate of CameraAccess
 */
- (void)cameraFrameReceived:(NSData *)data timeStamp:(NSTimeInterval)timeStamp width:(float)width height:(float)height padding:(float)padding
{
    // Do the image processing in here:
    [self processFrame:data width:width height:height padding:padding];
    
    
    // Get the current image as a UIImage so it can be displayed
    UIImage *image = [ViewController uiImageFromData:data width:width height:height padding:padding];
    
    int expectedImageWidth = 640;
    int expectedImageHeight = 480;
    
    if (image != nil) {
        
        if (int(image.size.width) != expectedImageWidth || int(image.size.height) != expectedImageHeight) {
            NSLog(@"Warning, image is the wrong size, got %f x %f, should be %i x %i \n", image.size.width, image.size.height,  expectedImageWidth, expectedImageHeight);
        }
        
       // Note: the camera image is already positioned and scaled (top left, expecting 640 480), so no need to update now
        
        // Draw a label in the middle of the object to say which trackable it is
        float labelSize = 120;
        CGRect trackerRect;
        if (trackerState == ImageTracking) {
            trackerRect = CGRectMake( trackedCentre.x-labelSize/2.f, trackedCentre.y-labelSize/2.f, labelSize, labelSize);
        }
        
        CGRect arbitrackRect;

        if (trackerState == ArbiTrackRunning) {

            // check arbitrack pose is ok
            if (arbitrackCentre.x != 0 && arbitrackCentre.y != 0) {
                arbitrackRect = CGRectMake( arbitrackCentre.x-labelSize/2.f, arbitrackCentre.y-labelSize/2.f, labelSize, labelSize);
            }

         
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            
            NSString *stateText;
            UIColor *stateColour;
            
            NSString *buttonText;
            UIColor *buttonColour;
            if (trackerState == Uninitialised) {
                stateText = @"";
                
                buttonText = @"* * *";
                buttonColour = [UIColor grayColor];
            }
            else if (trackerState == ImageDetection) {
                stateText = @"Looking for image...";
                stateColour = [UIColor orangeColor];
                
                buttonText = @"Start arbitrack here";
                buttonColour = [UIColor orangeColor];
            }
            else if (trackerState == ImageTracking) {
                stateText = @"Tracking image";
                stateColour = [UIColor cyanColor];
                
                buttonText = @"Start arbitrack from marker";
                buttonColour = [UIColor blueColor];
            }
            else if (trackerState == ArbiTrackRunning) {
                stateText = @"Running Arbitrack";
                stateColour = [UIColor greenColor];
                
                buttonText = @"Stop arbitrack";
                buttonColour = [UIColor greenColor];
            }
        
            
            // Update the image shown on the UILabel, but don't need to alter its location
            self.cameraImageView.image = image;

            
            self.stateLabel.text = stateText;
            self.stateLabel.textColor = stateColour;
            
            // Alter the arbitrack button's text and colour, but no need to alter its location (stays below fixed camera image)
            [self.arbitrackButton setTitle:buttonText forState:UIControlStateNormal];
            self.arbitrackButton.backgroundColor = buttonColour;
            
            
            if (trackerState == ImageTracking) {
                self.trackerLabel.text = trackedName;
                self.trackerLabel.frame = trackerRect;
                self.trackerLabel.hidden = false;
                self.trackerLabel.textColor = [UIColor cyanColor];
                
                
                
                // Pass the four projected corners of the trackable to the Quadrilateral object for drawing
                [trackerRectangle draw:self.cameraImageView p0:trackedCorner0 p1:trackedCorner1 p2:trackedCorner2 p3:trackedCorner3 colour:[UIColor blueColor]];
            }
            else {
                
                self.trackerLabel.hidden = true;
                [trackerRectangle hide];
            }

            
            if (trackerState == ArbiTrackRunning) {
                
                self.arbitrackLabel.text = @"Arbitrack";
                self.arbitrackLabel.frame = arbitrackRect;
                self.arbitrackLabel.hidden = false;
                self.arbitrackLabel.textColor = [UIColor whiteColor];
                
                
                [arbitrackGrid draw:self.cameraImageView p0:arbitrackCorner0 p1:arbitrackCorner1 p2:arbitrackCorner2 p3:arbitrackCorner3 colour:[UIColor greenColor]];
            }
            else {
                self.arbitrackLabel.hidden = true;
                [arbitrackGrid hide];
            }
        });
    }
}


// Tracking:

/** This just reads the first line from a file and returns it
 */
std::string loadKey(std::string file)
{
    std::ifstream fileStream;
    fileStream.open(file);
    if (fileStream.is_open()) {
        std::string line;
        getline(fileStream, line);
        return line;
    }
    else {
        printf("COULD NOT OPEN FILE! \n");
        return "";
    }
    
}

/** This reads a key via a bundled file (give the filename in the bundle, then this gets the actual path and calls loadKey()
 */
std::string loadBundledKey(std::string file)
{
    NSString *keyFileNS = [NSString stringWithUTF8String:file.c_str()];
    NSString *keyFilePathNS = [[NSBundle mainBundle] pathForResource:keyFileNS ofType:nil];
    std::string keyFilePath([keyFilePathNS UTF8String]);
    
    std::string key = loadKey(keyFilePath);

    return key;
}

- (void)initialiseTracker
{
    // Don't need to use singletons: just create an instance of the tracker and store it somewhere
    imageTracker = std::make_shared<KudanImageTracker>();
    
    // only track one at a time for now
    imageTracker->setMaximumSimultaneousTracking(1);
    
    
    // Setup the camera parameters
    KudanCameraParameters parameters;
    
    // Should use the camera to get the image stream size, but it's not initialised yet, so just hardcode for now
    parameters.setSize(640, 480);
    
    // Don't know the intrinsics so tell it to figure them out
    parameters.guessIntrinsics();
    
    // Important: set the intrinsic parameters on the tracker
    imageTracker->setCameraParameters(parameters);
    
    
    std::string keyFile = "key.txt";
    std::string key = loadBundledKey(keyFile);
    
    imageTracker->setApiKey(key);
    
    BOOL addedLego = [self addTrackable:@"lego.jpg" name:@"Lego"];
    NSLog(@"addedLego = %i ", addedLego);
    
    trackerState = ImageDetection;
}


-(void) initialiseArbitrack
{
    arbiTracker = std::make_shared<KudanArbiTracker>();
    
    
    // Setup the camera parameters
    KudanCameraParameters parameters;
    
    // Should use the camera to get the image stream size, but it's not initialised yet, so just hardcode for now
    parameters.setSize(640, 480);
    
    // Don't know the intrinsics so tell it to figure them out
    parameters.guessIntrinsics();
    
    // Important: set the intrinsic parameters on the tracker
    arbiTracker->setCameraParameters(parameters, 10, 1000);

    
    
    std::string keyFile = "key.txt";
    std::string key = loadBundledKey(keyFile);
    
    arbiTracker->setApiKey(key);
}


- (IBAction)arbitrackAction:(id)sender
{
    if (trackerState == Uninitialised) {
        NSLog(@"Error: not initialised");
    }
    else if (trackerState == ImageDetection) {
        
        NSLog(@"Requested: Initialise Arbitrack from here \n");
        
        
        KudanVector3 startPosition(0,0,200); // in front of the camera
        KudanQuaternion startOrientation(1,0,0,0); // without rotation
        arbiTracker->start(startPosition, startOrientation);
        
        arbitrackScale = 100;
        
        // Always set the state via the nextState variable to avoid thread synchronisation issues!
        // Otherwise the value could be re-set to something else before this is used (if already processing the frame)
        nextState = ArbiTrackRunning;
    }
    
    else if (trackerState == ImageTracking) {
        
        
        NSLog(@"Requested: Initialise Arbitrack from marker \n");
        
        
        arbiTracker->start(trackedPosition, trackedOrientation);
        // arbitrack scale should have been set already

        nextState = ArbiTrackRunning;
    }
    else if (trackerState == ArbiTrackRunning) {
        NSLog(@"Requested: Stop arbitrack");
        arbiTracker->stop();
        
        nextState = ImageDetection;

    }
}

/** Project a 3D point to 2D image given the camera pose (R, T) and calibration (K)
 This reflects the x-coordinate so that the screen coordinates align with what is used inside the tracker
 */
KudanVector2 project(KudanVector3 X, KudanMatrix3 intrinsicMatrix, KudanVector3 position, KudanQuaternion orientation, float w)
{
    
    // to project a 3D point X (3x1) according to a camera with rotation R (3x3) and translation T (3x1), and the camera intrinsic matrkx K (3x3), xh = K[R|T]X = K*(RX + T), where xh is the homogeneous point
    
    
    //KudanMatrix3 rotationMatrix = KudanQuaternion::quaternionToRotation(orientation);
    KudanMatrix3 rotationMatrix(orientation);
    
    KudanVector3 RX = rotationMatrix.multiply(X);
    KudanVector3 RXplusT = RX.add(position); // this is the point X expressed in the camera's coordinate frame
    
    // Project using the intrinsicmatrix:
    KudanVector3 XH = intrinsicMatrix.multiply(RXplusT);
    
    // Divide the homogeneous coordinates through by the z coordinate
    // Note: also need to reflect in the horizontal direction, because of the reference frame in which the pose is given!
    KudanVector2 pt(w - XH.x / XH.z , XH.y / XH.z);
    
    return pt;
}


/** 
 Process an image frame, expressed as an NSData array, using the image tracker
 */
- (void)processFrame:(NSData *)data width:(float)width height:(float)height padding:(float)padding
{
    // If there is a next state, set it now, before entering the processing frame (so as not to overwrite anything)
    if (nextState != Uninitialised) {
        trackerState = nextState;
        nextState = Uninitialised;
    }
    
    if (trackerState == Uninitialised ) {
        NSLog(@"Uninitialised! ");
        return;
    }
    else if (trackerState == ImageDetection || trackerState == ImageTracking) {
        
        if (imageTracker == nullptr) {
            NSLog(@"Error: Image Tracker is NULL! \n");
            return;
        }

        
        unsigned char *base = (unsigned char *)data.bytes;

        imageTracker->processFrame(base, width, height, 1 /* assume one channel*/, padding, false /* don't need to flip the image*/);
        
        
        
        //  Get all the detected trackables for this frame:
        std::vector<std::shared_ptr<KudanImageTrackable>> trackedList = imageTracker->getDetectedTrackables();
        
        
        // If there is exactly one (can only show one for now)
        if (trackedList.size() == 1) {
            
            trackerState = ImageTracking;
            
            std::shared_ptr<KudanImageTrackable> tracked = trackedList[0];

            
            /** Get the pose of the tracked object to draw it
             This is expressed as a 3D position and a unit quaternion for orientation
             This is: the position of the trackable centre with respect to the camera, and the orientation of the trackable about this centre
             This is equivalent to having the rotation (R) and translation (T) of a camera with respect to the trackable, with which the marker position (in its own coordinate frame) can be projected to the image
             */
            
            
            // To project the tracked marker centre into the image, use the marker centre in its own coodinate frame (obviously the origin) and project that using the tracked pose expressed as a camera */
            KudanVector3 origin(0,0,0);
            
            // Get the camera intrinsics as a 3x3 matrix
            KudanMatrix3 K = imageTracker->getCameraMatrix();
            
            // Project the point (0,0,0) using the camera intrinsics and extrinsics. Also need to pass in the image with (see function)
            KudanVector3 position = tracked->getPosition();
            KudanQuaternion orientation = tracked->getOrientation();
            KudanVector2 projection = project(origin, K, position, orientation, width);

            

            // Store the details of this trackable
            trackedCentre = CGPointMake(projection.x, projection.y);
            
            
            // As well as the centre, it's useful to draw the four corners of the tracked object
            // Because the trackable is defined as having size width x height in the world, and is at the origin (of its own coordinate frame), the bounds of the marker are at (+/- width/2, +/- height/2). Projecting these four points into the current image using the camera pose gets the outline of the tracked marker in the image:
            
            float w = tracked->getWidth();
            float h = tracked->getHeight();
            
            
            
            KudanVector3 corner00(-w/2.f, -h/2.f, 0);
            KudanVector2 projection00 = project(corner00, K, position, orientation, width);
            
            KudanVector3 corner01(-w/2.f, h/2.f, 0);
            KudanVector2 projection01 = project(corner01, K, position, orientation, width);
            
            KudanVector3 corner11(w/2.f, h/2.f, 0);
            KudanVector2 projection11 = project(corner11, K, position, orientation, width);
            
            KudanVector3 corner10(w/2.f, -h/2.f, 0);
            KudanVector2 projection10 = project(corner10, K, position, orientation, width);
            
            
            // Save as four separate points as properties on the MarkerTracker:
            trackedCorner0 = CGPointMake(projection00.x, projection00.y);
            trackedCorner1 = CGPointMake(projection01.x, projection01.y);
            trackedCorner2 = CGPointMake(projection11.x, projection11.y);
            trackedCorner3 = CGPointMake(projection10.x, projection10.y);
            
            // Save the name of the trackable (so it can visible switch between multiplt trackables)
            trackedName = [NSString stringWithUTF8String:tracked->getName().c_str()];
            
            
            // Save the size and pose in case it's needed for initialising arbitrack
            trackedPosition = position;
            trackedOrientation = orientation;
            arbitrackScale = h;
        }
        else {
            // Not tracking but trying to, i.e. detection state
            trackerState = ImageDetection;
        }
    }
    else if (trackerState == ArbiTrackRunning) {
        
        if (arbiTracker == nullptr) {
            NSLog(@"Error: ArbiTracker is NULL! \n");
            return;
        }
        
        
        arbitrackCentre = CGPointMake(0, 0);
        
        unsigned char *base = (unsigned char *)data.bytes;

        arbiTracker->processFrame(base, width, height, 1 /* assume one channel*/, padding, false /* don't need to flip the image*/);
        
        
        if (arbiTracker->isTracking()) {
            // Get the camera intrinsics as a 3x3 matrix
            KudanMatrix3 K = arbiTracker->getCameraMatrix(); // need this on arbitracker - oops! TODO

            
            KudanVector3 position = arbiTracker->getPosition();
            // make sure it's not the zero vector
            if (position.x == 0 && position.y == 0 && position.z == 0) {

            }
            else {
                KudanQuaternion orientation = arbiTracker->getOrientation();
                
                
                KudanVector3 origin(0,0,0);
                
                KudanVector2 projection = project(origin, K, position, orientation, width);
                
                arbitrackCentre = CGPointMake(projection.x, projection.y);
                
                // Get the four outer grid corners by projecting  +/- the arbitrack scale in (x,y)
                KudanVector3 corner00(-arbitrackScale, -arbitrackScale, 0);
                KudanVector2 projection00 = project(corner00, K, position, orientation, width);
                
                KudanVector3 corner01(-arbitrackScale, arbitrackScale, 0);
                KudanVector2 projection01 = project(corner01, K, position, orientation, width);
                
                KudanVector3 corner11(arbitrackScale, arbitrackScale, 0);
                KudanVector2 projection11 = project(corner11, K, position, orientation, width);
                
                KudanVector3 corner10(arbitrackScale, -arbitrackScale, 0);
                KudanVector2 projection10 = project(corner10, K, position, orientation, width);
                
                
                // Save as four separate points as properties on the MarkerTracker:
                arbitrackCorner0 = CGPointMake(projection00.x, projection00.y);
                arbitrackCorner1 = CGPointMake(projection01.x, projection01.y);
                arbitrackCorner2 = CGPointMake(projection11.x, projection11.y);
                arbitrackCorner3 = CGPointMake(projection10.x, projection10.y);
            }
        }
    }
}


/**
 Wrapper function for adding a trackable to the tracker, from an image file, via a UIImage
 */
- (BOOL)addTrackable:(NSString*)imageName name:(NSString*)name
{
    UIImage *image =  [UIImage imageNamed:imageName];
    
    unsigned char *imageData = imageDataFromUIImage(image);
    
    // This is how to create a KudanImageTrackable object, using a pointer to image data:
    std::shared_ptr<KudanImageTrackable> kudanImageTrackable = KudanImageTrackable::createFromImageData(imageData, name.UTF8String,  image.size.width, image.size.height, 4 /* this should be four channel RGBA data */, 0);
    
    // The above method will return a null pointer if not successful:
    
    if (kudanImageTrackable) {
        // Once the trackable is created, it needs to be added to the tracker!
        return imageTracker->addTrackable(kudanImageTrackable);
    }
    else {
        return false;
    }
}

@end
