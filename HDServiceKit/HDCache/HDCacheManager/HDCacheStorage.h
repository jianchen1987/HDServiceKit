//
//  HDCacheStorage.h
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheStorageObject.h"
#import <Foundation/Foundation.h>

extern NSString *HDCacheStorageDefaultFinderName;

typedef NS_ENUM(NSUInteger, HDCacheStorageType) {
    HDCacheStorageTypeMemory = 0,    ///< Memory 缓存
    HDCacheStorageTypeArchiver,      ///< 磁盘缓存
    HDCacheStorageTypeUserDefaults,  ///< 应用偏好设置
    HDCacheStorageTypeKeyChain       ///< 缓存到 KeyChain
};

@interface HDCacheStorage : NSObject

/**
 空间，nameSpace以.document结尾则数据保存至Document
 */
@property (nonatomic, strong) NSString *nameSpace;

/**
 isInDocumentDir 是否在 Document 目录，否则在 Cache 目录
 */
@property (nonatomic, assign) BOOL isInDocumentDir;

+ (instancetype)defaultStorage;

/**
 存储数据，HDCacheStorageType 为 HDCacheStorageTypeArchiver

 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 */
- (void)setObject:(HDCacheStorageObject *)aObject forKey:(NSString *)aKey;

/**
 存储数据

 @param aObject 存储对象，支持String,URL,Data,Number,Dictionary,Array,Null,自定义实体类
 @param aKey 唯一的对应的值，相同的值对覆盖原来的对象
 @param type 类型
 */
- (void)setObject:(HDCacheStorageObject *)aObject
           forKey:(NSString *)aKey
             type:(HDCacheStorageType)type;

/**
 获取数据

 @param aKey 唯一的对应的值
 */
- (HDCacheStorageObject *)objectForKey:(NSString *)aKey;

/**
 移除数据

@param aKey 唯一的对应的值
 */
- (void)removeObjectForKey:(NSString *)aKey;

/**
 删除所有的默认文件，常用方法

 @param completionBlock 完成回调
 */
- (void)removeDefaultObjectsWithCompletionBlock:
    (void (^)(long long folderSize))completionBlock;

/**
 删除过期的文件
 */
- (void)removeExpireObjects;

/**
 对所有空间做操作，删除所有的默认文件，谨慎操作

 @param completionBlock 完成回调
 */
+ (void)removeDefaultObjectsWithCompletionBlock:
    (void (^)(long long folderSize))completionBlock;

/**
 删除过期的文件，谨慎操作
 */
+ (void)removeExpireObjects;

/** 清除内存缓存 */
- (void)clearMemory;

@end
