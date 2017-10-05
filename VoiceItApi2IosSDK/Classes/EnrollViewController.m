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
       [_captureSession stopRunning];
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
    [self.navigationItem setHidesBackButton: YES];
    _myNavController = (MainNavigationController*) [self navigationController];
    _myVoiceIt = (VoiceItAPITwo *) _myNavController.myVoiceIt;
    //TODO: Make all these come dynamically when triggering enrollment process
    _thePhrase =  _myNavController.voicePrintPhrase;
    _contentLanguage =  _myNavController.contentLanguage;
    _userToEnrollUserId = _myNavController.uniqueId;
    // Setup Cancel Button on top left of navigation controller
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked)];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];

    // Initialize Boolean and All
    _lookingIntoCam = NO;
    _enrollmentStarted = NO;
//    _takePhoto = YES;
    _lookingIntoCamCounter = 0;
    _enrollmentDoneCounter = 0;
    [self setNavigationTitle:_enrollmentDoneCounter + 1];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupCaptureSession];
    [self setupCameraCircle];
    _originalMessageLeftConstraintContstant = _messageleftConstraint.constant;
}

-(void)setupCaptureSession{
    // Setup Video Input Device
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession beginConfiguration];
    [_captureSession setSessionPreset: AVCaptureSessionPresetHigh];
    _videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    NSError * videoError;
    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice: _videoDevice error:&videoError];
    [_captureSession addInput:videoInput];
}

-(void)setupCameraCircle{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: _captureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

//    // Setup Photo Settings, take live photo
//    _photoOutput = [[AVCapturePhotoOutput alloc]  init];
//    [_photoOutput setHighResolutionCaptureEnabled: YES];
//    [_photoOutput setLivePhotoCaptureEnabled: YES];
//    [_photoOutput setLivePhotoCaptureSuspended:NO];
//    [_captureSession addOutput: _photoOutput];

    // Setup Movie File Output
    //ADD MOVIE FILE OUTPUT
    _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    Float64 TotalSeconds = 10;            //Total seconds
    int32_t preferredTimeScale = 30;    //Frames per second
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    _movieFileOutput.maxRecordedDuration = maxDuration;
    _movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    [_captureSession addOutput:_movieFileOutput];

    //SET THE CONNECTION PROPERTIES (output properties)
    [self setupCameraOutputProperties];  //(We call a method as it also has to be done after changing camera)

    // Setup code to capture face meta data
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [_captureSession addOutput: metadataOutput];
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

    _cameraBorderLayer = [[CALayer alloc] init];
    _progressCircle = [CAShapeLayer layer];
    [_cameraBorderLayer setFrame:CGRectMake(backgroundViewX, backgroundViewY, backgroundWidthHeight, backgroundWidthHeight)];
    [_previewLayer setFrame:CGRectMake(cameraViewX, cameraViewY, cameraViewWidthHeight, cameraViewWidthHeight)];
    [_previewLayer setCornerRadius: cameraViewWidthHeight / 2];
   _cameraCenterPoint = CGPointMake(_cameraBorderLayer.frame.origin.x + (backgroundWidthHeight/2), _cameraBorderLayer.frame.origin.y + (backgroundWidthHeight/2) );

    if ([_videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        CGPoint autofocusPoint = _cameraCenterPoint;
        [_videoDevice setFocusPointOfInterest:autofocusPoint];
        [_videoDevice setFocusMode:AVCaptureFocusModeLocked];
    }

    // Setup Progress Circle
    _progressCircle .path = [UIBezierPath bezierPathWithArcCenter: _cameraCenterPoint radius:(backgroundWidthHeight / 2) startAngle:-M_PI_2 endAngle:2 * M_PI - M_PI_2 clockwise:YES].CGPath;
    _progressCircle.fillColor = [UIColor clearColor].CGColor;
    _progressCircle.strokeColor = [UIColor clearColor].CGColor;
    _progressCircle.lineWidth = circleWidth + 8.0;
    [_cameraBorderLayer setBackgroundColor: [UIColor clearColor].CGColor];
    _cameraBorderLayer.cornerRadius = backgroundWidthHeight / 2;

    // Setup Rectangle Around Face
    _faceRectangleLayer = [[CALayer alloc] init];
    _faceRectangleLayer.zPosition = 1;
    _faceRectangleLayer.borderColor = [Utilities cgColorFromHexString:@"#FBC132"];
    _faceRectangleLayer.borderWidth  = 4.0;
    _faceRectangleLayer.opacity = 0.7;
    [_faceRectangleLayer setHidden:YES];

    [rootLayer addSublayer:_cameraBorderLayer];
    [rootLayer addSublayer:_progressCircle];
    [rootLayer addSublayer:_previewLayer];
    [_previewLayer addSublayer:_faceRectangleLayer];
    [_captureSession commitConfiguration];
    [_captureSession startRunning];
}

-(void)animateProgressCircle {
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressCircle.strokeColor = [Utilities cgColorFromHexString:@"#FBC132"];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 5;
        animation.removedOnCompletion = YES;//NO;
        animation.fromValue = @(0);
        animation.toValue = @(1);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [_progressCircle addAnimation:animation forKey:@"drawCircleAnimation"];
    });

}

