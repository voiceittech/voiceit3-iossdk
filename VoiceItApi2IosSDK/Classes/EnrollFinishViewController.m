//
//  EnrollFinishViewController.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/4/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "EnrollFinishViewController.h"
#import "Styles.h"
@interface EnrollFinishViewController ()
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation EnrollFinishViewController

- (IBAction)doneButtonClicked:(id)sender {
    [[self navigationController] dismissViewControllerAnimated:YES completion:^{
        [self.myNavController userEnrollmentsPassed]();
    }];
    // TODO: Give Successful Enrollment Completion Notification/Callback Here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.doneButton setBackgroundColor:[Styles getMainUIColor]];
    self.myNavController = (MainNavigationController*) [self navigationController];
    [self.navigationItem setHidesBackButton: YES];
    self.doneButton.layer.cornerRadius = 10.0;
    // Setup Cancel Button on top left of navigation controller
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
