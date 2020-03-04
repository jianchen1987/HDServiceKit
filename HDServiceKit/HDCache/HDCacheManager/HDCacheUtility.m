//
//  HDCacheUtility.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheUtility.h"
#import "HDCacheManager.h"

extern NSString *const HDCachePrivateAESKey;
extern NSString *const HDCachePrivateAESNameSpace;

@interface HDCacheUtility ()

@property (nonatomic, strong) NSMutableArray *sizeArray;
@property (nonatomic, strong) NSMutableArray *cleanArray;

@end

@implementation HDCacheUtility

+ (instancetype)defaultCacheUtility {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (NSMutableArray *)sizeArray {
    return _sizeArray ?: ({ _sizeArray = [NSMutableArray array]; });
}

- (NSMutableArray *)cleanArray {
    return _cleanArray ?: ({ _cleanArray = [NSMutableArray array]; });
}

#pragma mark - 缓存大小返回
+ (void)sizeWithBlock:(void (^)(NSInteger totalSize))block {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            HDCacheUtility *utility = [HDCacheUtility defaultCacheUtility];
            __block NSInteger totalSize = 0;
            [utility.sizeArray
                enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                             BOOL *_Nonnull stop) {
                    HDCacheUtilitySizeBlock handleBlock = obj;
                    handleBlock(^(NSInteger size) {
                        totalSize += size;
                    });
                }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(totalSize);
                }
            });
        });
}

+ (void)registerCacheSizeBlock:(HDCacheUtilitySizeBlock)block {
    if (block) {
        HDCacheUtility *utility = [HDCacheUtility defaultCacheUtility];
        [utility.sizeArray addObject:block];
    }
}

#pragma mark - 缓存清理注册
+ (void)registerCacheCleanBlock:(void (^)(void))block {
    if (block) {
        HDCacheUtility *utility = [HDCacheUtility defaultCacheUtility];
        [utility.cleanArray addObject:block];
    }
}

+ (void)cleanWithCompleteBlock:(void (^)(void))completeBlock {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            HDCacheUtility *utility = [HDCacheUtility defaultCacheUtility];
            [utility.cleanArray
                enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx,
                                             BOOL *_Nonnull stop) {
                    void (^block)(void) = obj;
                    if (block) {
                        block();
                    }
                }];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completeBlock) {
                    completeBlock();
                }
            });
        });
}

#pragma mark -
+ (void)registerAESKey:(NSString *)key {
    HDCacheManager *cacheManager =
        [[HDCacheManager alloc] initWithNameSpace:HDCachePrivateAESNameSpace];
    [cacheManager setObject:key forKey:HDCachePrivateAESKey];
}

@end
