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
    [self checkMicrophonePermission];
    [self checkCameraPermission];
    NSLog(@"Microphone = %d, Camera = %d", _microphonePermissionGranted, _cameraPermissionGranted);
    if(_cameraPermissionGranted && _microphonePermissionGranted){
        [self launchEnrollmentProcess];
    } else {
        [self requestCameraAccess:^{
            [self requestMicAccess:^{
                if(_cameraPermissionGranted && _microphonePermissionGranted){
                    [self launchEnrollmentProcess];
                }
            }];
            }];
    }
}

-(void)launchEnrollmentProcess {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle * podBundle = [NSBundle bundleForClass: self.classForCoder];
        NSURL * bundleURL = [[podBundle resourceURL] URLByAppendingPathComponent:@"VoiceItApi2IosSDK.bundle"];
        NSBundle  * bundle = [[NSBundle alloc] initWithURL:bundleURL];
        UIStoryboard *voiceItStoryboard = [UIStoryboard storyboardWithName:@"VoiceIt" bundle: bundle];
        EnrollViewController * enrollVC = [voiceItStoryboard instantiateViewControllerWithIdentifier:@"enrollVC"];
        [[self navigationController] pushViewController:enrollVC animated: YES];
    });
}

-(void)requestCameraAccess :(void (^)(void))completionBlock {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
        if(granted){
            _cameraPermissionGranted = YES;
        } else {
            _cameraPermissionGranted = NO;
        }
        completionBlock();
    }];
}

-(void)requestMicAccess :(void (^)(void))completionBlock {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
        if(granted){
            _microphonePermissionGranted = YES;
        } else {
            _microphonePermissionGranted = NO;
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
            _microphonePermissionGranted = YES;
            break;
        case AVAudioSessionRecordPermissionDenied:
            _microphonePermissionGranted = NO;
            break;
        case AVAudioSessionRecordPermissionUndetermined:
            _microphonePermissionGranted = NO;
            break;
        default:
            break;
    }
}

-(void)checkCameraPermission {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
            _cameraPermissionGranted = YES;
            break;
        case AVAuthorizationStatusDenied:
           _cameraPermissionGranted = NO;
            break;
        case AVAuthorizationStatusRestricted:
            _cameraPermissionGranted = NO;
            break;
        case  AVAuthorizationStatusNotDetermined:
           _cameraPermissionGranted = NO;
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _myNavController = (MainNavigationController*) [self navigationController];
    self.continueButton.layer.cornerRadius = 10.0;
    // Do any additional setup after loading the view.
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
