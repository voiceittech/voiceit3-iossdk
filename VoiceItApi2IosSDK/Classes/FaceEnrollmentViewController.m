//
//  FaceEnrollmentViewController.m
//  VoiceItApi2IosSDK
//
//  Created by Armaan Bindra on 5/7/18.
//

#import "FaceEnrollmentViewController.h"

@interface FaceEnrollmentViewController ()
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
@property(nonatomic, strong)  AVAssetWriter *assetWriterMyData;
@property(nonatomic, strong)  NSString *videoPath;
@property(nonatomic, strong)  AVAssetWriterInput *assetWriterInput;
@end

@implementation FaceEnrollmentViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue",
                                                          DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageLabel.textColor  = [Utilities uiColorFromHexString:@"#FFFFFF"];
    [self.navigationItem setHidesBackButton: YES];
    self.myNavController = (MainNavigationController*) [self navigationController];
    self.myVoiceIt = (VoiceItAPITwo *) _myNavController.myVoiceIt;
    //TODO: Make all these come dynamically when triggering enrollment process
    self.userToEnrollUserId = _myNavController.uniqueId;
    // Setup Cancel Button on top left of navigation controller
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
    leftBarButton.tintColor = [Utilities uiColorFromHexString:@"#FFFFFF"];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    
    // Initialize Boolean and All
    self.lookingIntoCam = NO;
    self.enoughRecordingTimePassed = NO;
    self.enrollmentStarted = NO;
    self.continueRunning  = YES;
    self.lookingIntoCamCounter = 0;
    self.isReadyToWrite = NO;
    [self setNavigationTitle:@"Enrolling Face"];
    // Set up the AVCapture Session
    [self setupCaptureSession];
    [self setupVideoProcessing];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupCameraCircle];
    self.originalMessageLeftConstraintContstant = self.messageleftConstraint.constant;
}

-(void)cancelClicked{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.continueRunning = NO;
    [self cleanupCaptureSession];
    [_myVoiceIt deleteAllUserEnrollments:_userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
        [[self navigationController] dismissViewControllerAnimated:YES completion:^{
            [[self myNavController] userEnrollmentsCancelled];
        }];
    }];
}

-(void)setNavigationTitle:(NSString *) titleText {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self navigationItem] setTitle: titleText];
    });
}

-(void)setupCaptureSession{
    // Setup Video Input Devices
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    [self.captureSession setSessionPreset: AVCaptureSessionPresetMedium];
    self.videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    NSError * videoError;
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: self.videoDevice error:&videoError];
    [self.captureSession addInput:videoInput];
}

-(void)setupCameraCircle{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // Setup code to capture face meta data
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [self.captureSession addOutput: metadataOutput];
    // We're only interested in faces
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    // This VC is the delegate. Please call us on the main queue
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Setup Little Camera Circle and Positions
    CALayer *rootLayer = [[self view] layer];
    CGFloat backgroundWidthHeight = (CGFloat) self.view.frame.size.height  * 0.42;
    CGFloat cameraViewWidthHeight = (CGFloat) self.view.frame.size.height  * 0.4;
    CGFloat circleWidth = (backgroundWidthHeight - cameraViewWidthHeight) / 2;
    CGFloat backgroundViewX = (self.view.frame.size.width - backgroundWidthHeight)/2;
    CGFloat cameraViewX = (self.view.frame.size.width - cameraViewWidthHeight)/2;
    CGFloat backgroundViewY = 110.0; // TODO: Make this number a constant
    CGFloat cameraViewY = backgroundViewY + circleWidth;
    
    self.cameraBorderLayer = [[CALayer alloc] init];
    self.progressCircle = [CAShapeLayer layer];
    [self.cameraBorderLayer setFrame:CGRectMake(backgroundViewX, backgroundViewY, backgroundWidthHeight, backgroundWidthHeight)];
    [self.previewLayer setFrame:CGRectMake(cameraViewX, cameraViewY, cameraViewWidthHeight, cameraViewWidthHeight)];
    [self.previewLayer setCornerRadius: cameraViewWidthHeight / 2];
    self.cameraCenterPoint = CGPointMake(self.cameraBorderLayer.frame.origin.x + (backgroundWidthHeight/2), self.cameraBorderLayer.frame.origin.y + (backgroundWidthHeight/2) );
    
    if ([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        CGPoint autofocusPoint = self.cameraCenterPoint;
        [self.videoDevice setFocusPointOfInterest:autofocusPoint];
        [self.videoDevice setFocusMode:AVCaptureFocusModeLocked];
    }
    
    // Setup Progress Circle
    self.progressCircle .path = [UIBezierPath bezierPathWithArcCenter: self.cameraCenterPoint radius:(backgroundWidthHeight / 2) startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2 clockwise:YES].CGPath;
    self.progressCircle.fillColor = [UIColor clearColor].CGColor;
    self.progressCircle.strokeColor = [UIColor clearColor].CGColor;
    self.progressCircle.lineWidth = circleWidth * 2.0;
    [self.cameraBorderLayer setBackgroundColor: [UIColor clearColor].CGColor];
    self.cameraBorderLayer.cornerRadius = circleWidth / 2;
    
    // Setup Rectangle Around Face
    self.faceRectangleLayer = [[CALayer alloc] init];
    self.faceRectangleLayer.zPosition = 1;
    self.faceRectangleLayer.borderColor = [Styles getMainCGColor];
    self.faceRectangleLayer.borderWidth  = 4.0;
    self.faceRectangleLayer.opacity = 0.7;
    [self.faceRectangleLayer setHidden:YES];
    
    [rootLayer addSublayer:self.cameraBorderLayer];
    [rootLayer addSublayer:self.progressCircle];
    [rootLayer addSublayer:self.previewLayer];
    [self.previewLayer addSublayer:self.faceRectangleLayer];
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}

-(void)animateProgressCircle {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressCircle.strokeColor = [Styles getMainCGColor];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 3.0;
        animation.removedOnCompletion = YES;//NO;
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.progressCircle addAnimation:animation forKey:@"drawCircleAnimation"];
    });
    
}

