//
//  EnrollSetupViewController.h
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/2/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "SpinningView.h"
#import "EnrollViewController.h"
#import "Utilities.h"
#import <AVFoundation/AVFoundation.h>
#import "MainNavigationController.h"

@interface EnrollSetupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic)  MainNavigationController * myNavController;
@end
