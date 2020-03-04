//
//  HDCacheStorage.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheStorage.h"
#import "NSString+HDCache.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "YYModel.h"

const NSString *HDCacheStorageDefaultFinderName = @"Storage";
const NSString *HDCacheStorageDefaultkeyChainServiceSuffix = @"com.vipay.keyChain";

typedef NSCache HDMemoryCache;

@interface HDCacheStorage ()
@property (nonatomic, strong) HDMemoryCache *storageArchivers;
@property (nonatomic, copy) NSArray *finderNames;
@property (nonatomic, strong) UICKeyChainStore *keyChainStore;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation HDCacheStorage

+ (instancetype)defaultStorage {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

#pragma mark - 保存对象
- (void)setObject:(HDCacheStorageObject *)aObject forKey:(NSString *)aKey {
    [self setObject:aObject forKey:aKey type:HDCacheStorageTypeArchiver];
}

- (void)setObject:(HDCacheStorageObject *)aObject
           forKey:(NSString *)aKey
             type:(HDCacheStorageType)type {
    NSString *processedKey = [self processedKeyWithKey:aKey];

    if (aKey.length > 0) {
        switch (type) {
            case HDCacheStorageTypeMemory: {
                [self.storageArchivers setObject:aObject forKey:processedKey];
            } break;

            case HDCacheStorageTypeUserDefaults: {
                [self.userDefaults setObject:[aObject yy_modelToJSONData] forKey:processedKey];
                [self.userDefaults synchronize];
                [self.storageArchivers setObject:aObject forKey:processedKey];
            } break;

            case HDCacheStorageTypeArchiver: {
                [self archiveObject:aObject];
                [self.storageArchivers setObject:aObject forKey:processedKey];
            } break;

            case HDCacheStorageTypeKeyChain: {
                [self.keyChainStore setData:[aObject yy_modelToJSONData] forKey:aKey];
                [self.storageArchivers setObject:aObject forKey:processedKey];
            } break;

            default:
                break;
        }
    }
}

#pragma mark - 获取对象
- (HDCacheStorageObject *)objectForKey:(NSString *)aKey {

    NSString *processedKey = [self processedKeyWithKey:aKey];

    // 优先从 NSCache 获取
    HDCacheStorageObject *object = [self.storageArchivers objectForKey:processedKey];

    // 磁盘获取次之
    if (!object) {
        NSString *filePath = [self filePathWithKey:aKey];
        if (filePath) {
            object = [self unarchiveObjectWithPath:filePath];
        }
    }

    // 偏好设置再次之
    if (!object) {
        NSData *data = [self.userDefaults objectForKey:processedKey];
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            object = [HDCacheStorageObject yy_modelWithJSON:json];
        }
    }

    // 最后从 keyChain 获取
    if (!object) {
        NSData *data = [self.keyChainStore dataForKey:aKey];
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            object = [HDCacheStorageObject yy_modelWithJSON:json];
        }
    }
    // 缓存到 NSCache
    if (object) {
        [self.storageArchivers setObject:object forKey:processedKey];
    }
    return object;
}

#pragma mark - 删除对象
- (void)removeObjectForKey:(NSString *)aKey {
    NSString *processedKey = [self processedKeyWithKey:aKey];
    [self.storageArchivers removeObjectForKey:processedKey];

    NSArray *array = [self.finderNames copy];
    [array enumerateObjectsUsingBlock:^(NSString *finderName, NSUInteger idx,
                                        BOOL *stop) {
        NSString *filePath = [self filePathWithFileName:aKey finderName:finderName];
        if (filePath)
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }];

    [self.keyChainStore removeItemForKey:aKey];
    [self.userDefaults removeObjectForKey:processedKey];
}

- (void)removeAllObjects {
    [self.storageArchivers removeAllObjects];
    NSString *finderPath = [self cachePathWithFinderName:nil];
    [[NSFileManager defaultManager] removeItemAtPath:finderPath error:nil];
}

// 删除所有的永久文件
- (void)removePermanentObjects {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *permanentPath =
                [self cachePathWithFinderName:
                          self.finderNames[HDCacheStorageObjectIntervalAllTime]];
            [HDCacheStorage enumerateFilesWithPath:permanentPath
                                        usingBlock:^(NSString *fileName) {
                                            NSString *filePath = [permanentPath
                                                stringByAppendingString:fileName];
                                            BOOL isDir;
                                            if ([[NSFileManager defaultManager]
                                                    fileExistsAtPath:filePath
                                                         isDirectory:&isDir] &&
                                                !isDir) {
                                                [[NSFileManager defaultManager]
                                                    removeItemAtPath:filePath
                                                               error:nil];
                                            }
                                        }];
        });
}

