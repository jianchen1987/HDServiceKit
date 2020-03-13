//
//  MKWebViewScrollPositionManager.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2017 smilly.co All rights reserved.
//

#import "HDWHWebViewScrollPositionManager.h"

/**
 保持页面的当前滚动位置
 */
static NSMutableDictionary *positionHolder = nil;

@implementation HDWHWebViewScrollPositionManager

+ (instancetype)sharedInstance {
    static HDWHWebViewScrollPositionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        positionHolder = [NSMutableDictionary dictionaryWithCapacity:10];
    });

    return _sharedManager;
}

- (void)cacheURL:(NSURL *)url position:(CGFloat)y {
    //    记录2个网站的位置，达到 quote，清空
    if (positionHolder.allKeys.count > 2) {
        [positionHolder removeAllObjects];
    }
    if (url) {
        [positionHolder setObject:@(y) forKey:url];
    }
}

- (CGFloat)positionForCacheURL:(NSURL *)url {
    CGFloat y = 0;
    if (url) {
        y = [[positionHolder objectForKey:url] floatValue];
    }
    return y;
}

- (void)emptyURLCache:(NSURL *)url {
    [positionHolder removeObjectForKey:url];
}

- (void)clearAllCache {
    [positionHolder removeAllObjects];
}

@end
