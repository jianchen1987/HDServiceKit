//
//  HDCacheUtility.h
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HDCacheUtilitySizeBlock)(void (^sizeBlock)(NSInteger size));

@interface HDCacheUtility : NSObject

/**
 注册应用缓存清理方式
 @param block 清理方法
 */
+ (void)registerCacheCleanBlock:(void (^)(void))block;

/**
 立即清理客户端缓存
 @param block 清理完成后回调
 */
+ (void)cleanWithCompleteBlock:(void (^)(void))block;

/**
 注册应用缓存大小的获取方式

 @param block sizeBlock返回特定组件的缓存大小
 */
+ (void)registerCacheSizeBlock:(HDCacheUtilitySizeBlock)block;

/**
 获取当前客户端可清理缓存的大小
 @param block totalSize单位为b
 */
+ (void)sizeWithBlock:(void (^)(NSInteger totalSize))block;

/**
 aes私有key，建议放在application:didFinishLaunchingWithOptions:内，不设置则使用默认值
 @param key 16位字符串
 */
+ (void)registerAESKey:(NSString *)key;

@end