// 删除所有的默认文件，常用方法
- (void)removeDefaultObjectsWithCompletionBlock:
    (void (^)(long long folderSize))completionBlock {

    [self.storageArchivers removeAllObjects];

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path =
                [self cachePathWithFinderName:
                          self.finderNames[HDCacheStorageObjectIntervalDefault]];
            __block long long folderSize = 0;
            [HDCacheStorage
                enumerateFilesWithPath:path
                            usingBlock:^(NSString *fileName) {
                                NSString *filePath =
                                    [path stringByAppendingPathComponent:fileName];
                                BOOL isDir;
                                if ([[NSFileManager defaultManager]
                                        fileExistsAtPath:filePath
                                             isDirectory:&isDir] &&
                                    !isDir) {
                                    long long size = [[[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                                         error:nil] fileSize];
                                    folderSize += size;
                                    [[NSFileManager defaultManager]
                                        removeItemAtPath:filePath
                                                   error:nil];
                                }
                            }];
            if (completionBlock)
                completionBlock(folderSize);
        });
}

// 删除过期的文件
- (void)removeExpireObjects {
    [self.storageArchivers removeAllObjects];

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *path =
                [self cachePathWithFinderName:
                          self.finderNames[HDCacheStorageObjectIntervalTiming]];
            [HDCacheStorage
                enumerateFilesWithPath:path
                            usingBlock:^(NSString *fileName) {
                                NSString *filePath =
                                    [path stringByAppendingPathComponent:fileName];
                                BOOL isDir;
                                if ([[NSFileManager defaultManager]
                                        fileExistsAtPath:filePath
                                             isDirectory:&isDir] &&
                                    !isDir) {
                                    [self unarchiveObjectWithPath:filePath];
                                }
                            }];
        });
}

+ (void)removeDefaultObjectsWithCompletionBlock:
    (void (^)(long long folderSize))completionBlock {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            HDCacheStorage *storage = [HDCacheStorage defaultStorage];
            [storage removeAllObjects];
            [storage removeAllObjects];
            NSString *path = [storage
                cachePathWithFinderName:storage.finderNames
                                            [HDCacheStorageObjectIntervalDefault]];
            __block long long folderSize = 0;
            [HDCacheStorage
                enumerateFilesWithPath:path
                            usingBlock:^(NSString *fileName) {
                                NSString *filePath =
                                    [path stringByAppendingPathComponent:fileName];
                                long long size = [[[NSFileManager defaultManager]
                                    attributesOfItemAtPath:filePath
                                                     error:nil] fileSize];
                                folderSize += size;
                            }];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            if (completionBlock)
                completionBlock(folderSize);
        });
}

+ (void)removeExpireObjects {
    HDCacheStorage *storage = [HDCacheStorage defaultStorage];
    [storage removeAllObjects];
    [storage removeAllObjects];

    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            HDCacheStorage *storage = [HDCacheStorage defaultStorage];
            NSString *path = [storage
                cachePathWithFinderName:storage.finderNames
                                            [HDCacheStorageObjectIntervalTiming]];
            [self removeExpireObjectsWithPath:path];
        });
}

+ (void)removeExpireObjectsWithPath:(NSString *)path {
    [HDCacheStorage
        enumerateFilesWithPath:path
                    usingBlock:^(NSString *fileName) {
                        NSString *filePath =
                            [path stringByAppendingPathComponent:fileName];
                        BOOL isDir;
                        if ([[NSFileManager defaultManager]
                                fileExistsAtPath:filePath
                                     isDirectory:&isDir] &&
                            !isDir) {
                            [[HDCacheStorage defaultStorage]
                                unarchiveObjectWithPath:filePath];
                        } else {
                            [HDCacheStorage removeExpireObjectsWithPath:filePath];
                        }
                    }];
}

- (void)clearMemory {
    [self.storageArchivers removeAllObjects];
}

#pragma mark - archive/unarchive
- (void)archiveObject:(HDCacheStorageObject *)object {
    @synchronized(self) {
        // 移除其他级别的文件，一个Key只保存一份
        [self removeObjectForKey:object.objectIdentifier];
        NSString *filePath = [self filePathWithObject:object];
        [NSKeyedArchiver archiveRootObject:object toFile:filePath];
    }
}

- (HDCacheStorageObject *)unarchiveObjectWithPath:(NSString *)path {
    if ([path hasSuffix:@".DS_Store"])
        return nil;
    HDCacheStorageObject *object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } @catch (NSException *exception) {
    }
    switch (object.storageIntervalType) {
        case HDCacheStorageObjectIntervalTiming: {
            // 验证对象生命情况
            NSDictionary *arrtibutes =
                [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                 error:nil];
            if (arrtibutes) {
                NSDate *createDate = arrtibutes[NSFileCreationDate];
                if (createDate) {
                    NSTimeInterval interval =
                        [[NSDate date] timeIntervalSinceDate:createDate];
                    BOOL valid = interval < object.timeoutInterval;
                    if (valid)
                        return object;
                }
                dispatch_async(
                    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    });
            }
        } break;

        case HDCacheStorageObjectIntervalDefault:
        case HDCacheStorageObjectIntervalAllTime: {
            return object;
        } break;
    }
    return nil;
}

