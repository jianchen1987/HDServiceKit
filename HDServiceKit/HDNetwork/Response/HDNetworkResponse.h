//
//  HDNetworkResponse.h
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkDefine.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 网络请求响应对象
 如果想拓展一些属性，使用 runtime 关联属性，然后重写预处理方法进行计算并赋值就行了。
 */
@interface HDNetworkResponse : NSObject

/// 请求成功数据
@property (nonatomic, strong, nullable) id responseObject;

/// 额外数据
@property (nonatomic, strong, nullable) id extraData;

/// 请求失败 NSError
@property (nonatomic, strong, readonly, nullable) NSError *error;

/// 请求任务
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *sessionTask;

/// sessionTask.response
@property (nonatomic, strong, readonly, nullable) NSHTTPURLResponse *URLResponse;

/// 便利构造
+ (instancetype)responseWithSessionTask:(nullable NSURLSessionTask *)sessionTask
                         responseObject:(nullable id)responseObject
                                  error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
