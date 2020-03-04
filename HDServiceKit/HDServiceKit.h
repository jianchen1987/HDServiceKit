//
//  HDServiceKit.h
//  HDServiceKit
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2020 VanJay. All rights reserved.
//  This file is generated automatically.

#ifndef HDServiceKit_h
#define HDServiceKit_h

#import <UIKit/UIKit.h>

/// 版本号
static NSString * const HDServiceKit_VERSION = @"0.1.0";

#if __has_include("HDCache.h")
#import "HDCache.h"
#endif

#if __has_include("HDCacheStorage.h")
#import "HDCacheStorage.h"
#endif

#if __has_include("HDCacheUtility.h")
#import "HDCacheUtility.h"
#endif

#if __has_include("HDCacheStorageObject.h")
#import "HDCacheStorageObject.h"
#endif

#if __has_include("HDCacheManager.h")
#import "HDCacheManager.h"
#endif

#if __has_include("NSData+HDCache.h")
#import "NSData+HDCache.h"
#endif

#if __has_include("NSJSONSerialization+HDCache.h")
#import "NSJSONSerialization+HDCache.h"
#endif

#if __has_include("NSString+HDCache.h")
#import "NSString+HDCache.h"
#endif

#endif /* HDServiceKit_h */