#pragma mark - 文件名操作
- (NSArray *)finderNames {
    if (!_finderNames) {
        _finderNames = @[
            [@"StorageNormal" hdCache_md5],
            [@"StorageTiming" hdCache_md5],
            [@"StorageAllTime" hdCache_md5]
        ];
    }
    return _finderNames;
}

- (NSString *)filePathWithObject:(HDCacheStorageObject *)object {
    NSString *finderName = self.finderNames[object.storageIntervalType];
    return [self filePathWithFileName:object.objectIdentifier
                           finderName:finderName];
}

- (NSString *)filePathWithKey:(NSString *)aKey {
    __block NSString *objectPath = nil;
    NSArray *array = [self.finderNames copy];
    [array enumerateObjectsUsingBlock:^(NSString *finderName, NSUInteger idx,
                                        BOOL *stop) {
        NSString *filePath = [self filePathWithFileName:aKey finderName:finderName];
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (exist) {
            objectPath = filePath;
            *stop = exist;
        }
    }];
    return objectPath;
}

#pragma mark - 目录操作
- (NSString *)filePathWithFileName:(NSString *)name
                        finderName:(NSString *)finderName {
    if ([name length] <= 0)
        return nil;
    NSString *finderPath = [self cachePathWithFinderName:finderName];
    NSString *filePath =
        [NSString stringWithFormat:@"%@%@", finderPath, [name hdCache_md5]];
    return filePath;
}

/** 根据目录名称获取缓存路径 */
- (NSString *)cachePathWithFinderName:(NSString *)finderName {
    BOOL isDocument = self.isInDocumentDir;
    NSString *directory = isDocument ? [HDCacheStorage documentDirectory]
                                     : [HDCacheStorage cachesDirectory];
    NSString *fileDirectory =
        [NSString stringWithFormat:@"%@%@/", directory,
                                   [HDCacheStorageDefaultFinderName hdCache_md5]];
    if (finderName.length) {
        fileDirectory =
            [NSString stringWithFormat:@"%@%@/", fileDirectory, finderName];
    }
    // 空间目录
    if (self.nameSpace.length) {
        fileDirectory =
            [NSString stringWithFormat:@"%@%@/", fileDirectory,
                                       [[self.nameSpace hdCache_md5] hdCache_md5]];
    }
    if (fileDirectory &&
        [[NSFileManager defaultManager] fileExistsAtPath:fileDirectory] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return fileDirectory;
}

/** 获取缓存路径 */
+ (NSString *)cachesDirectory {
    static NSString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [HDCacheStorage pathWithSearchDirectory:NSCachesDirectory];
    });
    return instance;
}

+ (NSString *)documentDirectory {
    static NSString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [HDCacheStorage pathWithSearchDirectory:NSDocumentDirectory];
    });
    return instance;
}

+ (NSString *)pathWithSearchDirectory:(NSSearchPathDirectory)searchDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(searchDirectory,
                                                         NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    directory = [directory stringByAppendingString:@"/"];
    return directory;
}

/** 遍历路径的目录，返回所有的文件名 */
+ (void)enumerateFilesWithPath:(NSString *)path
                    usingBlock:(void (^)(NSString *fileName))block {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path])
        return;
    NSEnumerator *filesEnumerator =
        [[manager subpathsAtPath:path] objectEnumerator];
    NSString *fileName;
    while ((fileName = [filesEnumerator nextObject]) != nil) {
        block(fileName);
    }
}

- (NSString *)keyChainServiceName {
    return [[NSString stringWithFormat:@"%@_%@", self.nameSpace, HDCacheStorageDefaultkeyChainServiceSuffix] hdCache_md5];
}

- (NSString *)processedKeyWithKey:(NSString *)akey {
    return [[NSString stringWithFormat:@"%@_%@", self.nameSpace, akey] hdCache_md5];
}

#pragma mark - lazy load
- (HDMemoryCache *)storageArchivers {
    return _storageArchivers ?: ({ _storageArchivers = [[HDMemoryCache alloc] init]; });
}

- (UICKeyChainStore *)keyChainStore {
    return _keyChainStore ?: ({ _keyChainStore = [UICKeyChainStore keyChainStoreWithService:[self keyChainServiceName]]; });
}

- (NSUserDefaults *)userDefaults {
    return _userDefaults ?: ({ _userDefaults = [NSUserDefaults standardUserDefaults]; });
}
@end
