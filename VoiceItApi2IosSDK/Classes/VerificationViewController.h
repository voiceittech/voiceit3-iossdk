//
//  VerificationViewController.h
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/4/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SpinningView.h"
#import "Utilities.h"
#import "VoiceItAPITwo.h"
#import "ResponseManager.h"

@interface VerificationViewController : UIViewController <AVCaptureFileOutputRecordingDelegate,AVCaptureMetadataOutputObjectsDelegate,AVAudioRecorderDelegate>
#pragma mark - Audio Recording Stuff
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;
@property (nonatomic, strong) NSString *audioPath;
@property(nonatomic, strong) AVAudioSession *audioSession;

#pragma mark -  Graphics/UI/Constraints/Animations
@property CGFloat originalMessageLeftConstraintContstant;
@property (weak, nonatomic) IBOutlet UIView *verificationBox;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet SpinningView *progressView;
@property  CGPoint cameraCenterPoint;
@property CAShapeLayer * progressCircle;
@property CALayer * cameraBorderLayer;
@property CALayer * faceRectangleLayer;

#pragma mark -  Camera Related Stuff
@property  AVCaptureSession * captureSession;
//@property AVCapturePhotoOutput * photoOutput;
@property AVCaptureDevice * videoDevice;
@property AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSData *finalCapturedPhotoData;
@property AVCaptureMovieFileOutput *movieFileOutput;
@property NSDate *faceTimer;
@property (strong, nonatomic) NSMutableArray * faceTimes;

#pragma mark -  Boolean Switches
@property BOOL lookingIntoCam;
@property BOOL verificationStarted;
@property BOOL isRecording;
@property BOOL continueRunning;
//@property BOOL takePhoto;

#pragma mark -  Counters to keep track of stuff
@property int lookingIntoCamCounter;
@property int failCounter;

#pragma mark -  Developer Passed Options
@property (strong, nonatomic)  NSString * userToVerifyUserId;
@property (strong, nonatomic)  NSString * thePhrase;
@property (strong, nonatomic)  NSString * contentLanguage;
@property (strong, nonatomic)  NSObject * voiceItMaster;
#pragma mark - Miscellaneous
@property (strong, nonatomic) NSMutableArray* okResponseCodes;

#pragma mark - callbacks
@property (nonatomic, copy) void (^userVerificationCancelled)(void);
@property (nonatomic, copy) void (^userVerificationSuccessful)(float, float, NSString *);
@property (nonatomic, copy) void (^userVerificationFailed)(float, float, NSString *);
@end
