//
//  HDNetworkCache.m
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkCache.h"
#import "HDNetworkCache+Internal.h"

@interface HDNetworkCachePackage : NSObject <NSCoding>
@property (nonatomic, strong) id<NSCoding> object;
@property (nonatomic, strong) NSDate *updateDate;
@end
@implementation HDNetworkCachePackage
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.object = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(object))];
    self.updateDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(updateDate))];
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.object forKey:NSStringFromSelector(@selector(object))];
    [aCoder encodeObject:self.updateDate forKey:NSStringFromSelector(@selector(updateDate))];
}
@end

static NSString *const HDNetworkCacheName = @"HDNetworkCacheName";
static YYDiskCache *_diskCache = nil;
static YYMemoryCache *_memoryCache = nil;

@implementation HDNetworkCache

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.writeMode = HDNetworkCacheWriteModeNone;
        self.readMode = HDNetworkCacheReadModeNone;
        self.ageSeconds = 0;
        self.extraCacheKey = [@"v" stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    }
    return self;
}

#pragma mark - public

+ (NSInteger)getDiskCacheSize {
    return [HDNetworkCache.diskCache totalCost] / 1024.0 / 1024.0;
}

+ (void)removeDiskCache {
    [HDNetworkCache.diskCache removeAllObjects];
}

+ (void)removeMemeryCache {
    [HDNetworkCache.memoryCache removeAllObjects];
}

#pragma mark - internal

- (void)setObject:(id<NSCoding>)object forKey:(id)key {
    if (self.writeMode == HDNetworkCacheWriteModeNone) return;

    HDNetworkCachePackage *package = [HDNetworkCachePackage new];
    package.object = object;
    package.updateDate = [NSDate date];

    if (self.writeMode & HDNetworkCacheWriteModeMemory) {
        [HDNetworkCache.memoryCache setObject:package forKey:key];
    }
    if (self.writeMode & HDNetworkCacheWriteModeDisk) {
        [HDNetworkCache.diskCache setObject:package
                                     forKey:key
                                  withBlock:^{
                                  }];  //子线程执行，空闭包仅为了去除警告
    }
}

- (void)objectForKey:(NSString *)key withBlock:(nonnull void (^)(NSString *_Nonnull, id<NSCoding> _Nullable))block {
    if (!block) return;

    void (^callBack)(id<NSCoding>) = ^(id<NSCoding> obj) {
        HDNETWORK_MAIN_QUEUE_ASYNC(^{
            if (obj && [((NSObject *)obj) isKindOfClass:HDNetworkCachePackage.class]) {
                HDNetworkCachePackage *package = (HDNetworkCachePackage *)obj;
                if (self.ageSeconds != 0 && -[package.updateDate timeIntervalSinceNow] > self.ageSeconds) {
                    block(key, nil);
                } else {
                    block(key, package.object);
                }
            } else {
                block(key, nil);
            }
        })
    };

    id<NSCoding> object = [HDNetworkCache.memoryCache objectForKey:key];
    if (object) {
        callBack(object);
    } else {
        [HDNetworkCache.diskCache objectForKey:key
                                     withBlock:^(NSString *key, id<NSCoding> object) {
                                         if (object && ![HDNetworkCache.memoryCache objectForKey:key]) {
                                             [HDNetworkCache.memoryCache setObject:object forKey:key];
                                         }
                                         callBack(object);
                                     }];
    }
}

#pragma mark - getter and setter

+ (YYDiskCache *)diskCache {
    if (!_diskCache) {
        NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [cacheFolder stringByAppendingPathComponent:HDNetworkCacheName];
        _diskCache = [[YYDiskCache alloc] initWithPath:path];
    }
    return _diskCache;
}

+ (void)setDiskCache:(YYDiskCache *)diskCache {
    _diskCache = diskCache;
}

+ (YYMemoryCache *)memoryCache {
    if (!_memoryCache) {
        _memoryCache = [YYMemoryCache new];
        _memoryCache.name = HDNetworkCacheName;
    }
    return _memoryCache;
}

+ (void)setMemoryCache:(YYMemoryCache *)memoryCache {
    _memoryCache = memoryCache;
}

@end
