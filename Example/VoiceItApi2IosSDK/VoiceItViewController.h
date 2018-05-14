//
//  VoiceItViewController.h
//  VoiceItApi2IosSDK
//
//  Created by armaanbindra on 03/23/2017.
//  Copyright (c) 2017 armaanbindra. All rights reserved.
//

@import UIKit;
#import "VoiceItAPITwo.h"

@interface VoiceItViewController : UIViewController
@property VoiceItAPITwo * myVoiceIt;
@property (weak, nonatomic) IBOutlet UISwitch *livenessToggle;
@property NSString * API_KEY;
@property NSString * API_TOKEN;
@property NSString * TEST_USER_ID;
@property NSString * TEST_PHRASE;
@property NSString * TEST_CONTENT_LANGUAGE;
@end
