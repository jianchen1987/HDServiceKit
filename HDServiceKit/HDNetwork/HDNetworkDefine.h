//
//  HDNetworkDefine.h
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#ifndef HDNetworkDefine_h
#define HDNetworkDefine_h

// clang-format off
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif
// clang-format on

#define HDNETWORK_QUEUE_ASYNC(queue, block)                                                                     \
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) { \
        block();                                                                                                \
    } else {                                                                                                    \
        dispatch_async(queue, block);                                                                           \
    }

#define HDNETWORK_MAIN_QUEUE_ASYNC(block) HDNETWORK_QUEUE_ASYNC(dispatch_get_main_queue(), block)

NS_ASSUME_NONNULL_BEGIN

/// 请求类型
typedef NS_ENUM(NSInteger, HDRequestMethod) {
    HDRequestMethodGET,
    HDRequestMethodPOST,
    HDRequestMethodDELETE,
    HDRequestMethodPUT,
    HDRequestMethodHEAD,
    HDRequestMethodPATCH
};

/// 缓存存储模式
typedef NS_OPTIONS(NSUInteger, HDNetworkCacheWriteMode) {
    /// 无缓存
    HDNetworkCacheWriteModeNone = 0,
    /// 内存缓存
    HDNetworkCacheWriteModeMemory = 1 << 0,
    /// 磁盘缓存
    HDNetworkCacheWriteModeDisk = 1 << 1,
    HDNetworkCacheWriteModeMemoryAndDisk = HDNetworkCacheWriteModeMemory | HDNetworkCacheWriteModeDisk
};

/// 缓存读取模式
typedef NS_ENUM(NSInteger, HDNetworkCacheReadMode) {
    /// 不读取缓存
    HDNetworkCacheReadModeNone,
    /// 缓存命中后仍然发起网络请求
    HDNetworkCacheReadModeAlsoNetwork,
    /// 缓存命中后不发起网络请求
    HDNetworkCacheReadModeCancelNetwork,
};

/// 网络请求释放策略
typedef NS_ENUM(NSInteger, HDNetworkReleaseStrategy) {
    /// 网络任务会持有 HDNetworkRequest 实例，网络任务完成 HDNetworkRequest 实例才会释放
    HDNetworkReleaseStrategyHoldRequest,
    /// 网络请求将随着 HDNetworkRequest 实例的释放而取消
    HDNetworkReleaseStrategyWhenRequestDealloc,
    /// 网络请求和 HDNetworkRequest 实例无关联
    HDNetworkReleaseStrategyNotCareRequest
};

/// 重复网络请求处理策略
typedef NS_ENUM(NSInteger, HDNetworkRepeatStrategy) {
    /// 允许重复网络请求
    HDNetworkRepeatStrategyAllAllowed,
    /// 取消最旧的网络请求
    HDNetworkRepeatStrategyCancelOldest,
    /// 取消最新的网络请求
    HDNetworkRepeatStrategyCancelNewest
};

/// 网络请求回调重定向类型
typedef NS_ENUM(NSInteger, HDRequestRedirection) {
    /// 重定向为成功
    HDRequestRedirectionSuccess,
    /// 重定向为失败
    HDRequestRedirectionFailure,
    /// 停止后续操作（主要是停止回调）
    HDRequestRedirectionStop
};

@class HDNetworkRequest;
@class HDNetworkResponse;

/// 进度闭包
typedef void (^HDRequestProgressBlock)(NSProgress *progress);

/// 缓存命中闭包
typedef void (^HDRequestCacheBlock)(HDNetworkResponse *response);

/// 请求成功闭包
typedef void (^HDRequestSuccessBlock)(HDNetworkResponse *response);

/// 请求失败闭包
typedef void (^HDRequestFailureBlock)(HDNetworkResponse *response);

/// 网络请求响应代理
@protocol HDResponseDelegate <NSObject>
@optional

/// 上传进度
- (void)request:(__kindof HDNetworkRequest *)request uploadProgress:(NSProgress *)progress;

/// 下载进度
- (void)request:(__kindof HDNetworkRequest *)request downloadProgress:(NSProgress *)progress;

/// 缓存命中
- (void)request:(__kindof HDNetworkRequest *)request cacheWithResponse:(HDNetworkResponse *)response;

/// 请求成功
- (void)request:(__kindof HDNetworkRequest *)request successWithResponse:(HDNetworkResponse *)response;

/// 请求失败
- (void)request:(__kindof HDNetworkRequest *)request failureWithResponse:(HDNetworkResponse *)response;

@end

NS_ASSUME_NONNULL_END

#endif /* HDNetworkDefine_h */