-(void)startDelayedRecording:(NSTimeInterval)delayTime{
    NSLog(@"Starting Delayed RECORDING with delayTime %f ", delayTime);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(self.continueRunning){
            [self makeLabelFlyIn:[ResponseManager getMessage:@"FACE_ENROLL"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(self.continueRunning){
                    [self startRecording];
                }
            });
        }
    });
}

-(void)startRecording {
    NSLog(@"Starting RECORDING");
    self.isRecording = YES;
    [self startWritingToVideoFile];
    self.cameraBorderLayer.backgroundColor = [UIColor clearColor].CGColor;
    // Initialize Face Variables
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(self.continueRunning){
            [self setEnoughRecordingTimePassed:YES];
            [self stopRecording];
        }
    });
    // Start Progress Circle Around Face Animation
    [self animateProgressCircle];
}

-(void)stopRecording{
    self.isRecording = NO;
    [self setEnoughRecordingTimePassed:NO];
    [self stopWritingToVideoFile];
}

- (void)cleanupCaptureSession {
    [self.captureSession stopRunning];
    [self cleanupVideoProcessing];
    self.captureSession = nil;
    [self.previewLayer removeFromSuperlayer];
}

- (void)cleanupVideoProcessing {
    if (self.videoDataOutput) {
        [self.captureSession removeOutput:self.videoDataOutput];
    }
    self.videoDataOutput = nil;
}

- (void)setupVideoProcessing {
    self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *rgbOutputSettings = @{
                                        (__bridge NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
                                        };
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    
    if (![self.captureSession canAddOutput:self.videoDataOutput]) {
        [self cleanupVideoProcessing];
        NSLog(@"Failed to setup video output");
        return;
    }
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    [self.captureSession addOutput:self.videoDataOutput];
}

-(void)startWritingToVideoFile{
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:640], AVVideoWidthKey, [NSNumber numberWithInt:480], AVVideoHeightKey, AVVideoCodecH264, AVVideoCodecKey,nil];
    self.assetWriterInput = [AVAssetWriterInput  assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [self.assetWriterInput setTransform: CGAffineTransformMakeRotation( ( 90 * M_PI ) / 180 )];
    self.pixelBufferAdaptor =
    [[AVAssetWriterInputPixelBufferAdaptor alloc]
     initWithAssetWriterInput:self.assetWriterInput
     sourcePixelBufferAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
      kCVPixelBufferPixelFormatTypeKey,
      nil]];
    
    self.videoPath = [Utilities pathForTemporaryFileWithSuffix:@"mp4"];
    NSURL *videoURL = [NSURL fileURLWithPath:self.videoPath];
    
    /* Asset writer with MPEG4 format*/
    self.assetWriterMyData = [[AVAssetWriter alloc]
                              initWithURL: videoURL
                              fileType:AVFileTypeMPEG4
                              error:nil];
    [self.assetWriterMyData addInput:self.assetWriterInput];
    self.assetWriterInput.expectsMediaDataInRealTime = YES;
    [self.assetWriterMyData startWriting];
    [self.assetWriterMyData startSessionAtSourceTime:kCMTimeZero];
    self.isReadyToWrite = YES;
}

-(void)stopWritingToVideoFile {
    self.isReadyToWrite = NO;
    [self.assetWriterMyData finishWritingWithCompletionHandler:^{
        [self showLoading];
        if(!self.continueRunning){
            return;
        }
        [self.myVoiceIt createFaceEnrollment:self.userToEnrollUserId videoPath:self.videoPath callback:^(NSString * jsonResponse){
            [Utilities deleteFile:self.videoPath];
            [self removeLoading];
            NSLog(@"Face Enrollment JSON Response : %@", jsonResponse);
            NSDictionary *jsonObj = [Utilities getJSONObject:jsonResponse];
            NSLog(@"Response Code is %@ and message is : %@", [jsonObj objectForKey:@"responseCode"], [jsonObj objectForKey:@"message"]);
            NSString * responseCode = [jsonObj objectForKey:@"responseCode"];
            if([responseCode isEqualToString:@"SUCC"]){
             [self takeToFinishedView];
            } else {
                [self startDelayedRecording:3.0];
                [self makeLabelFlyIn:[ResponseManager getMessage:responseCode]];
            }
        }];

    }];
}

