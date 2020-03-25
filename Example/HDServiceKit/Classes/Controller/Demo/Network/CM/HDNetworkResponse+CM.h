//
//  HDNetworkResponse+CM.h
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import <HDServiceKit/HDServiceKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 网络响应错误类型
typedef NS_ENUM(NSInteger, CMResponseErrorType) {
    /// 未知
    CMResponseErrorTypeUnknown,
    /// 超时
    CMResponseErrorTypeTimedOut,
    /// 取消
    CMResponseErrorTypeCancelled,
    /// 无网络
    CMResponseErrorTypeNoNetwork,
    /// 服务器错误
    CMResponseErrorTypeServerError,
    /// 业务数据不正确，错误
    CMResponseErrorTypeBussinessDataError,
    /// session 过期
    CMResponseErrorTypeSessionExpired,
    /// 登录状态过期
    CMResponseErrorTypeLoginExpired
};

@interface HDNetworkResponse (CM)

/// 请求失败类型 (使用该属性做业务处理足够)
@property (nonatomic, assign) CMResponseErrorType errorType;
@end

NS_ASSUME_NONNULL_END