-(void)startDelayedRecording:(NSTimeInterval)delayTime{
    NSLog(@"Starting Delayed RECORDING with delayTime %f ", delayTime);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
         [self animateLabel:[ResponseManager getMessage:[[NSString alloc] initWithFormat:@"ENROLL_%d", _enrollmentDoneCounter] variable:_thePhrase]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self startRecording];
        });
    });
}

    -(void)startRecording {
        NSLog(@"Starting RECORDING");
        _isRecording = YES;
//        _takePhoto = YES;
        _cameraBorderLayer.backgroundColor = [UIColor clearColor].CGColor;
        // Initialize Face Variables
        _faceTimes = [[NSMutableArray alloc] init];
        _faceTimer = [NSDate date];

        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *err;
        [audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
        if (err)
        {
            NSLog(@"%@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        }
        err = nil;
        if (err)
        {
            NSLog(@"%@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        }

        NSDictionary *recordSettings = [[NSDictionary alloc]
                                        initWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                        [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey, nil];

        // Unique recording URL
        NSString *fileName = @"OriginalFile"; // Changed it So It Keeps Replacing File
        _audioPath = [NSTemporaryDirectory()
                              stringByAppendingPathComponent:[NSString
                                                              stringWithFormat:@"%@.wav", fileName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_audioPath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_audioPath
                                                       error:nil];
        }

        NSURL *url = [NSURL fileURLWithPath:_audioPath];
        err = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&err];
        if(!_audioRecorder){
            NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
            return;
        }
        [_audioRecorder setDelegate:self];
        [_audioRecorder prepareToRecord];
        [_audioRecorder recordForDuration:4.8];

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
    [_movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

-(void)stopSavingToMovieFile{
      [_movieFileOutput stopRecording];
}

    -(void)recordingStopped{
        _isRecording = NO;
        _faceTimer = nil;
        _progressCircle.strokeColor = [UIColor clearColor].CGColor;
    }

    - (void) setupCameraOutputProperties
    {
        //SET THE CONNECTION PROPERTIES (output properties)
        AVCaptureConnection *CaptureConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
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
                [_faceRectangleLayer setHidden:NO];
                faceFound = YES;
                AVMetadataObject * face = [_previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
                CGFloat padding = 10.0;
                CGFloat halfPadding = padding/2;
                CGRect newFaceCircle = CGRectMake(face.bounds.origin.x - halfPadding, face.bounds.origin.y - halfPadding, face.bounds.size.width + padding, face.bounds.size.height + padding);
                _faceRectangleLayer.frame = newFaceCircle;
                _faceRectangleLayer.cornerRadius = 10.0;
            }
        }

        if(faceFound && _isRecording){
            NSTimeInterval timeInterval = [_faceTimer timeIntervalSinceNow];
            [_faceTimes addObject: [NSNumber numberWithDouble:timeInterval]];
        }

//        if(faceFound && _isRecording && _takePhoto){
//            NSTimeInterval timeInterval = [_faceTimer timeIntervalSinceNow];
//            [_faceTimes addObject: [NSNumber numberWithDouble:timeInterval]];
//            AVCapturePhotoSettings * photoSettings = [[AVCapturePhotoSettings alloc] init];
//            [photoSettings setAutoStillImageStabilizationEnabled:YES];
//            [photoSettings setHighResolutionPhotoEnabled:YES];
//            [_photoOutput capturePhotoWithSettings:photoSettings delegate:self];
//            _takePhoto  = NO;
//        }

        if(faceFound) {
            if (_lookingIntoCamCounter > MAX_TIME_TO_WAIT_TILL_FACE_FOUND && !_lookingIntoCam && !_enrollmentStarted) {
                _lookingIntoCam = YES;
                _enrollmentStarted = YES;
                [self startEnrollmentProcess];
            }
            _lookingIntoCamCounter += 1;
        } else if (!_enrollmentStarted){
            [self animateLabel: [ResponseManager getMessage:@"LOOK_INTO_CAM"]];
            _lookingIntoCam = NO;
             _lookingIntoCamCounter = 0;
            [_faceRectangleLayer setHidden:YES];
        } else {
            _lookingIntoCam = NO;
            _lookingIntoCamCounter = 0;
            [_faceRectangleLayer setHidden:YES];
        }
    }

//-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
//    // Did finish processing photo save it to photo data
//    NSData * photoData = [photo fileDataRepresentation];
//    _finalCapturedPhotoData = photoData;
//    NSLog(@"STILL PHOTO WITH FACE CAPTURED AND SAVED");
//}

-(void)startEnrollmentProcess {
    [_myVoiceIt getAllEnrollmentsForUser:_userToEnrollUserId callback:^(NSString * getEnrollmentsJSONResponse){
        NSDictionary *getEnrollmentsJSONObj = [Utilities getJSONObject:getEnrollmentsJSONResponse];
        int enrollmentCount = [[getEnrollmentsJSONObj objectForKey: @"count"] intValue];
        NSLog(@"Enrollment Count From Server is %d", enrollmentCount);
        if(enrollmentCount == 0){
            [self animateLabel: [ResponseManager getMessage:@"GET_ENROLLED"]];
            [self startDelayedRecording:2.0];
        } else {
            [_myVoiceIt deleteAllUserEnrollments:_userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
                [self animateLabel: [ResponseManager getMessage:@"GET_ENROLLED"]];
                [self startDelayedRecording:2.0];
            }];
        }
    }];

}

-(void)animateLabel:(NSString *)message {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[self messageLabel] setText:message];
        [_messageLabel setHidden:YES];
        _originalMessageLeftConstraintContstant = _messageleftConstraint.constant;
        _messageleftConstraint.constant = -1000;
        [_messageLabel setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            //Change your constraints from code.
            _messageleftConstraint.constant = _originalMessageLeftConstraintContstant;
            [self.view layoutIfNeeded];
        }];
    });
}

-(void)viewWillDisappear:(BOOL)animated{
    [_captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
    [_progressView setHidden:NO];
    [_progressView startAnimation];
    [self animateLabel:@""];
    });
}

