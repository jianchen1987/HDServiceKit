//
//  HDNetworkManager.m
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkManager.h"
#import "HDNetworkRequest+Internal.h"
#import <pthread/pthread.h>

#define HDNM_TASKRECORD_LOCK(...)     \
    pthread_mutex_lock(&self->_lock); \
    __VA_ARGS__                       \
    pthread_mutex_unlock(&self->_lock);

@interface HDNetworkManager ()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSURLSessionTask *> *taskRecord;
@end

@implementation HDNetworkManager {
    pthread_mutex_t _lock;
}

#pragma mark - life cycle

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

+ (instancetype)sharedManager {
    static HDNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDNetworkManager alloc] initSpecially];
    });
    return manager;
}

- (instancetype)initSpecially {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

#pragma mark - private

- (void)cancelTaskWithIdentifier:(NSNumber *)identifier {
    HDNM_TASKRECORD_LOCK(NSURLSessionTask *task = self.taskRecord[identifier];)
    if (task) {
        [task cancel];
        HDNM_TASKRECORD_LOCK([self.taskRecord removeObjectForKey:identifier];)
    }
}

- (void)cancelAllTask {
    HDNM_TASKRECORD_LOCK(
        for (NSURLSessionTask *task in self.taskRecord) {
            [task cancel];
        }
            [self.taskRecord removeAllObjects];)
}

- (NSNumber *)startDownloadTaskWithManager:(AFHTTPSessionManager *)manager URLRequest:(NSURLRequest *)URLRequest downloadPath:(NSString *)downloadPath downloadProgress:(nullable HDRequestProgressBlock)downloadProgress completion:(HDRequestCompletionBlock)completion {

    // 保证下载路径是文件而不是目录
    NSString *validDownloadPath = downloadPath.copy;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:validDownloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        validDownloadPath = [NSString pathWithComponents:@[validDownloadPath, URLRequest.URL.lastPathComponent]];
    }

    // 若存在文件则移除
    if ([[NSFileManager defaultManager] fileExistsAtPath:validDownloadPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:validDownloadPath error:nil];
    }

    __block NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:URLRequest
        progress:downloadProgress
        destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
            return [NSURL fileURLWithPath:validDownloadPath isDirectory:NO];
        }
        completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
            HDNM_TASKRECORD_LOCK([self.taskRecord removeObjectForKey:@(task.taskIdentifier)];)
            if (completion) {
                completion([HDNetworkResponse responseWithSessionTask:task responseObject:filePath error:error]);
            }
        }];

    NSNumber *taskIdentifier = @(task.taskIdentifier);
    HDNM_TASKRECORD_LOCK(self.taskRecord[taskIdentifier] = task;)
    [task resume];
    return taskIdentifier;
}

