//
//  HDCacheManager.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheManager.h"
#import <pthread.h>

NSString *const kHDCacheManagerObjectKey = @"kHDCacheManagerObjectKey";
NSString *const kHDCacheManagerSetObjectNotification = @"kHDCacheManagerSetObjectNotification";
NSString *const kHDCacheManagerGetObjectNotification = @"kHDCacheManagerGetObjectNotification";
NSString *const kHDCacheManagerRemoveObjectNotification = @"kHDCacheManagerRemoveObjectNotification";

@interface HDCacheManager ()

@property (nonatomic, strong) HDCacheStorage *fileStorage;
@property (nonatomic, strong) NSCache *tmpDatas;
@property (nonatomic, assign) pthread_rwlock_t rwLock;

@end

@implementation HDCacheManager

+ (HDCacheManager *)defaultManager {
    static HDCacheManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
        instance.nameSpace = @"Data";
        // 初始化锁
        pthread_rwlock_t rwLock = instance.rwLock;
        pthread_rwlock_init(&rwLock, NULL);
    });
    return instance;
}

- (void)dealloc {
    pthread_rwlock_destroy(&_rwLock);
}

+ (instancetype)cacheManagerWithNameSpace:(NSString *)nameSpace {
    return [[self alloc] initWithNameSpace:nameSpace];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace {
    return [self initWithNameSpace:nameSpace isInDocumentDir:false];
}

+ (instancetype)cacheManagerWithNameSpace:(NSString *)nameSpace isInDocumentDir:(BOOL)isInDocumentDir {
    return [[self alloc] initWithNameSpace:nameSpace isInDocumentDir:isInDocumentDir];
}

- (instancetype)initWithNameSpace:(NSString *)nameSpace isInDocumentDir:(BOOL)isInDocumentDir {
    if (self = [super init]) {
        self.nameSpace = nameSpace;
        self.isInDocumentDir = isInDocumentDir;
        pthread_rwlock_init(&_rwLock, NULL);
    }
    return self;
}

- (HDCacheStorage *)fileStorage {
    return _fileStorage ?: ({
        HDCacheStorage *fileStorage = HDCacheStorage.new;
        fileStorage.nameSpace = self.nameSpace;
        fileStorage.isInDocumentDir = self.isInDocumentDir;
        _fileStorage = fileStorage;
    });
}

- (NSCache *)tmpDatas {
    return _tmpDatas ?: ({ _tmpDatas = [NSCache new]; });
}

#pragma mark -
- (void)setObject:(id)aObject forKey:(NSString *)aKey {
    [self setObject:aObject forKey:aKey duration:0];
}

- (void)setObject:(id)aObject
           forKey:(NSString *)aKey
         duration:(NSTimeInterval)duration {
    if (!aKey)
        return;
    if (!aObject) {
        [self removeObjectForKey:aKey];
        return;
    }
    pthread_rwlock_wrlock(&_rwLock);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHDCacheManagerSetObjectNotification
                      object:@{kHDCacheManagerObjectKey: @{aKey: aObject}}];
    HDCacheStorageObject *object =
        [[HDCacheStorageObject alloc] initWithObject:aObject];
    object.timeoutInterval = duration;
    object.objectIdentifier = aKey;
    if (object.storageString) {
        [self.fileStorage setObject:object forKey:aKey];
    }
    pthread_rwlock_unlock(&_rwLock);
}

- (void)setObject:(id)aObject forKey:(NSString *)aKey toDisk:(BOOL)toDisk {
    if (!aKey)
        return;
    if (!aObject) {
        [self removeObjectForKey:aKey];
        return;
    }

    if (toDisk) {
        // 里面有加锁操作
        [self setObject:aObject forKey:aKey];
    } else {
        pthread_rwlock_wrlock(&_rwLock);
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kHDCacheManagerSetObjectNotification
                          object:@{kHDCacheManagerObjectKey: @{aKey: aObject}}];
        [self.tmpDatas setObject:aObject forKey:aKey];
        pthread_rwlock_unlock(&_rwLock);
    }
}

- (void)setObjectTokeyChain:(id)aObject forKey:(NSString *)aKey {
    if (!aKey)
        return;
    if (!aObject) {
        pthread_rwlock_wrlock(&_rwLock);
        [self removeObjectForKey:aKey];
        pthread_rwlock_unlock(&_rwLock);
        return;
    }
    pthread_rwlock_wrlock(&_rwLock);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHDCacheManagerSetObjectNotification
                      object:@{kHDCacheManagerObjectKey: @{aKey: aObject}}];
    HDCacheStorageObject *object =
        [[HDCacheStorageObject alloc] initWithObject:aObject];
    object.timeoutInterval = -1;
    object.objectIdentifier = aKey;
    if (object.storageString) {
        [self.fileStorage setObject:object forKey:aKey type:HDCacheStorageTypeKeyChain];
    }
    pthread_rwlock_unlock(&_rwLock);
}

