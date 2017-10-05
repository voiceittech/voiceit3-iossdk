//
//  Utilities.m
//  TestingVoiceItAPI2iOSSDKCode
//
//  Created by Armaan Bindra on 10/2/17.
//  Copyright © 2017 VoiceIt Technologies LLC. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities
/* Utility Methods */
+(UIColor *)uiColorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(CGColorRef)cgColorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0].CGColor;
}

+(NSDictionary *)getJSONObject:(NSString *)jsonString {
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    return jsonObj;
}

+(BOOL)isStrSame:(NSString *)firstString secondString:(NSString *) secondString{
    return [[firstString lowercaseString] isEqualToString:[secondString lowercaseString]];
}

+(NSData *)imageFromVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetIG =
    [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetIG.appliesPreferredTrackTransform = YES;
    assetIG.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *igError = nil;
    thumbnailImageRef =
    [assetIG copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)
                    actualTime:NULL
                         error:&igError];
    
    if (!thumbnailImageRef){
        NSLog(@"thumbnailImageGenerationError %@", igError );
    }
    
    UIImage *image = thumbnailImageRef
    ? [[UIImage alloc] initWithCGImage:thumbnailImageRef]
    : nil;
    //    [Utilities savePhotoToPhotos:image];
    NSData *imageData = nil;
    if ( image != nil){
        imageData  = UIImageJPEGRepresentation(image, 0.5);
    }
    return imageData;
}

//+(void)savePhotoToPhotos:(UIImage *)thePhoto{
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        switch (status) {
//            case PHAuthorizationStatusAuthorized: {
//                NSLog(@"Auth Granted");
//                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//                    [PHAssetChangeRequest creationRequestForAssetFromImage:thePhoto];
//                } completionHandler: ^(BOOL success, NSError *error) {
//                    if (success) {
//                        NSLog(@"Success");
//                    }
//                    else {
//                        NSLog(@"write error : %@",error);
//                    }
//                }];
//                break;
//            }
//            case PHAuthorizationStatusRestricted:{
//                NSLog(@"Access Restricted");
//                break;
//            }
//            case PHAuthorizationStatusDenied:{
//                NSLog(@"Access Denied");
//                break;
//            }
//            default:{
//                break;
//            }
//        }
//    }];
//}
@end

