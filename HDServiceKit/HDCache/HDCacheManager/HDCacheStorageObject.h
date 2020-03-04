//
//  HDCacheStorageObject.h
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HDCacheStorageObjectTimeOutInterval) {
    HDCacheStorageObjectIntervalDefault,
    HDCacheStorageObjectIntervalTiming,  // 定时
    HDCacheStorageObjectIntervalAllTime  // 永久
};

@interface HDCacheStorageObject : NSObject <NSCoding>

/** 数据String */
@property (nonatomic, copy, readonly) NSString *storageString;

/** 数据类名 */
@property (nonatomic, strong, readonly) id storageObject;

/** 数据的存储时效类型 */
@property (nonatomic, assign, readonly)
    HDCacheStorageObjectTimeOutInterval storageIntervalType;

/** 当前对象的标识符（KEY），默认会自动生成，可自定义 */
@property (nonatomic, copy) NSString *objectIdentifier;

/**
 存储文件的过期时间，负数表示永久存储
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 根据（String,URL,Data,Number,Dictionary,Array,Null,实体）初始化存储对象

 @param object 原始对象
 */
- (instancetype)initWithObject:(id)object;

@end
