//
//  CameraViewController.h
//  VoiceItAPITwoDemoApp
//
//  Created by Armaan Bindra on 3/16/17.
//  Copyright © 2017 Armaan Bindra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSimpleCamera.h"

@interface CameraViewController : UIViewController
- (id)init:(void (^)(NSString *))callback;
@property (nonatomic, copy) void (^videoRecordingCompleted)(NSString * );
@end