- (NSNumber *)startDataTaskWithManager:(AFHTTPSessionManager *)manager URLRequest:(NSURLRequest *)URLRequest retryConfig:(HDNetworkRetryConfig *)retryConfig uploadProgress:(nullable HDRequestProgressBlock)uploadProgress downloadProgress:(nullable HDRequestProgressBlock)downloadProgress completion:(HDRequestCompletionBlock)completion {
    __block NSURLSessionDataTask *task;
    void (^retryBlock)(NSURLResponse *_Nonnull, id _Nullable, NSError *_Nullable) = ^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
        HDNetworkResponse *wrappedResponse = [HDNetworkResponse responseWithSessionTask:task responseObject:responseObject error:error];

        // 判断是否是致命错误，无需重试
        if ([self isErrorFatal:error]) {
            [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"收到严重错误，请查看屏蔽列表，将停止重试，直接触发回调，原因：%@", error.localizedDescription]];
            !completion ?: completion(wrappedResponse);
            return;
        }

        // 判断是否是不需重试的状态码
        NSHTTPURLResponse *taskResponse = (NSHTTPURLResponse *)task.response;
        for (NSNumber *fatalStatusCode in retryConfig.fatalStatusCodes) {
            if (taskResponse.statusCode == fatalStatusCode.integerValue) {
                [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"请求得到状态码 %zd ，在指定不再尝试的 statusCode 数组中，将停止重试，原因：%@", fatalStatusCode.integerValue, error.localizedDescription]];
                !completion ?: completion(wrappedResponse);
                return;
            }
        }

        if (retryConfig.remainingRetryCount > 0) {
            BOOL shouldRetry = retryConfig.shouldRetryBlock && retryConfig.shouldRetryBlock(wrappedResponse);
            if (shouldRetry) {
                [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"外部判断应该重试，还剩：%zd 次", retryConfig.remainingRetryCount]];
                int64_t delay;
                if (retryConfig.isRetryProgressive) {
                    delay = (int64_t)(retryConfig.retryInterval * pow(2, 2 - retryConfig.maxRetryCount));
                } else {
                    delay = retryConfig.retryInterval;
                }
                [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"延迟重试时间：%llu", delay]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"延迟时间 %lld 到，开始发起重试", delay]];
                    [self startDataTaskWithManager:manager URLRequest:URLRequest retryConfig:retryConfig uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completion];
                    retryConfig.remainingRetryCount -= 1;
                });
            } else {
                [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"重试次数还剩：%zd 次，但 shouldRetryBlock 返回 false，将不再重试，回调数据", retryConfig.remainingRetryCount]];
                !completion ?: completion(wrappedResponse);
            }
        } else {
            [self logMessageLogEnabled:retryConfig.logEnabled string:[NSString stringWithFormat:@"重试次数已达最大次数 %zd，将回调数据", retryConfig.maxRetryCount]];

            !completion ?: completion(wrappedResponse);
        }
    };

    task = [manager dataTaskWithRequest:URLRequest
        uploadProgress:^(NSProgress *_Nonnull _uploadProgress) {
            if (uploadProgress) {
                uploadProgress(_uploadProgress);
            }
        }
        downloadProgress:^(NSProgress *_Nonnull _downloadProgress) {
            if (downloadProgress) {
                downloadProgress(_downloadProgress);
            }
        }
        completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
            HDNM_TASKRECORD_LOCK([self.taskRecord removeObjectForKey:@(task.taskIdentifier)];)
            retryBlock(response, responseObject, error);
        }];

    NSNumber *taskIdentifier = @(task.taskIdentifier);
    HDNM_TASKRECORD_LOCK(self.taskRecord[taskIdentifier] = task;)
    [task resume];
    return taskIdentifier;
}

- (void)logMessageLogEnabled:(BOOL)logEnabled string:(NSString *)message, ... {
    if (!logEnabled) {
        return;
    }
#ifdef DEBUG
    NSLog(@"%@", message);
#endif
}

- (BOOL)isErrorFatal:(NSError *)error {
    switch (error.code) {
        case kCFHostErrorHostNotFound:
        case kCFHostErrorUnknown:  // 查询kCFGetAddrInfoFailureKey以获取getaddrinfo返回的值; 在netdb.h中查找
        // HTTP 错误
        case kCFErrorHTTPAuthenticationTypeUnsupported:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPParseFailure:
        case kCFErrorHTTPRedirectionLoopDetected:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFErrorPACFileError:
        case kCFErrorPACFileAuth:
        case kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod:
        // CFURLConnection和CFURLProtocol的错误代码
        case kCFURLErrorUnknown:
        case kCFURLErrorCancelled:
        case kCFURLErrorBadURL:
        case kCFURLErrorUnsupportedURL:
        case kCFURLErrorHTTPTooManyRedirects:
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorUserCancelledAuthentication:
        case kCFURLErrorUserAuthenticationRequired:
        case kCFURLErrorZeroByteResource:
        case kCFURLErrorCannotDecodeRawData:
        case kCFURLErrorCannotDecodeContentData:
        case kCFURLErrorCannotParseResponse:
        case kCFURLErrorInternationalRoamingOff:
        case kCFURLErrorCallIsActive:
        case kCFURLErrorDataNotAllowed:
        case kCFURLErrorRequestBodyStreamExhausted:
        case kCFURLErrorFileDoesNotExist:
        case kCFURLErrorFileIsDirectory:
        case kCFURLErrorNoPermissionsToReadFile:
        case kCFURLErrorDataLengthExceedsMaximum:
        // SSL 错误
        case kCFURLErrorServerCertificateHasBadDate:
        case kCFURLErrorServerCertificateUntrusted:
        case kCFURLErrorServerCertificateHasUnknownRoot:
        case kCFURLErrorServerCertificateNotYetValid:
        case kCFURLErrorClientCertificateRejected:
        case kCFURLErrorClientCertificateRequired:
        case kCFURLErrorCannotLoadFromNetwork:
        // Cookie 错误
        case kCFHTTPCookieCannotParseCookieFile:
        // CFNetServices
        case kCFNetServiceErrorUnknown:
        case kCFNetServiceErrorCollision:
        case kCFNetServiceErrorNotFound:
        case kCFNetServiceErrorInProgress:
        case kCFNetServiceErrorBadArgument:
        case kCFNetServiceErrorCancel:
        case kCFNetServiceErrorInvalid:
        // 特例
        case 101:  // 空地址
        case 102:  // 忽略“帧加载中断”错误
            return YES;

        default:
            break;
    }

    return NO;
}

