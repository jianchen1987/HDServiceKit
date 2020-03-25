//
//  HDNetworkCache.h
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkDefine.h"
#import <Foundation/Foundation.h>

#if __has_include(<YYCache/YYCache.h>)
#import <YYCache/YYCache.h>
#else
#import "YYCache.h"
#endif

@class HDNetworkResponse;

NS_ASSUME_NONNULL_BEGIN

@interface HDNetworkCache : NSObject

/** 缓存存储模式 (默认不缓存) */
@property (nonatomic, assign) HDNetworkCacheWriteMode writeMode;

/** 缓存读取模式 (默认不读取) */
@property (nonatomic, assign) HDNetworkCacheReadMode readMode;

/** 缓存有效时长 (单位：秒，默认不限制) */
@property (nonatomic, assign) NSTimeInterval ageSeconds;

/** 缓存 key 额外的部分，默认是 app 版本号 */
@property (nonatomic, copy) NSString *extraCacheKey;

/** 根据请求成功数据判断是否需要写缓存 (保证仅在数据有效时返回 YES) */
@property (nonatomic, copy, nullable) BOOL (^shouldWriteCacheBlock)(HDNetworkResponse *response);

/** 根据读取到的缓存数据判断是否使用缓存 (保证仅在数据有效时返回 YES) */
@property (nonatomic, copy, nullable) BOOL (^shouldReadCacheBlock)(HDNetworkResponse *response);

/** 根据默认的缓存 key 自定义缓存 key */
@property (nonatomic, copy, nullable) NSString * (^customCacheKeyBlock)(NSString *defaultCacheKey);

/**
 获取磁盘缓存大小
 
 @return 缓存大小(单位 M)
 */
+ (NSInteger)getDiskCacheSize;

/**
 清除磁盘缓存
 */
+ (void)removeDiskCache;

/**
 清除内存缓存
 */
+ (void)removeMemeryCache;

/** 磁盘缓存对象 */
@property (nonatomic, class, readonly) YYDiskCache *diskCache;

/** 内存缓存对象 */
@property (nonatomic, class, readonly) YYMemoryCache *memoryCache;

@end

NS_ASSUME_NONNULL_END
