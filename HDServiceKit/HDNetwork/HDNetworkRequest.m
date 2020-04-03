//
//  HDNetworkRequest.m
//  HDServiceKit
//
//  Created by VanJay on 03/23/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkRequest.h"
#import "HDNetworkCache+Internal.h"
#import "HDNetworkManager.h"
#import "HDNetworkRequest+Internal.h"
#import <pthread/pthread.h>

#define HDN_IDECORD_LOCK(...)         \
    pthread_mutex_lock(&self->_lock); \
    __VA_ARGS__                       \
    pthread_mutex_unlock(&self->_lock);

@interface HDNetworkRequest ()
@property (nonatomic, copy, nullable) HDRequestProgressBlock uploadProgress;
@property (nonatomic, copy, nullable) HDRequestProgressBlock downloadProgress;
@property (nonatomic, copy, nullable) HDRequestCacheBlock cacheBlock;
@property (nonatomic, copy, nullable) HDRequestSuccessBlock successBlock;
@property (nonatomic, copy, nullable) HDRequestFailureBlock failureBlock;
@property (nonatomic, strong) HDNetworkCache *cacheHandler;
@property (nonatomic, strong) HDNetworkRetryConfig *retryConfig;
/// 记录网络任务标识容器
@property (nonatomic, strong) NSMutableSet<NSNumber *> *taskIDRecord;
@end

@implementation HDNetworkRequest {
    pthread_mutex_t _lock;
}

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        self.releaseStrategy = HDNetworkReleaseStrategyHoldRequest;
        self.repeatStrategy = HDNetworkRepeatStrategyAllAllowed;
        self.taskIDRecord = [NSMutableSet set];
        self.requestTimeoutInterval = 30;
    }
    return self;
}

- (void)dealloc {
    if (self.releaseStrategy == HDNetworkReleaseStrategyWhenRequestDealloc) {
        [self cancel];
    }
    pthread_mutex_destroy(&_lock);
}

#pragma mark - public

- (void)startWithSuccess:(HDRequestSuccessBlock)success failure:(HDRequestFailureBlock)failure {
    [self startWithUploadProgress:nil downloadProgress:nil cache:nil success:success failure:failure];
}

- (void)startWithCache:(HDRequestCacheBlock)cache success:(HDRequestSuccessBlock)success failure:(HDRequestFailureBlock)failure {
    [self startWithUploadProgress:nil downloadProgress:nil cache:cache success:success failure:failure];
}

- (void)startWithUploadProgress:(HDRequestProgressBlock)uploadProgress downloadProgress:(HDRequestProgressBlock)downloadProgress cache:(HDRequestCacheBlock)cache success:(HDRequestSuccessBlock)success failure:(HDRequestFailureBlock)failure {
    self.uploadProgress = uploadProgress;
    self.downloadProgress = downloadProgress;
    self.cacheBlock = cache;
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)start {
    if (self.isExecuting) {
        switch (self.repeatStrategy) {
            case HDNetworkRepeatStrategyCancelNewest:
                return;
            case HDNetworkRepeatStrategyCancelOldest: {
                [self cancelNetworking];
            } break;
            default:
                break;
        }
    }

    NSString *cacheKey = [self requestCacheKey];

    if (self.cacheHandler.readMode == HDNetworkCacheReadModeNone) {
        [self startWithCacheKey:cacheKey];
        return;
    }

    [self.cacheHandler objectForKey:cacheKey
                          withBlock:^(NSString *_Nonnull key, id<NSCoding> _Nonnull object) {
                              if (object) {  // 缓存命中
                                  HDNetworkResponse *response = [HDNetworkResponse responseWithSessionTask:nil responseObject:object error:nil];
                                  [self successWithResponse:response cacheKey:cacheKey fromCache:YES taskID:nil];
                              }

                              BOOL needRequestNetwork = !object || self.cacheHandler.readMode == HDNetworkCacheReadModeAlsoNetwork;
                              if (needRequestNetwork) {
                                  [self startWithCacheKey:cacheKey];
                              } else {
                                  [self clearRequestBlocks];
                              }
                          }];
}

- (void)cancel {
    self.delegate = nil;
    [self clearRequestBlocks];
    [self cancelNetworking];
}

- (void)cancelNetworking {
    // 此处取消顺序很重要
    // clang-format off
    HDN_IDECORD_LOCK(
        NSSet *removeSet = self.taskIDRecord.mutableCopy;
            [self.taskIDRecord removeAllObjects];
    );
    // clang-format on
    [[HDNetworkManager sharedManager] cancelNetworkingWithSet:removeSet];
}

