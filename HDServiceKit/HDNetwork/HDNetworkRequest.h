//
//  HDNetworkRequest.h
//  HDServiceKit
//
//  Created by VanJay on 03/23/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkCache.h"
#import "HDNetworkResponse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDNetworkRequest : NSObject

#pragma - 网络请求数据

/** 请求方法类型 */
@property (nonatomic, assign) HDRequestMethod requestMethod;

/** 请求访问路径 (例如：/detail/list) */
@property (nonatomic, copy) NSString *requestURI;

/** 请求参数 */
@property (nonatomic, copy, nullable) NSDictionary *requestParameter;

/** 请求超时时间 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/** 请求上传文件包 */
@property (nonatomic, copy, nullable) void (^requestConstructingBody)(id<AFMultipartFormData> formData);

/** 下载路径 */
@property (nonatomic, copy) NSString *downloadPath;

#pragma - 发起网络请求

/** 发起网络请求 */
- (void)start;

/** 发起网络请求带回调 */
- (void)startWithSuccess:(nullable HDRequestSuccessBlock)success
                 failure:(nullable HDRequestFailureBlock)failure;

- (void)startWithCache:(nullable HDRequestCacheBlock)cache
               success:(nullable HDRequestSuccessBlock)success
               failure:(nullable HDRequestFailureBlock)failure;

- (void)startWithUploadProgress:(nullable HDRequestProgressBlock)uploadProgress
               downloadProgress:(nullable HDRequestProgressBlock)downloadProgress
                          cache:(nullable HDRequestCacheBlock)cache
                        success:(nullable HDRequestSuccessBlock)success
                        failure:(nullable HDRequestFailureBlock)failure;

/** 取消网络请求 */
- (void)cancel;

#pragma - 相关回调代理

/** 请求结果回调代理 */
@property (nonatomic, weak) id<HDResponseDelegate> delegate;

#pragma - 缓存

/** 缓存处理器 */
@property (nonatomic, strong, readonly) HDNetworkCache *cacheHandler;

#pragma - 其它

/** 网络请求释放策略 (默认 HDNetworkReleaseStrategyHoldRequest) */
@property (nonatomic, assign) HDNetworkReleaseStrategy releaseStrategy;

/** 重复网络请求处理策略 (默认 HDNetworkRepeatStrategyAllAllowed) */
@property (nonatomic, assign) HDNetworkRepeatStrategy repeatStrategy;

/** 是否正在网络请求 */
- (BOOL)isExecuting;

/** 请求标识，可以查看完整的请求路径和参数 */
- (NSString *)requestIdentifier;

/** 清空所有请求回调闭包 */
- (void)clearRequestBlocks;

#pragma - 网络请求公共配置(以子类化方式实现 \
                           : 针对不同的接口团队设计不同的公共配置)

/**
 事务管理器 (通常情况下不需设置) 。注意：
 1、其 requestSerializer 和 responseSerializer 属性会被下面两个同名属性覆盖。
 2、其 completionQueue 属性会被框架内部覆盖。
 */
@property (nonatomic, strong, nullable) AFHTTPSessionManager *sessionManager;

/** 请求序列化器 */
@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;

/** 响应序列化器 */
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;

/** 服务器地址及公共路径 (例如：https://www.baidu.com) */
@property (nonatomic, copy) NSString *baseURI;

@end

/// 预处理请求数据 (重写分类方法)，拦截器
@interface HDNetworkRequest (RequestInterceptor)

/** 预处理请求参数, 返回处理后的请求参数 */
- (nullable NSDictionary *)hd_preprocessParameter:(nullable NSDictionary *)parameter;

/** 预处理拼接后的完整 URL 字符串, 返回处理后的 URL 字符串 */
- (NSString *)hd_preprocessURLString:(NSString *)URLString;

@end

/// 预处理响应数据 (重写分类方法)，拦截器
@interface HDNetworkRequest (ResponseInterceptor)

/**
 网络请求回调重定向，方法在子线程回调，并会再下面几个预处理方法之前调用。
 需要特别注意 HDRequestRedirectionStop 会停止后续操作，如果业务使用闭包回调，这个闭包不会被清空，可能会造成循环引用，所以这种场景务必保证回调被正确处理，一般有以下两种方式：
 1、Stop 过后执行特定逻辑，然后重新 start 发起网络请求，之前的回调闭包就能继续正常处理了。
 2、直接调用 clearRequestBlocks 清空回调闭包。
 */
- (void)hd_redirection:(void (^)(HDRequestRedirection))redirection response:(HDNetworkResponse *)response;

/** 预处理请求成功数据 (子线程执行, 若数据来自缓存在主线程执行) */
- (void)hd_preprocessSuccessInChildThreadWithResponse:(HDNetworkResponse *)response;

/** 预处理请求成功数据 */
- (void)hd_preprocessSuccessInMainThreadWithResponse:(HDNetworkResponse *)response;

/** 预处理请求失败数据 (子线程执行) */
- (void)hd_preprocessFailureInChildThreadWithResponse:(HDNetworkResponse *)response;

/** 预处理请求失败数据 */
- (void)hd_preprocessFailureInMainThreadWithResponse:(HDNetworkResponse *)response;

@end

NS_ASSUME_NONNULL_END
