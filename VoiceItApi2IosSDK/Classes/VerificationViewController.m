//
//  VerificationViewController.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/4/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "VerificationViewController.h"

@interface VerificationViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation VerificationViewController
VoiceItAPITwo * myVoiceIt;
int TIME_TO_WAIT_TILL_FACE_FOUND = 30;


- (IBAction)cancelClicked:(id)sender {
    [_captureSession stopRunning];
    _captureSession = nil;
    [ _audioRecorder stop];
    [self stopSavingToMovieFile];
    [self dismissViewControllerAnimated:YES completion:^{
        [self userVerificationCancelled]();
    }];
}

-(void)setMessage:(NSString *) newMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageLabel setText: newMessage];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _okResponseCodes = [[NSMutableArray alloc] initWithObjects:@"SRNR",@"NEHSD", @"FNFD",  nil];
    myVoiceIt = (VoiceItAPITwo *) [self voiceItMaster];
    // Initialize Boolean and All
    _lookingIntoCam = NO;
    _verificationStarted  = NO;
    _lookingIntoCamCounter = 0;
    _failCounter = 0;
    // Do any additional setup after loading the view.
    
    [_progressView setHidden:YES];
}

-(void)setBottomCornersForCancelButton{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_cancelButton.bounds byRoundingCorners:( UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0, 10.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _cancelButton.bounds;
    maskLayer.path  = maskPath.CGPath;
    _cancelButton.layer.mask = maskLayer;
}

-(void)viewWillAppear:(BOOL)animated{
    // Setup Awesome Transparent Background and radius for Verification Box
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:blurEffectView atIndex:0];
    } else {
        [[self view] setBackgroundColor:[UIColor colorWithRed:0.58 green:0.65 blue:0.65 alpha:0.6]];
    }
    [[_verificationBox layer] setCornerRadius:10.0];
    [self setBottomCornersForCancelButton];

    [self setup_captureSession];
    [self setupCameraCircle];
    [_messageLabel setText: [ResponseManager getMessage:@"LOOK_INTO_CAM"]];
}

-(void)setup_captureSession{
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
    [self setupCameraOutputProperties];            //(We call a method as it also has to be done after changing camera)
    
    // Setup code to capture face meta data
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [_captureSession addOutput: metadataOutput];
    // We're only interested in faces
    [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeFace]];
    // This VC is the delegate. Please call us on the main queue
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Setup Little Camera Circle and Positions
    CALayer *rootLayer = [[self verificationBox] layer];
    CGFloat backgroundWidthHeight = (CGFloat) [self verificationBox].frame.size.height  * 0.50;
    CGFloat cameraViewWidthHeight = (CGFloat) [self verificationBox].frame.size.height  * 0.48;
    CGFloat circleWidth = (backgroundWidthHeight - cameraViewWidthHeight) / 2;
    CGFloat backgroundViewX = ([self verificationBox].frame.size.width - backgroundWidthHeight)/2;
    CGFloat cameraViewX = ([self verificationBox].frame.size.width - cameraViewWidthHeight)/2;
    CGFloat backgroundViewY = 30.0; // TODO: Make this number a constant
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
        [self setMessage:[ResponseManager getMessage:@"VERIFY" variable:_thePhrase]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self startRecording];
        });
    });
}

-(void)startRecording {
    NSLog(@"Starting RECORDING");
    _isRecording = YES;
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
                                    [NSNumber numberWithFloat:11025.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithInt:8], AVLinearPCMBitDepthKey,
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
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"verificationMovie.mov"];
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
            _faceRectangleLayer.frame = face.bounds;
            _faceRectangleLayer.cornerRadius = 10.0;
        }
    }
    
    if(faceFound && _isRecording){
        NSTimeInterval timeInterval = [_faceTimer timeIntervalSinceNow];
        [_faceTimes addObject: [NSNumber numberWithDouble:timeInterval]];
    }
    
    if(faceFound) {
        if (_lookingIntoCamCounter >TIME_TO_WAIT_TILL_FACE_FOUND && !_lookingIntoCam && !_verificationStarted) {
            _lookingIntoCam = YES;
            _verificationStarted = YES;
            [self startVerificationProcess];
        }
        _lookingIntoCamCounter += 1;
    } else if (!_verificationStarted){
        [self setMessage: [ResponseManager getMessage:@"LOOK_INTO_CAM"]];
        _lookingIntoCam = NO;
        _lookingIntoCamCounter = 0;
        [_faceRectangleLayer setHidden:YES];
    } else {
        _lookingIntoCam = NO;
        _lookingIntoCamCounter = 0;
        [_faceRectangleLayer setHidden:YES];
    }
}

