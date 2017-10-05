//
//  MainNavigationController.h
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/2/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"
#import "VoiceItAPITwo.h"

@interface MainNavigationController : UINavigationController
@property (nonatomic, strong) NSObject * myVoiceIt;
@property NSString * uniqueId;
@property NSString* contentLanguage;
@property NSString* voicePrintPhrase;
@property (nonatomic, copy) void (^userEnrollmentsCancelled)(void);
@property (nonatomic, copy) void (^userEnrollmentsPassed)(void);
@end
