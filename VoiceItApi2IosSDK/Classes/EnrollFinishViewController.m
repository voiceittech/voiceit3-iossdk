//
//  EnrollFinishViewController.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/4/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "EnrollFinishViewController.h"

@interface EnrollFinishViewController ()

@end

@implementation EnrollFinishViewController

- (IBAction)doneButtonClicked:(id)sender {
    [[self navigationController] dismissViewControllerAnimated:YES completion:^{
        [_myNavController userEnrollmentsPassed]();
    }];
    // TODO: Give Successful Enrollment Completion Notification/Callback Here
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _myNavController = (MainNavigationController*) [self navigationController];
    [self.navigationItem setHidesBackButton: YES];
    // Setup Cancel Button on top left of navigation controller
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