- (void)setObjectToAppUserDefaults:(id)aObject forKey:(NSString *)aKey {
    if (!aKey)
        return;
    if (!aObject) {
        pthread_rwlock_wrlock(&_rwLock);
        [self removeObjectForKey:aKey];
        pthread_rwlock_unlock(&_rwLock);
        return;
    }
    pthread_rwlock_wrlock(&_rwLock);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHDCacheManagerSetObjectNotification
                      object:@{kHDCacheManagerObjectKey: @{aKey: aObject}}];
    HDCacheStorageObject *object =
        [[HDCacheStorageObject alloc] initWithObject:aObject];
    object.timeoutInterval = -1;
    if (object.storageString) {
        [self.fileStorage setObject:object forKey:aKey type:HDCacheStorageTypeUserDefaults];
    }
    pthread_rwlock_unlock(&_rwLock);
}

#pragma mark - 获取数据
- (id)objectForKey:(NSString *)aKey {

    if (!aKey) {
        return nil;
    }
    pthread_rwlock_rdlock(&_rwLock);
    id value = [self.tmpDatas objectForKey:aKey] ?: ({
        HDCacheStorageObject *object = [self.fileStorage objectForKey:aKey];
        id returnObject = [object storageObject];
        if (!returnObject) {
            pthread_rwlock_unlock(&_rwLock);
            return nil;
        }
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kHDCacheManagerGetObjectNotification
                          object:@{
                              kHDCacheManagerObjectKey: @{aKey: returnObject}
                          }];
        returnObject;
    });
    pthread_rwlock_unlock(&_rwLock);
    return value;
}

/** 异步根据Key获取缓存对象 */
- (void)objectKey:(NSString *)aKey completion:(void (^)(id obj))block {

    if (!aKey) {
        return;
    }

    pthread_rwlock_rdlock(&_rwLock);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       id obj = [self objectForKey:aKey];
                       if (block)
                           dispatch_async(dispatch_get_main_queue(), ^{
                               block(obj);
                           });
                   });
    pthread_rwlock_unlock(&_rwLock);
}

#pragma mark -
- (void)removeObjectForKey:(NSString *)aKey {
    if (!aKey)
        return;
    pthread_rwlock_wrlock(&_rwLock);
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHDCacheManagerRemoveObjectNotification
                      object:aKey];
    [self.fileStorage removeObjectForKey:aKey];
    [self.tmpDatas removeObjectForKey:aKey];
    pthread_rwlock_unlock(&_rwLock);
}

- (void)removeObjectsWithCompletionBlock:(void (^)(long long folderSize))completionBlock {
    pthread_rwlock_wrlock(&_rwLock);
    [self.fileStorage removeDefaultObjectsWithCompletionBlock:completionBlock];
    pthread_rwlock_unlock(&_rwLock);
}

- (void)removeExpireObjects {
    pthread_rwlock_wrlock(&_rwLock);
    [self.fileStorage removeExpireObjects];
    pthread_rwlock_unlock(&_rwLock);
}

+ (void)removeObjectsWithCompletionBlock:
    (void (^)(long long folderSize))completionBlock {
    pthread_rwlock_t rwLock;
    pthread_rwlock_wrlock(&rwLock);
    [HDCacheStorage removeDefaultObjectsWithCompletionBlock:completionBlock];
    pthread_rwlock_unlock(&rwLock);
    pthread_rwlock_destroy(&rwLock);
}

+ (void)removeExpireObjects {
    pthread_rwlock_t rwLock;
    pthread_rwlock_wrlock(&rwLock);
    [HDCacheStorage removeExpireObjects];
    pthread_rwlock_unlock(&rwLock);
    pthread_rwlock_destroy(&rwLock);
}

#pragma mark - getters and setters
- (void)setNameSpace:(NSString *)nameSpace {
    pthread_rwlock_wrlock(&_rwLock);
    _nameSpace = [nameSpace copy];
    self.fileStorage.nameSpace = nameSpace;
    pthread_rwlock_unlock(&_rwLock);
}

- (void)setIsInDocumentDir:(BOOL)isInDocumentDir {
    pthread_rwlock_wrlock(&_rwLock);
    _isInDocumentDir = isInDocumentDir;
    self.fileStorage.isInDocumentDir = isInDocumentDir;
    pthread_rwlock_unlock(&_rwLock);
}

- (void)clearMemory {
    pthread_rwlock_wrlock(&_rwLock);
    [self.tmpDatas removeAllObjects];
    [self.fileStorage clearMemory];
    pthread_rwlock_unlock(&_rwLock);
}
@end
