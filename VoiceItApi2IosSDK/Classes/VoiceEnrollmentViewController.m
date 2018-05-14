//
//  VoiceEnrollmentViewController.m
//  VoiceItApi2IosSDK
//
//  Created by Armaan Bindra on 5/7/18.
//

#import "VoiceEnrollmentViewController.h"
#import "SCSiriWaveformView.h"

@interface VoiceEnrollmentViewController()
@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveformView;
@end

@implementation VoiceEnrollmentViewController

-(void)cancelClicked{
    [self setAudioSessionInactive];
    self.continueRunning = NO;
    [self.myVoiceIt deleteAllUserEnrollments:_userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
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
    self.thePhrase =  _myNavController.voicePrintPhrase;
    self.contentLanguage =  _myNavController.contentLanguage;
    self.userToEnrollUserId = _myNavController.uniqueId;
    
    // Setup Cancel Button on top left of navigation controller
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClicked)];
    leftBarButton.tintColor = [Utilities uiColorFromHexString:@"#FFFFFF"];
    [self.navigationItem setLeftBarButtonItem:leftBarButton];
    
    // Initialize Boolean and All
    self.enrollmentStarted = NO;
    self.continueRunning  = YES;
    self.enrollmentDoneCounter = 0;
    [self setNavigationTitle:self.enrollmentDoneCounter + 1];
    [self.messageLabel setText:@""];
    // Do any additional setup after loading the view.
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.waveformView setWaveColor:[Styles getMainUIColor]];
    [self.waveformView setPrimaryWaveLineWidth:4.0f];
    [self.waveformView setSecondaryWaveLineWidth:4.0f];
    [self.waveformView setFrequency:2.0f];
    [self.waveformView setIdleAmplitude:0.0f];
    [self.waveformView setBackgroundColor:[UIColor clearColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    self.originalMessageLeftConstraintContstant = self.messageleftConstraint.constant;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.enrollmentStarted = YES;
    [self startEnrollmentProcess];
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
    self.isRecording = YES;
    self.audioSession = [AVAudioSession sharedInstance];
    NSError *err;
    [self.audioSession setCategory:AVAudioSessionCategoryRecord error:&err];
    if (err)
    {
        NSLog(@"%@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
    }
    err = nil;
    
    self.audioPath = [Utilities pathForTemporaryFileWithSuffix:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:self.audioPath];
    
    err = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[Utilities getRecordingSettings] error:&err];
    if(!self.audioRecorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [self.audioRecorder setDelegate:self];
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder setMeteringEnabled:YES];
    [self.audioRecorder recordForDuration:4.8];
    
}

-(void)recordingStopped{
    self.isRecording = NO;
}

-(void)startEnrollmentProcess {
    [self.myVoiceIt getAllEnrollmentsForUser:self.userToEnrollUserId callback:^(NSString * getEnrollmentsJSONResponse){
        NSDictionary *getEnrollmentsJSONObj = [Utilities getJSONObject:getEnrollmentsJSONResponse];
        int enrollmentCount = [[getEnrollmentsJSONObj objectForKey: @"count"] intValue];
        NSLog(@"Voice Enrollment Count From Server is %d", enrollmentCount);
        [self.myVoiceIt deleteAllUserEnrollments:self.userToEnrollUserId callback:^(NSString * deleteEnrollmentsJSONResponse){
                NSLog(@"DELETING ENROLLMENTS IN THE BEGINNING %@",deleteEnrollmentsJSONResponse);
                [self startDelayedRecording:0.0];
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

-(void)viewWillDisappear:(BOOL)animated{
    [self setAudioSessionInactive];
    self.continueRunning = NO;
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

#pragma mark - AVAudioRecorderDelegate Methods

-(void)setAudioSessionInactive{
    [self.audioRecorder stop];
    NSError * err;
    [self.audioSession setActive:NO error:&err];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if(!self.continueRunning){
        return;
    }
    [self setAudioSessionInactive];
    [self recordingStopped];
    [self showLoading];
    [self.myVoiceIt createVoiceEnrollment:self.userToEnrollUserId contentLanguage:self.contentLanguage audioPath:self.audioPath callback:^(NSString * jsonResponse){
        [Utilities deleteFile:self.audioPath];
        [self removeLoading];
        NSLog(@"Voice Enrollment JSON Response : %@", jsonResponse);
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

- (void)updateMeters
{
    CGFloat normalizedValue;
    [self.audioRecorder updateMeters];
    normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.audioRecorder averagePowerForChannel:0]];
    [self.waveformView updateWithLevel:normalizedValue];
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}
@end
