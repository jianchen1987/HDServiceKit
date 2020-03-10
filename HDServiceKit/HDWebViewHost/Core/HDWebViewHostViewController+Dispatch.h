//
//  HDWebviewHostViewController+Dispatch.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewHostViewController (Dispatch)

/// 核心的h5调用native接口的分发器
/// @param action 方法名
/// @param paramDict 参数
/// @return 是否已经被处理
- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict;

/// 核心的h5调用native接口的分发器
/// @param action 方法名
/// @param paramDict 参数
/// @param callbackKey 回调 key
/// @return 是否已经被处理
- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict callbackKey:(NSString * _Nullable)callbackKey;

#pragma mark - like private

- (void)dispatchParsingParameter:(NSDictionary *)contentJSON;

@end

NS_ASSUME_NONNULL_END