-(void)removeLoading{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_progressView endAnimation];
        [_progressView setHidden:YES];
    });
}

- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    NSNumber * faceFoundNumber = [_faceTimes objectAtIndex:0];
    NSTimeInterval faceFoundTime = [faceFoundNumber doubleValue];
    _finalCapturedPhotoData = [Utilities imageFromVideo:outputFileURL atTime:faceFoundTime];
}

#pragma mark - AVAudioRecorderDelegate Methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"AUDIO RECORDED FINISHED SUCCESS = %d", flag);
    [self recordingStopped];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"Setting Category Error:%@", err.localizedDescription);
    }

    [audioSession setActive:NO error:&err];

    if([_faceTimes count] > 0){
        [self showLoading];
        [_myVoiceIt createVideoEnrollment:_userToEnrollUserId contentLanguage: _contentLanguage imageData:_finalCapturedPhotoData audioPath:_audioPath callback:^(NSString * jsonResponse){
            NSLog(@"Video Enrollment JSON Response : %@", jsonResponse);
            NSDictionary *jsonObj = [Utilities getJSONObject:jsonResponse];
            NSLog(@"Response Code is %@ and message is : %@", [jsonObj objectForKey:@"responseCode"], [jsonObj objectForKey:@"message"]);
            NSString * responseCode = [jsonObj objectForKey:@"responseCode"];

            [self removeLoading];
            if([responseCode isEqualToString:@"SUCC"]){
                NSString * enrollmentId =  [jsonObj objectForKey:@"id"];
                NSString * enrollmentText = [jsonObj objectForKey:@"text"];
                if([Utilities isStrSame:enrollmentText secondString:_thePhrase]){
                    _enrollmentDoneCounter += 1;
                    [self setNavigationTitle:_enrollmentDoneCounter + 1];
                    if( _enrollmentDoneCounter < 3){
                        [self startDelayedRecording:1];
                    } else {
                           [self takeToFinishedView];
                    }
                } else {
                    //If Successfully did enrollment with wrong phrase, then extract enrollmentId and delete this wrong enrollment
                    [_myVoiceIt deleteEnrollmentForUser:_userToEnrollUserId enrollmentId:enrollmentId callback:^(NSString * deleteEnrollmentJsonResponse){
                        [self startDelayedRecording:2.5];
                        [self animateLabel:[ResponseManager getMessage: @"STTF" variable:_thePhrase]];
                    }];
                }
            } else {
                [self startDelayedRecording:3.0];
                if([Utilities isStrSame:responseCode secondString:@"STTF"]){
                    [self animateLabel:[ResponseManager getMessage: responseCode variable:_thePhrase]];
                } else {
                    [self animateLabel:[ResponseManager getMessage:responseCode]];
                }
            }
        }];

    } else {
        [self startDelayedRecording:3.0];
        [self animateLabel: [ResponseManager getMessage:@"FNFD"]];
    }

}

-(void)takeToFinishedView{
        NSLog(@"Take to finished view");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSBundle * podBundle = [NSBundle bundleForClass: self.classForCoder];
            NSURL * bundleURL = [[podBundle resourceURL] URLByAppendingPathComponent:@"VoiceItApi2IosSDK.bundle"];
            NSBundle  * bundle = [[NSBundle alloc] initWithURL:bundleURL];
            UIStoryboard *voiceItStoryboard = [UIStoryboard storyboardWithName:@"VoiceIt" bundle: bundle];
            EnrollFinishViewController * enrollVC = [voiceItStoryboard instantiateViewControllerWithIdentifier:@"enrollFinishedVC"];
            [[self navigationController] pushViewController:enrollVC animated: YES];
        });
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"fail because %@", error.localizedDescription);
}

@end
