//
//  MKWebViewScrollPositionManager.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2017 smilly.co All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HDWHWebViewScrollPositionManager : NSObject

+ (instancetype)sharedInstance;

- (void)cacheURL:(NSURL *)url position:(CGFloat)lastPosition;

- (CGFloat)positionForCacheURL:(NSURL *)url;

- (void)emptyURLCache:(NSURL *)url;

/**
 清除所有对象
 */
- (void)clearAllCache;
@end
