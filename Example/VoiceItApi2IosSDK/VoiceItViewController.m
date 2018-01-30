//
//  VoiceItViewController.m
//  VoiceItApi2IosSDK
//
//  Created by armaanbindra on 03/23/2017.
//  Copyright (c) 2017 armaanbindra. All rights reserved.
//

#import "VoiceItViewController.h"
#import "VoiceItAPITwo.h"
@interface VoiceItViewController ()
@end

@implementation VoiceItViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableDictionary * styles = [[NSMutableDictionary alloc] init];
    [styles setObject:@"#FF0000" forKey:@"kThemeColor"];
    [styles setObject:@"default" forKey:@"kIconStyle"];
    _myVoiceIt  = [[VoiceItAPITwo alloc] init:self apiKey:@"API_KEY_HERE" apiToken:@"API_TOKEN_HERE" styles:styles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//usr_7f94221e4db24595bb085647ba6819f6
- (IBAction)startEnrollmentClicked:(id)sender {
    [_myVoiceIt encapsulatedVideoEnrollUser:@"USER_ID_HERE" contentLanguage:@"CONTENT_LANGUAGE_HERE" voicePrintPhrase:@"my face and voice identify me" userEnrollmentsCancelled:^{
        NSLog(@"User Enrollments Cancelled");
    } userEnrollmentsPassed:^{
        NSLog(@"User Enrollments Completed");
    }];
}

- (IBAction)verifyClicked:(id)sender {
    [_myVoiceIt encapsulatedVideoVerification:@"USER_ID_HERE" contentLanguage:@"CONTENT_LANGUAGE_HERE" voicePrintPhrase:@"my face and voice identify me" userVerificationCancelled:^{
         NSLog(@"User Verication Cancelled");
    } userVerificationSuccessful:^(float faceConfidence ,float voiceConfidence, NSString * jsonResponse){
        NSLog(@"User Verication Successful voiceConfidence : %g , faceConfidence : %g",voiceConfidence, faceConfidence);
    } userVerificationFailed:^(float faceConfidence ,float voiceConfidence, NSString * jsonResponse){
        NSLog(@"User Verication Failed voiceConfidence : %g , faceConfidence : %g",voiceConfidence, faceConfidence);
    }];
}

@end
