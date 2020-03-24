//
//  HDNetworkResponse+SuperApp.h
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import <HDServiceKit/HDServiceKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络响应错误类型
typedef NS_ENUM(NSInteger, HDResponseErrorType) {
    /// 未知
    HDResponseErrorTypeUnknown,
    /// 超时
    HDResponseErrorTypeTimedOut,
    /// 取消
    HDResponseErrorTypeCancelled,
    /// 无网络
    HDResponseErrorTypeNoNetwork,
    /// 服务器错误
    HDResponseErrorTypeServerError,
    /// session 过期
    HDResponseErrorTypeSessionExpired,
    /// 登录状态过期
    HDResponseErrorTypeLoginExpired
};

@interface HDNetworkResponse (SuperApp)

/// 请求失败类型 (使用该属性做业务处理足够)
@property (nonatomic, assign) HDResponseErrorType errorType;
@end

NS_ASSUME_NONNULL_END
