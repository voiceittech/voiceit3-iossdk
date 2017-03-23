//
//  VoiceItViewController.m
//  VoiceItApi2IosSDK
//
//  Created by armaanbindra on 03/23/2017.
//  Copyright (c) 2017 armaanbindra. All rights reserved.
//

#import "VoiceItViewController.h"


NSString * const API_KEY = @"key_4306d632525748ac987cc0385ceff339";
NSString * const API_TOKEN = @"tok_c910f4047d1d425980c856bb3ca8fa5b";

@interface VoiceItViewController ()

@end

@implementation VoiceItViewController

- (IBAction)recordNow:(id)sender {
//    [_myVoiceIt createAudioEnrollment:@"usr_e3482389fbb84f07bf9abee278d7ae96" contentLanguage:@"en-US" callback:^(NSString * result){
//        NSLog(@"Enrollment done and result is &%@",result);
//    }];
//    
    [_myVoiceIt createVideoEnrollment:@"usr_e3482389fbb84f07bf9abee278d7ae96" contentLanguage:@"en-US" callback:^(NSString * result){
        NSLog(@"Enrollment done and result is &%@",result);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _myVoiceIt = [[VoiceItAPITwo alloc] init:self apiKey:API_KEY apiToken:API_TOKEN];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
