#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "EnrollFinishViewController.h"
#import "EnrollSetupViewController.h"
#import "EnrollViewController.h"
#import "MainNavigationController.h"
#import "ResponseManager.h"
#import "SpinningView.h"
#import "Utilities.h"
#import "VerificationViewController.h"
#import "VoiceItApi2IosSDK.h"
#import "VoiceItAPITwo.h"
#import "VoiceItLogo.h"

FOUNDATION_EXPORT double VoiceItApi2IosSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char VoiceItApi2IosSDKVersionString[];