#pragma mark - public

- (void)cancelNetworkingWithSet:(NSSet<NSNumber *> *)set {
    HDNM_TASKRECORD_LOCK(
        for (NSNumber *identifier in set) {
            NSURLSessionTask *task = self.taskRecord[identifier];
            if (task) {
                [task cancel];
                [self.taskRecord removeObjectForKey:identifier];
            }
        })
}

- (NSNumber *)startNetworkingWithRequest:(HDNetworkRequest *)request uploadProgress:(nullable HDRequestProgressBlock)uploadProgress downloadProgress:(nullable HDRequestProgressBlock)downloadProgress completion:(nullable HDRequestCompletionBlock)completion {

    // 构建网络请求数据
    NSString *method = [request requestMethodString];
    AFHTTPRequestSerializer *serializer = [self requestSerializerForRequest:request];
    NSString *URLString = [request validRequestURLString];
    id parameter = [request validRequestParameter];

    // 构建 URLRequest
    NSError *error = nil;
    NSMutableURLRequest *URLRequest = nil;
    if (request.requestConstructingBody) {
        URLRequest = [serializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:parameter constructingBodyWithBlock:request.requestConstructingBody error:&error];
    } else {
        URLRequest = [serializer requestWithMethod:method URLString:URLString parameters:parameter error:&error];
    }

    if (error) {
        if (completion) completion([HDNetworkResponse responseWithSessionTask:nil responseObject:nil error:error]);
        return nil;
    }

    // 发起网络请求
    AFHTTPSessionManager *manager = [self sessionManagerForRequest:request];
    if (request.downloadPath.length > 0) {
        return [self startDownloadTaskWithManager:manager URLRequest:URLRequest downloadPath:request.downloadPath downloadProgress:downloadProgress completion:completion];
    } else {
        return [self startDataTaskWithManager:manager URLRequest:URLRequest retryConfig:request.retryConfig uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completion];
    }
}

#pragma mark - read info from request

- (AFHTTPRequestSerializer *)requestSerializerForRequest:(HDNetworkRequest *)request {
    AFHTTPRequestSerializer *serializer = request.requestSerializer ?: [AFJSONRequestSerializer serializer];
    if (request.requestTimeoutInterval > 0) {
        serializer.timeoutInterval = request.requestTimeoutInterval;
    }
    return serializer;
}

- (AFHTTPSessionManager *)sessionManagerForRequest:(HDNetworkRequest *)request {
    AFHTTPSessionManager *manager = request.sessionManager;
    if (!manager) {
        static AFHTTPSessionManager *defaultManager = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultManager = [AFHTTPSessionManager new];
            defaultManager.completionQueue = dispatch_queue_create("com.hdnetwork.completionqueue", DISPATCH_QUEUE_CONCURRENT);
        });
        manager = defaultManager;
    }
    AFHTTPResponseSerializer *customSerializer = request.responseSerializer;
    if (customSerializer) manager.responseSerializer = customSerializer;
    return manager;
}

#pragma mark - getter
- (NSMutableDictionary<NSNumber *, NSURLSessionTask *> *)taskRecord {
    if (!_taskRecord) {
        _taskRecord = [NSMutableDictionary dictionary];
    }
    return _taskRecord;
}

@end
