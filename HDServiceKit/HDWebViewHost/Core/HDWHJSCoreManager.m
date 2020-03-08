//
//  HDWHJSCoreManager.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHJSCoreManager.h"
#import "HDWHUtil.h"

@implementation HDWHJSCoreManager

+ (instancetype)defaultManager {
    static HDWHJSCoreManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [HDWHJSCoreManager new];
    });

    return _instance;
}

@end