-(void)startEnrollmentProcess {
    [self.myVoiceIt getAllFaceEnrollmentsForUser:self.userToEnrollUserId callback:^(NSString * getEnrollmentsJSONResponse){
        NSDictionary *getEnrollmentsJSONObj = [Utilities getJSONObject:getEnrollmentsJSONResponse];
        int enrollmentCount = [[getEnrollmentsJSONObj objectForKey: @"count"] intValue];
        NSLog(@"Enrollment Count From Server is %d", enrollmentCount);
        [self.myVoiceIt deleteAllUserEnrollments:self.userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
                [self makeLabelFlyIn: [ResponseManager getMessage:@"GET_ENROLLED"]];
                [self startDelayedRecording:2.0];
            }];
    }];
    
}

-(void)makeLabelFlyAway :(void (^)(void))flewAway {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat flyAwayTime = 0.4;
        __block CGFloat currentX = [self.messageLabel center].x;
        [UIView animateWithDuration:flyAwayTime animations:^{
            [self.messageLabel setCenter:CGPointMake(currentX - self.view.bounds.size.width, self.messageLabel.center.y)];
        } completion:^(BOOL finished){
            flewAway();
        }];
    });
}

-(void)makeLabelFlyIn:(NSString *)message {
    CGFloat flyInTime = 0.8;
    dispatch_async(dispatch_get_main_queue(), ^{
        __block CGFloat currentX = [self.messageLabel center].x;
        [[self messageLabel] setText:message];
        [self.messageLabel setCenter:CGPointMake(currentX + 2 * self.view.bounds.size.width, self.messageLabel.center.y)];
        currentX = [self.messageLabel center].x;
        [UIView animateWithDuration:flyInTime animations:^{
            [self.messageLabel setCenter:CGPointMake(currentX - self.view.bounds.size.width, self.messageLabel.center.y)];
        }];
    });
}

// Code to Capture Face Rectangle and other cool metadata stuff
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    BOOL faceFound = NO;
    for(AVMetadataObject *metadataObject in metadataObjects) {
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeFace]) {
            [self.faceRectangleLayer setHidden:NO];
            faceFound = YES;
            AVMetadataObject * face = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            CGFloat padding = 10.0;
            CGFloat halfPadding = padding/2;
            CGRect newFaceCircle = CGRectMake(face.bounds.origin.x - halfPadding, face.bounds.origin.y - halfPadding, face.bounds.size.width + padding, face.bounds.size.height + padding);
            self.faceRectangleLayer.frame = newFaceCircle;
            self.faceRectangleLayer.cornerRadius = 10.0;
        }
    }
    
    if(faceFound) {
        self.lookingIntoCamCounter += 1;
        self.lookingIntoCam = self.lookingIntoCamCounter > MAX_TIME_TO_WAIT_TILL_FACE_FOUND;
        if (!self.lookingIntoCam && !self.enrollmentStarted) {
            self.enrollmentStarted = YES;
            [self startEnrollmentProcess];
        }
    } else if (!self.enrollmentStarted){
        [self makeLabelFlyIn:[ResponseManager getMessage:@"LOOK_INTO_CAM"]];
        self.lookingIntoCam = NO;
        self.lookingIntoCamCounter = 0;
        [self.faceRectangleLayer setHidden:YES];
    } else {
        self.lookingIntoCam = NO;
        self.lookingIntoCamCounter = 0;
        [self.faceRectangleLayer setHidden:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
fromConnection:(AVCaptureConnection *)connection {
    
   if(self.isRecording && !self.enoughRecordingTimePassed && self.isReadyToWrite){
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // a very dense way to keep track of the time at which this frame
        // occurs relative to the output stream, but it's just an example!
        static int64_t frameNumber = 0;
        if(self.assetWriterInput.readyForMoreMediaData){
            
            if(self.pixelBufferAdaptor != nil){
                [self.pixelBufferAdaptor appendPixelBuffer:imageBuffer
                                      withPresentationTime:CMTimeMake(frameNumber, 25)];
                frameNumber++;
            }
        }
    }
    
    // Don't do any analysis when not looking into the camera
    if(!self.lookingIntoCam){
        return;
    }
    
}

-(void)showLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self makeLabelFlyAway:^{
            [self.progressView setHidden:NO];
        }];
    });
}

-(void)removeLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setHidden:YES];
    });
}

-(void)takeToFinishedView{
    NSLog(@"Take to finished view");
    dispatch_async(dispatch_get_main_queue(), ^{
        EnrollFinishViewController * enrollVC = [[Utilities getVoiceItStoryBoard] instantiateViewControllerWithIdentifier:@"enrollFinishedVC"];
        [[self navigationController] pushViewController:enrollVC animated: YES];
    });
}

@end
