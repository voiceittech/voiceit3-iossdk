//
//  EnrollSetupViewController.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/2/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "EnrollSetupViewController.h"

@interface EnrollSetupViewController ()
@property BOOL cameraPermissionGranted;
@property BOOL microphonePermissionGranted;
@end

@implementation EnrollSetupViewController

- (IBAction)continueClicked:(id)sender {
    if(self.myNavController.enrollmentType == video){
        [self checkMicrophonePermission];
        [self checkCameraPermission];
        NSLog(@"Microphone = %d, Camera = %d", self.microphonePermissionGranted, self.cameraPermissionGranted);
        if(self.cameraPermissionGranted && self.microphonePermissionGranted){
            [self launchEnrollmentProcess];
        } else {
            [self requestCameraAccess:^{
                [self requestMicAccess:^{
                    if(self.cameraPermissionGranted && self.microphonePermissionGranted){
                        [self launchEnrollmentProcess];
                    }
                }];
            }];
        }
    }
    
    if(self.myNavController.enrollmentType == face){
        [self checkCameraPermission];
        if(self.cameraPermissionGranted){
            [self launchEnrollmentProcess];
        } else {
            [self requestCameraAccess:^{
                if(self.cameraPermissionGranted){
                        [self launchEnrollmentProcess];
                    }
            }];
        }
    }
    
    if(self.myNavController.enrollmentType == voice){
        [self checkMicrophonePermission];
        if(self.microphonePermissionGranted){
            [self launchEnrollmentProcess];
        } else {
            [self requestMicAccess:^{
                if(self.microphonePermissionGranted){
                    [self launchEnrollmentProcess];
                }
            }];
        }
    }
}

-(void)launchEnrollmentProcess {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.myNavController.enrollmentType == face){
            FaceEnrollmentViewController * enrollVC = [[Utilities getVoiceItStoryBoard] instantiateViewControllerWithIdentifier:@"faceEnrollVC"];
            [[self navigationController] pushViewController:enrollVC animated: YES];
        }
        else if(self.myNavController.enrollmentType == voice){
            VoiceEnrollmentViewController * enrollVC = [[Utilities getVoiceItStoryBoard] instantiateViewControllerWithIdentifier:@"voiceEnrollVC"];
            [[self navigationController] pushViewController:enrollVC animated: YES];
        } else if(self.myNavController.enrollmentType == video){
            EnrollViewController * enrollVC = [[Utilities getVoiceItStoryBoard] instantiateViewControllerWithIdentifier:@"enrollVC"];
            [[self navigationController] pushViewController:enrollVC animated: YES];
        }
    });
}

-(void)requestCameraAccess :(void (^)(void))completionBlock {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
        if(granted){
            self.cameraPermissionGranted = YES;
        } else {
            self.cameraPermissionGranted = NO;
        }
        completionBlock();
    }];
}

-(void)requestMicAccess :(void (^)(void))completionBlock {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
        if(granted){
            self.microphonePermissionGranted = YES;
        } else {
            self.microphonePermissionGranted = NO;
        }
        completionBlock();
    }];
}

- (IBAction)cancelClicked:(id)sender {
    [[self navigationController] dismissViewControllerAnimated:YES completion: ^{
        [[self myNavController] userEnrollmentsCancelled]();
    }];
    
}

-(void)checkMicrophonePermission {
    switch ([[AVAudioSession sharedInstance] recordPermission]) {
        case AVAudioSessionRecordPermissionGranted:
            self.microphonePermissionGranted = YES;
            break;
        case AVAudioSessionRecordPermissionDenied:
            self.microphonePermissionGranted = NO;
            break;
        case AVAudioSessionRecordPermissionUndetermined:
            self.microphonePermissionGranted = NO;
            break;
        default:
            break;
    }
}

-(void)checkCameraPermission {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            self.cameraPermissionGranted = YES;
            break;
        case AVAuthorizationStatusDenied:
            self.cameraPermissionGranted = NO;
            break;
        case AVAuthorizationStatusRestricted:
            self.cameraPermissionGranted = NO;
            break;
        case  AVAuthorizationStatusNotDetermined:
            self.cameraPermissionGranted = NO;
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.myNavController = (MainNavigationController*) [self navigationController];
    self.continueButton.layer.cornerRadius = 10.0;
    [self.continueButton setBackgroundColor:[Styles getMainUIColor]];
    
    if(self.myNavController.enrollmentType == face){
        [self.enrollmentSetupTitleLabel setText:@"Set Up Face Verification"];
        [self.enrollmentSetupSubtitleLabel setText:@"This lets you log in by verifying your face"];
    }
    
    if(self.myNavController.enrollmentType == voice){
        [self.enrollmentSetupTitleLabel setText:@"Set Up Voice Verification"];
        [self.enrollmentSetupSubtitleLabel setText:@"This lets you log in by verifying your voice"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

