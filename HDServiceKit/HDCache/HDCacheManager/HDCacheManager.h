//
//  HDCacheManager.h
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheStorage.h"
#import <Foundation/Foundation.h>

extern NSString *const kHDCacheManagerObjectKey;                 // 固定返回Dictionary格式的数据
extern NSString *const kHDCacheManagerSetObjectNotification;     // 触发存数据
extern NSString *const kHDCacheManagerGetObjectNotification;     // 触发取数据
extern NSString *const kHDCacheManagerRemoveObjectNotification;  // 触发移除缓存

@interface HDCacheManager : NSObject

/**
 空间，nameSpace以.document结尾则数据保存至Document
 */
@property (nonatomic, strong) NSString *nameSpace;

/**
 isInDocumentDir 是否在 Document 目录，否则在 Cache 目录
 */
@property (nonatomic, assign) BOOL isInDocumentDir;

/**
 默认缓存管理器，Cache 目录下
 */
+ (HDCacheManager *)defaultManager;

/**
 在 Cache 目录创建缓存管理器

 @param nameSpace 空间
 */
+ (instancetype)cacheManagerWithNameSpace:(NSString *)nameSpace;

/**
 在 Cache 目录创建缓存管理器
 
 @param nameSpace 空间
 */
- (instancetype)initWithNameSpace:(NSString *)nameSpace;

/**
 创建缓存管理器

 @param nameSpace 空间
 @param isInDocumentDir 是否在 Document 目录，否则在 Cache 目录
 */
+ (instancetype)cacheManagerWithNameSpace:(NSString *)nameSpace isInDocumentDir:(BOOL)isInDocumentDir;

/**
 创建缓存管理器
 
 @param nameSpace 空间
 @param isInDocumentDir 是否在 Document 目录，否则在 Cache 目录
 */
- (instancetype)initWithNameSpace:(NSString *)nameSpace isInDocumentDir:(BOOL)isInDocumentDir;

/**
 根据Key缓存对象到磁盘，默认duration为0：对象一直存在，清理后失效，object为nil则removeObject

 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 */
- (void)setObject:(id)aObject forKey:(NSString *)aKey;

/**
 存储的对象的存在时间，duration默认为0，传-1，表示永久存在，不可被清理，只能手动移除或覆盖移除

 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 @param duration 存储时间，单位:秒
 */
- (void)setObject:(id)aObject forKey:(NSString *)aKey duration:(NSTimeInterval)duration;

/**
 存储对象，toDisk设为NO则存到内存，也不进行 Encode 操作，获取数据内存地址相同

 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 @param toDisk 是否缓存到磁盘，是：归档  否：内存
 */
- (void)setObject:(id)aObject forKey:(NSString *)aKey toDisk:(BOOL)toDisk;

/**
 存储对象到 keyChain

 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 */
- (void)setObjectTokeyChain:(id)aObject forKey:(NSString *)aKey;

/**
 存储对象到偏好设置
 
 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 */
- (void)setObjectToAppUserDefaults:(id)aObject forKey:(NSString *)aKey;

/**
 根据Key获取对象，toDisk参数为NO的优先级最高

 @param aKey 唯一的对应的值
 */
- (id)objectForKey:(NSString *)aKey;

/**
 根据Key移除缓存对象，duration为负数的永久缓存可通过此方法清除

 @param aKey 唯一的对应的值
 */
- (void)removeObjectForKey:(NSString *)aKey;

/**
 异步移除所有duration为0的缓存，不处理 keyChain 和偏好设置存储
 folderSize单位是字节，转换M需要folderSize/(1024.0*1024.0)

 @param completionBlock 完成回调
 */
- (void)removeObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock;

/**
 异步检查缓存(duration大于0)的生命，删除过期缓存，可在App启动使用，不处理 keyChain 和偏好设置存储
 */
- (void)removeExpireObjects;

/**
 不区分空间，对所有数据进行删除，谨慎操作，不处理 keyChain 和偏好设置存储

 @param completionBlock 完成回调
 */
+ (void)removeObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock;

/**
 不区分空间，对所有缓存进行检查，删除过期缓存，谨慎操作，不处理 keyChain 和偏好设置存储
 */
+ (void)removeExpireObjects;

/** 清除内存缓存 */
- (void)clearMemory;

@end
