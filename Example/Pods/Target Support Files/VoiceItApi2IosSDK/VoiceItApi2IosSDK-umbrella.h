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
#import "VideoEnrollmentViewController.h"
#import "FaceEnrollmentViewController.h"
#import "FaceVerificationViewController.h"
#import "Liveness.h"
#import "MainNavigationController.h"
#import "NSMutableArray+Shuffle.h"
#import "ResponseManager.h"
#import "SCSiriWaveformView.h"
#import "SpinningView.h"
#import "Styles.h"
#import "Utilities.h"
#import "VideoVerificationViewController.h"
#import "VoiceEnrollmentViewController.h"
#import "VoiceItApi2IosSDK.h"
#import "VoiceItAPITwo.h"
#import "VoiceItLogo.h"
#import "VoiceVerificationViewController.h"

FOUNDATION_EXPORT double VoiceItApi2IosSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char VoiceItApi2IosSDKVersionString[];

