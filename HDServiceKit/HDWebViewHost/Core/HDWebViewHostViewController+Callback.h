//
//  HDWebViewHostViewController+Callback.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/13.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController.h"
#import "HDWebViewHostResponseCode.h"

typedef NS_ENUM(NSUInteger, HDWHCallbackType) {
    HDWHCallbackTypeSuccess = 0,  ///< 成功
    HDWHCallbackTypeCancel = 1,   ///< 取消
    HDWHCallbackTypeFail = 2,     ///< 失败
};

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewHostViewController (Callback)

/// 调用 callback 的函数，这个函数是 js 端调用方法时，注册在 js 端的 block
/// @param callbackKey 回调函数相关 key
/// @param actionName 调用的函数名
/// @param code 错误码
/// @param type 类型
/// @param params 参数
- (void)fireCallback:(NSString *)callbackKey actionName:(NSString *)actionName code:(HDWHRespCode)code type:(HDWHCallbackType)type params:(NSDictionary *__nullable)params;
@end

NS_ASSUME_NONNULL_END