- (BOOL)isExecuting {
    HDN_IDECORD_LOCK(BOOL isExecuting = self.taskIDRecord.count > 0;)
    return isExecuting;
}

- (void)clearRequestBlocks {
    self.uploadProgress = nil;
    self.downloadProgress = nil;
    self.cacheBlock = nil;
    self.successBlock = nil;
    self.failureBlock = nil;
}

#pragma mark - request

- (void)startWithCacheKey:(NSString *)cacheKey {
    __weak typeof(self) weakSelf = self;
    BOOL(^cancelled)
    (NSNumber *) = ^BOOL(NSNumber *taskID) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return YES;
        HDN_IDECORD_LOCK(BOOL contains = [self.taskIDRecord containsObject:taskID];)
        return !contains;
    };

    __block NSNumber *taskID = nil;
    if (self.releaseStrategy == HDNetworkReleaseStrategyHoldRequest) {
        taskID = [[HDNetworkManager sharedManager] startNetworkingWithRequest:self
            uploadProgress:^(NSProgress *_Nonnull progress) {
                if (cancelled(taskID)) return;
                [self requestUploadProgress:progress];
            }
            downloadProgress:^(NSProgress *_Nonnull progress) {
                if (cancelled(taskID)) return;
                [self requestDownloadProgress:progress];
            }
            completion:^(HDNetworkResponse *_Nonnull response) {
                if (cancelled(taskID)) return;
                [self requestCompletionWithResponse:response cacheKey:cacheKey fromCache:NO taskID:taskID];
            }];
    } else {
        __weak typeof(self) weakSelf = self;
        taskID = [[HDNetworkManager sharedManager] startNetworkingWithRequest:weakSelf
            uploadProgress:^(NSProgress *_Nonnull progress) {
                if (cancelled(taskID)) return;
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self requestUploadProgress:progress];
            }
            downloadProgress:^(NSProgress *_Nonnull progress) {
                if (cancelled(taskID)) return;
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self requestDownloadProgress:progress];
            }
            completion:^(HDNetworkResponse *_Nonnull response) {
                if (cancelled(taskID)) return;
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self requestCompletionWithResponse:response cacheKey:cacheKey fromCache:NO taskID:taskID];
            }];
    }
    if (nil != taskID) {
        HDN_IDECORD_LOCK([self.taskIDRecord addObject:taskID];)
    }
}

#pragma mark - response

- (void)requestUploadProgress:(NSProgress *)progress {
    HDNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self.delegate respondsToSelector:@selector(request:uploadProgress:)]) {
            [self.delegate request:self uploadProgress:progress];
        }
        if (self.uploadProgress) {
            self.uploadProgress(progress);
        }
    })
}

- (void)requestDownloadProgress:(NSProgress *)progress {
    HDNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self.delegate respondsToSelector:@selector(request:downloadProgress:)]) {
            [self.delegate request:self downloadProgress:progress];
        }
        if (self.downloadProgress) {
            self.downloadProgress(progress);
        }
    })
}

- (void)requestCompletionWithResponse:(HDNetworkResponse *)response cacheKey:(NSString *)cacheKey fromCache:(BOOL)fromCache taskID:(NSNumber *)taskID {
    void (^process)(HDRequestRedirection) = ^(HDRequestRedirection redirection) {
        switch (redirection) {
            case HDRequestRedirectionSuccess: {
                [self successWithResponse:response cacheKey:cacheKey fromCache:NO taskID:taskID];
            } break;
            case HDRequestRedirectionFailure: {
                [self failureWithResponse:response taskID:taskID];
            } break;
            case HDRequestRedirectionStop:
            default: {
                HDN_IDECORD_LOCK([self.taskIDRecord removeObject:taskID];)
            } break;
        }
    };

    if ([self respondsToSelector:@selector(hd_redirection:response:)]) {
        [self hd_redirection:process response:response];
    } else {
        HDRequestRedirection redirection = response.error ? HDRequestRedirectionFailure : HDRequestRedirectionSuccess;
        process(redirection);
    }
}

