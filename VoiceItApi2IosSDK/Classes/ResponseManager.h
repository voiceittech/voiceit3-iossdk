//
//  ResponseManager.h
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/3/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseManager : NSObject
+(NSString *)getMessage:(NSString*) name;
+(NSString *)getMessage:(NSString*) name variable:(NSString*)variable;
@end
