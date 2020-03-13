//
//  HDPodAsset.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDPodAsset : NSObject
+ (NSString *)pathForFilename:(NSString *)filename pod:(NSString *)podName;
+ (NSData *)dataForFilename:(NSString *)filename pod:(NSString *)podName;
+ (NSString *)stringForFilename:(NSString *)filename pod:(NSString *)podName;
+ (NSString *)bundlePathForPod:(NSString *)podName;
+ (NSBundle *)bundleForPod:(NSString *)podName;
+ (NSArray *)assetsInPod:(NSString *)podName;
@end
