//
//  ResponseManager.h
//  VoiceItApi2IosSDK
//
//  Created by VoiceIt Technologies, LLC
//  Copyright (c) 2020 VoiceIt Technologies, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseManager : NSObject
+(NSString *)getMessage:(NSString*) name;
+(NSString *)getMessage:(NSString*) name variable:(NSString*)variable;
@end
