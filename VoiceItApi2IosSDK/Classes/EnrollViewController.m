//
//  EnrollViewController.m
//  Pods-VoiceItApi2IosSDK_Example
//
//  Created by Armaan Bindra on 10/1/17.
//

#import "EnrollViewController.h"
@interface EnrollViewController ()
@end

@implementation EnrollViewController
// TODO: Figure out where to put this
int MAX_TIME_TO_WAIT_TILL_FACE_FOUND = 40;


-(void)cancelClicked{
    [self stopSavingToMovieFile];
    [self setAudioSessionInactive];
    [self.captureSession stopRunning];
    self.captureSession = nil;
    self.continueRunning = NO;
    [_myVoiceIt deleteAllUserEnrollments:_userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
        [[self navigationController] dismissViewControllerAnimated:YES completion:^{
            [[self myNavController] userEnrollmentsCancelled];
        }];
    }];
}

-(void)setNavigationTitle:(int) enrollNumber {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * newTitle = [[NSString alloc] initWithFormat:@"%d of 3", enrollNumber];
        [[self navigationItem] setTitle: newTitle];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageLabel.textColor  = [Utilities uiColorFromHexString:@"#FFFFFF"];
    [self.navigationItem setHidesBackButton: YES];
    self.myNavController = (MainNavigationController*) [self navigationController];
    self.myVoiceIt = (VoiceItAPITwo *) _myNavController.myVoiceIt;
    //TODO: Make all these come dynamically when triggering enrollment process
    self.thePhrase =  _myNavController.voicePrintPhrase;
    self.contentLanguage =  _myNavController.contentLanguage;
    self.userToEnrollUserId = _myNavController.uniqueId;
    // Setup Cancel Button on top left of navigation controller
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
    leftBarButton.tintColor = [Utilities uiColorFromHexString:@"#FFFFFF"];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    
    // Initialize Boolean and All
    self.lookingIntoCam = NO;
    self.enrollmentStarted = NO;
    self.continueRunning  = YES;
    //    self.takePhoto = YES;
    self.lookingIntoCamCounter = 0;
    self.enrollmentDoneCounter = 0;
    [self setNavigationTitle:self.enrollmentDoneCounter + 1];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupCaptureSession];
    [self setupCameraCircle];
    // TODO: Trying to Keep Animation Going and Showing and Hiding Instead.
    //    [self.progressView startAnimation];
    self.originalMessageLeftConstraintContstant = self.messageleftConstraint.constant;
}

-(void)setupCaptureSession{
    // Setup Video Input Device
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    [self.captureSession setSessionPreset: AVCaptureSessionPresetHigh];
    self.videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    NSError * videoError;
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: self.videoDevice error:&videoError];
    [self.captureSession addInput:videoInput];
}

-(void)setupCameraCircle{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //    // Setup Photo Settings, take live photo
    //    self.photoOutput = [[AVCapturePhotoOutput alloc]  init];
    //    [self.photoOutput setHighResolutionCaptureEnabled: YES];
    //    [self.photoOutput setLivePhotoCaptureEnabled: YES];
    //    [self.photoOutput setLivePhotoCaptureSuspended:NO];
    //    [self.captureSession addOutput: self.photoOutput];
    
    // Setup Movie File Output
    //ADD MOVIE FILE OUTPUT
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    Float64 TotalSeconds = 10;            //Total seconds
    int32_t preferredTimeScale = 30;    //Frames per second
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    self.movieFileOutput.maxRecordedDuration = maxDuration;
    self.movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    [self.captureSession addOutput:self.movieFileOutput];
    
    //SET THE CONNECTION PROPERTIES (output properties)
    [self setupCameraOutputProperties];  //(We call a method as it also has to be done after changing camera)
    
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
    CGFloat backgroundViewY = 100.0; // TODO: Make this number a constant
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
    self.progressCircle.lineWidth = circleWidth + 8.0;
    [self.cameraBorderLayer setBackgroundColor: [UIColor clearColor].CGColor];
    self.cameraBorderLayer.cornerRadius = backgroundWidthHeight / 2;
    
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
        animation.duration = 5;
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
            [self makeLabelFlyIn:[ResponseManager getMessage:[[NSString alloc] initWithFormat:@"ENROLL_%d", self.enrollmentDoneCounter] variable:self.thePhrase]];
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
    _isRecording = YES;
    //        _takePhoto = YES;
    self.cameraBorderLayer.backgroundColor = [UIColor clearColor].CGColor;
    // Initialize Face Variables
    self.faceTimes = [[NSMutableArray alloc] init];
    self.faceTimer = [NSDate date];
    
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [self.audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    if (err)
    {
        NSLog(@"%@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    err = nil;
    
    // Unique recording URL
    NSString *fileName = @"OriginalFile"; // Changed it So It Keeps Replacing File
    self.audioPath = [NSTemporaryDirectory()
                  stringByAppendingPathComponent:[NSString
                                                  stringWithFormat:@"%@.wav", fileName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.audioPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.audioPath
                                                   error:nil];
    }
    
    NSURL *url = [NSURL fileURLWithPath:self.audioPath];
    err = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[Utilities getRecordingSettings] error:&err];
    if(!self.audioRecorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [self.audioRecorder setDelegate:self];
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder recordForDuration:4.8];
    
    // Start Capturing Video Data
    [self startSavingToMovieFile];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self stopSavingToMovieFile];
    });
    
    // Start Progress Circle Around Face Animation
    [self animateProgressCircle];
}