- (void)successWithResponse:(HDNetworkResponse *)response cacheKey:(NSString *)cacheKey fromCache:(BOOL)fromCache taskID:(NSNumber *)taskID {
    if ([self respondsToSelector:@selector(hd_preprocessSuccessInChildThreadWithResponse:)]) {
        [self hd_preprocessSuccessInChildThreadWithResponse:response];
    }

    HDNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self respondsToSelector:@selector(hd_preprocessSuccessInMainThreadWithResponse:)]) {
            [self hd_preprocessSuccessInMainThreadWithResponse:response];
        }

        if (fromCache) {
            BOOL shouldReadCache = !self.cacheHandler.shouldReadCacheBlock || self.cacheHandler.shouldReadCacheBlock(response);
            if (shouldReadCache) {
                if ([self.delegate respondsToSelector:@selector(request:cacheWithResponse:)]) {
                    [self.delegate request:self cacheWithResponse:response];
                }
                if (self.cacheBlock) {
                    self.cacheBlock(response);
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(request:successWithResponse:)]) {
                [self.delegate request:self successWithResponse:response];
            }
            if (self.successBlock) {
                self.successBlock(response);
            }
            [self clearRequestBlocks];

            // 在网络响应数据被业务处理完成后进行缓存，可避免将异常数据写入缓存（比如数据导致 Crash 的情况）
            BOOL shouldCache = !self.cacheHandler.shouldWriteCacheBlock || self.cacheHandler.shouldWriteCacheBlock(response);
            BOOL isSendFile = self.requestConstructingBody || self.downloadPath.length > 0;
            if (!isSendFile && shouldCache) {
                [self.cacheHandler setObject:response.responseObject forKey:cacheKey];
            }
        }

        if (taskID) [self.taskIDRecord removeObject:taskID];
    })
}

- (void)failureWithResponse:(HDNetworkResponse *)response taskID:(NSNumber *)taskID {
    if ([self respondsToSelector:@selector(hd_preprocessFailureInChildThreadWithResponse:)]) {
        [self hd_preprocessFailureInChildThreadWithResponse:response];
    }

    HDNETWORK_MAIN_QUEUE_ASYNC(^{
        if ([self respondsToSelector:@selector(hd_preprocessFailureInMainThreadWithResponse:)]) {
            [self hd_preprocessFailureInMainThreadWithResponse:response];
        }

        if ([self.delegate respondsToSelector:@selector(request:failureWithResponse:)]) {
            [self.delegate request:self failureWithResponse:response];
        }
        if (self.failureBlock) {
            self.failureBlock(response);
        }
        [self clearRequestBlocks];

        if (taskID) [self.taskIDRecord removeObject:taskID];
    })
}

#pragma mark - private

- (NSString *)requestIdentifier {
    NSString *identifier = [NSString stringWithFormat:@"%@-%@%@", [self requestMethodString], [self validRequestURLString], [self stringFromParameter:[self validRequestParameter]]];
    return identifier;
}

- (NSString *)requestCacheKey {
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@", self.cacheHandler.extraCacheKey, [self requestIdentifier]];
    if (self.cacheHandler.customCacheKeyBlock) {
        cacheKey = self.cacheHandler.customCacheKeyBlock(cacheKey);
    }
    return cacheKey;
}

- (NSString *)stringFromParameter:(NSDictionary *)parameter {
    NSMutableString *string = [NSMutableString string];
    NSArray *allKeys = [parameter.allKeys sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        return [[NSString stringWithFormat:@"%@", obj1] compare:[NSString stringWithFormat:@"%@", obj2] options:NSLiteralSearch];
    }];
    for (id key in allKeys) {
        [string appendString:[NSString stringWithFormat:@"%@%@=%@", string.length > 0 ? @"&" : @"?", key, parameter[key]]];
    }
    return string;
}

- (NSString *)requestMethodString {
    switch (self.requestMethod) {
        case HDRequestMethodGET:
            return @"GET";
        case HDRequestMethodPOST:
            return @"POST";
        case HDRequestMethodPUT:
            return @"PUT";
        case HDRequestMethodDELETE:
            return @"DELETE";
        case HDRequestMethodHEAD:
            return @"HEAD";
        case HDRequestMethodPATCH:
            return @"PATCH";
    }
}

- (NSString *)validRequestURLString {
    NSURL *baseURL = [NSURL URLWithString:self.baseURI];
    NSString *URLString = [NSURL URLWithString:self.requestURI relativeToURL:baseURL].absoluteString;
    if ([self respondsToSelector:@selector(hd_preprocessURLString:)]) {
        URLString = [self hd_preprocessURLString:URLString];
    }
    return URLString;
}

- (id)validRequestParameter {
    id parameter = self.requestParameter;
    if ([self respondsToSelector:@selector(hd_preprocessParameter:)]) {
        parameter = [self hd_preprocessParameter:parameter];
    }
    return parameter;
}

#pragma mark - getter

- (HDNetworkCache *)cacheHandler {
    if (!_cacheHandler) {
        _cacheHandler = [HDNetworkCache new];
    }
    return _cacheHandler;
}

- (HDNetworkRetryConfig *)retryConfig {
    return _retryConfig ?: ({ _retryConfig = HDNetworkRetryConfig.new; });
}
@end
