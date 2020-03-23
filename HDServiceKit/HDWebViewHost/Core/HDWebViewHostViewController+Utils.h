//
//  HDServiceKitViewController+Utils.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 支持的方法列表 key
UIKIT_EXTERN NSString *const kHDWHSupportMethodListKey;
/// app 信息 key
UIKIT_EXTERN NSString *const kHDWHAppInfoKey;

@interface HDWebViewHostViewController (Utils)

/// 当前支持的所有的方法和设备信息
- (NSDictionary *)supportMethodListAndAppInfo;

/// 提示
/// @param text 文字
- (void)showTextTip:(NSString *)text;

/// 提示
/// @param text 文字
/// @param delay 多久隐藏
- (void)showTextTip:(NSString *)text hideAfterDelay:(CGFloat)delay;

/// 记录当前 url 当前滚动位置，缓存
- (void)dealWithViewHistory;

/// 退出界面
- (void)popOutImmediately;

/// 是否需要外部浏览器打开
/// @param url 地址
- (BOOL)isExternalSchemeRequest:(NSString *)url;

/// 是否 itunes 相关请求
/// @param url 地址
- (BOOL)isItmsAppsRequest:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