-(void)startSavingToMovieFile{
    //Create temporary URL to record to
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"enrollmentMovie.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
        {
            //Error - handle if requried
        }
    }
    //Start recording
    [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

-(void)stopSavingToMovieFile{
    [self.movieFileOutput stopRecording];
}

-(void)recordingStopped{
    self.isRecording = NO;
    self.faceTimer = nil;
    self.progressCircle.strokeColor = [UIColor clearColor].CGColor;
}

- (void) setupCameraOutputProperties
{
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection *CaptureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    //Set landscape (if required)
    if ([CaptureConnection isVideoOrientationSupported])
    {
        [CaptureConnection setVideoOrientation: AVCaptureVideoOrientationPortrait];
    }
    [CaptureConnection preferredVideoStabilizationMode];
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
    
    if(faceFound && self.isRecording){
        NSTimeInterval timeInterval = [self.faceTimer timeIntervalSinceNow];
        [self.faceTimes addObject: [NSNumber numberWithDouble:timeInterval]];
    }
    
    //        if(faceFound && self.isRecording && self.takePhoto){
    //            NSTimeInterval timeInterval = [self.faceTimer timeIntervalSinceNow];
    //            [self.faceTimes addObject: [NSNumber numberWithDouble:timeInterval]];
    //            AVCapturePhotoSettings * photoSettings = [[AVCapturePhotoSettings alloc] init];
    //            [photoSettings setAutoStillImageStabilizationEnabled:YES];
    //            [photoSettings setHighResolutionPhotoEnabled:YES];
    //            [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
    //            self.takePhoto  = NO;
    //        }
    
    if(faceFound) {
        if (self.lookingIntoCamCounter > MAX_TIME_TO_WAIT_TILL_FACE_FOUND && !self.lookingIntoCam && !self.enrollmentStarted) {
            self.lookingIntoCam = YES;
            self.enrollmentStarted = YES;
            [self startEnrollmentProcess];
        }
        self.lookingIntoCamCounter += 1;
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

//-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
//    // Did finish processing photo save it to photo data
//    NSData * photoData = [photo fileDataRepresentation];
//    self.finalCapturedPhotoData = photoData;
//    NSLog(@"STILL PHOTO WITH FACE CAPTURED AND SAVED");
//}

-(void)startEnrollmentProcess {
    [self.myVoiceIt getAllEnrollmentsForUser:self.userToEnrollUserId callback:^(NSString * getEnrollmentsJSONResponse){
        NSDictionary *getEnrollmentsJSONObj = [Utilities getJSONObject:getEnrollmentsJSONResponse];
        int enrollmentCount = [[getEnrollmentsJSONObj objectForKey: @"count"] intValue];
        NSLog(@"Enrollment Count From Server is %d", enrollmentCount);
        if(enrollmentCount == 0){
            [self makeLabelFlyIn: [ResponseManager getMessage:@"GET_ENROLLED"]];
            [self startDelayedRecording:2.0];
        } else {
            [self.myVoiceIt deleteAllUserEnrollments:self.userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
                [self makeLabelFlyIn: [ResponseManager getMessage:@"GET_ENROLLED"]];
                [self startDelayedRecording:2.0];
            }];
        }
    }];
    
}

-(void)makeLabelFlyAway :(void (^)(void))flewAway {
    // TODO: Trying out New Label Animation Code
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
    // TODO: Trying out New Label Animation Code
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

//-(void)animateLabel:(NSString *)message {
//    // TODO: Trying out New Label Animation Code
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CGFloat flyAwayTime = 0.4;
//        CGFloat flyInTime = 0.8;
//        __block CGFloat currentX = [self.messageLabel center].x;
//        [UIView animateWithDuration:flyAwayTime animations:^{
//            [self.messageLabel setCenter:CGPointMake(currentX - self.view.bounds.size.width, self.messageLabel.center.y)];
//        } completion:^(BOOL finished){
//            currentX = [self.messageLabel center].x;
//            [[self messageLabel] setText:message];
//            [self.messageLabel setCenter:CGPointMake(currentX + 2 * self.view.bounds.size.width, self.messageLabel.center.y)];
//            currentX = [self.messageLabel center].x;
//            [UIView animateWithDuration:flyInTime animations:^{
//                [self.messageLabel setCenter:CGPointMake(currentX - self.view.bounds.size.width, self.messageLabel.center.y)];
//            }];
//        }];
//    });
//}

-(void)viewWillDisappear:(BOOL)animated{
    [_captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    if ([self.faceTimes count] > 0) {
        NSNumber * faceFoundNumber = [self.faceTimes objectAtIndex:0];
        NSTimeInterval faceFoundTime = [faceFoundNumber doubleValue];
        self.finalCapturedPhotoData = [Utilities imageFromVideo:outputFileURL atTime:faceFoundTime];
    }
}

#pragma mark - AVAudioRecorderDelegate Methods

-(void)setAudioSessionInactive{
    [self.audioRecorder stop];
    NSError * err;
    [self.audioSession setActive:NO error:&err];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"AUDIO RECORDED FINISHED SUCCESS = %d", flag);
    [self setAudioSessionInactive];
    [self recordingStopped];
    if([self.faceTimes count] > 0){
        [self showLoading];
        [self.myVoiceIt createVideoEnrollment:self.userToEnrollUserId contentLanguage: self.contentLanguage imageData:self.finalCapturedPhotoData audioPath:self.audioPath callback:^(NSString * jsonResponse){
            [self removeLoading];
            NSLog(@"Video Enrollment JSON Response : %@", jsonResponse);
            NSDictionary *jsonObj = [Utilities getJSONObject:jsonResponse];
            NSLog(@"Response Code is %@ and message is : %@", [jsonObj objectForKey:@"responseCode"], [jsonObj objectForKey:@"message"]);
            NSString * responseCode = [jsonObj objectForKey:@"responseCode"];
            if([responseCode isEqualToString:@"SUCC"]){
                NSString * enrollmentId =  [jsonObj objectForKey:@"id"];
                NSString * enrollmentText = [jsonObj objectForKey:@"text"];
                if([Utilities isStrSame:enrollmentText secondString:self.thePhrase]){
                    self.enrollmentDoneCounter += 1;
                    if( self.enrollmentDoneCounter < 3){
                        [self setNavigationTitle:self.enrollmentDoneCounter + 1];
                        [self startDelayedRecording:1];
                    } else {
                        [self takeToFinishedView];
                    }
                } else {
                    //If Successfully did enrollment with wrong phrase, then extract enrollmentId and delete this wrong enrollment
                    [self.myVoiceIt deleteEnrollmentForUser:self.userToEnrollUserId enrollmentId:enrollmentId callback:^(NSString * deleteEnrollmentJsonResponse){
                        [self startDelayedRecording:2.5];
                        [self makeLabelFlyIn:[ResponseManager getMessage: @"STTF" variable:self.thePhrase]];
                    }];
                }
            } else {
                [self startDelayedRecording:3.0];
                if([Utilities isStrSame:responseCode secondString:@"STTF"]){
                    [self makeLabelFlyIn:[ResponseManager getMessage: responseCode variable:self.thePhrase]];
                } else {
                    [self makeLabelFlyIn:[ResponseManager getMessage:responseCode]];
                }
            }
        }];
        
    } else {
        [self startDelayedRecording:3.0];
        [self makeLabelFlyIn: [ResponseManager getMessage:@"FNFD"]];
    }
    
}

-(void)takeToFinishedView{
    NSLog(@"Take to finished view");
    dispatch_async(dispatch_get_main_queue(), ^{
        EnrollFinishViewController * enrollVC = [[Utilities getVoiceItStoryBoard] instantiateViewControllerWithIdentifier:@"enrollFinishedVC"];
        [[self navigationController] pushViewController:enrollVC animated: YES];
    });
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"fail because %@", error.localizedDescription);
}
@end