-(void)startVerificationProcess {
    [self setMessage: [ResponseManager getMessage:@"GET_VERIFIED"]];
    [self startDelayedRecording:2.0];
}

-(void)viewWillDisappear:(BOOL)animated{
    [_captureSession stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    if([_faceTimes count] > 0){
        NSNumber * faceFoundNumber = [_faceTimes objectAtIndex:0];
        NSTimeInterval faceFoundTime = [faceFoundNumber doubleValue];
        _finalCapturedPhotoData = [Utilities imageFromVideo:outputFileURL atTime:faceFoundTime];
    }
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
        [myVoiceIt videoVerification:_userToVerifyUserId contentLanguage: _contentLanguage imageData:_finalCapturedPhotoData audioPath:_audioPath callback:^(NSString * jsonResponse){
            [self removeLoading];
            NSLog(@"Video Verification JSON Response : %@", jsonResponse);
            NSDictionary *jsonObj = [Utilities getJSONObject:jsonResponse];
            NSLog(@"Response Code is %@ and message is : %@", [jsonObj objectForKey:@"responseCode"], [jsonObj objectForKey:@"message"]);
            NSString * responseCode = [jsonObj objectForKey:@"responseCode"];
            
            if([responseCode isEqualToString:@"SUCC"]){
                [self setMessage:[ResponseManager getMessage:@"SUCCESS"]];
                float faceConfidence = [[jsonObj objectForKey:@"faceConfidence"] floatValue];
                float voiceConfidence = [[jsonObj objectForKey:@"voiceConfidence"] floatValue];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated: YES completion:^{
                        [self userVerificationSuccessful](faceConfidence, voiceConfidence, jsonResponse);
                    }];
                });
            } else {
                if(![_okResponseCodes containsObject:responseCode]){
                    _failCounter += 1;
                }
                
                if(_failCounter < 3){
                    if([responseCode isEqualToString:@"STTF"]){
                        [self setMessage:[ResponseManager getMessage: responseCode variable:_thePhrase]];
                        [self startDelayedRecording:3.0];
                    }
                    else if ([responseCode isEqualToString:@"TVER"]){
                        [self setMessage:[ResponseManager getMessage: responseCode]];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated: YES completion:^{
                                 [self userVerificationFailed](0.0, 0.0, jsonResponse);
                            }];
                        });
                    }else{
                        [self setMessage:[ResponseManager getMessage: responseCode]];
                        [self startDelayedRecording:3.0];
                    }
                } else {
                    [self setMessage:[ResponseManager getMessage: @"TOO_MANY_ATTEMPTS"]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        float faceConfidence = [[jsonObj objectForKey:@"faceConfidence"] floatValue];
                        float voiceConfidence = [[jsonObj objectForKey:@"voiceConfidence"] floatValue];
                        [self dismissViewControllerAnimated: YES completion:^{
                            [self userVerificationFailed](faceConfidence, voiceConfidence, jsonResponse);
                        }];
                    });
                }
            }
        }];
        
    } else {
        [self startDelayedRecording:3.0];
        [self setMessage: [ResponseManager getMessage:@"FNFD"]];    }
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"fail because %@", error.localizedDescription);
}

-(void)showLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView setHidden:NO];
        [_progressView startAnimation];
        [self setMessage:@""];
    });
}

-(void)removeLoading{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_progressView endAnimation];
        [_progressView setHidden:YES];
    });
}

@end
