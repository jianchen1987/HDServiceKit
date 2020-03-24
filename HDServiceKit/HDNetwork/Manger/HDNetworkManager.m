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

- (NSNumber *)startDataTaskWithManager:(AFHTTPSessionManager *)manager URLRequest:(NSURLRequest *)URLRequest uploadProgress:(nullable HDRequestProgressBlock)uploadProgress downloadProgress:(nullable HDRequestProgressBlock)downloadProgress completion:(HDRequestCompletionBlock)completion {

    __block NSURLSessionDataTask *task = [manager dataTaskWithRequest:URLRequest
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
            if (completion) {
                completion([HDNetworkResponse responseWithSessionTask:task responseObject:responseObject error:error]);
            }
        }];

    NSNumber *taskIdentifier = @(task.taskIdentifier);
    HDNM_TASKRECORD_LOCK(self.taskRecord[taskIdentifier] = task;)
    [task resume];
    return taskIdentifier;
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
        return [self startDataTaskWithManager:manager URLRequest:URLRequest uploadProgress:uploadProgress downloadProgress:downloadProgress completion:completion];
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
        });
        manager = defaultManager;
    }
    manager.completionQueue = dispatch_queue_create("com.hdnetwork.completionqueue", DISPATCH_QUEUE_CONCURRENT);
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
