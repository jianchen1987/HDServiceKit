//
//  SANetworkRequest.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "SANetworkRequest.h"
#import "HDNetworkResponse+SuperApp.h"

@implementation SANetworkRequest

#pragma mark - life cycle

- (instancetype)init {
    if (self = [super init]) {
        self.baseURI = @"http://japi.juhe.cn";
        self.requestMethod = HDRequestMethodPOST;

        [self.cacheHandler setShouldCacheBlock:^BOOL(HDNetworkResponse *_Nonnull response) {
            // 检查数据正确性，保证缓存有用的内容
            return YES;
        }];
    }
    return self;
}

#pragma mark - override

- (AFHTTPRequestSerializer *)requestSerializer {
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer new];
    serializer.timeoutInterval = 25;
    return serializer;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *types = [NSMutableSet set];
    [types addObject:@"text/html"];
    [types addObject:@"text/plain"];
    [types addObject:@"application/json"];
    [types addObject:@"text/json"];
    [types addObject:@"text/javascript"];
    serializer.acceptableContentTypes = types;
    return serializer;
}

- (void)start {
    NSLog(@"发起请求：%@", self.requestIdentifier);
    [super start];
}

- (void)hd_redirection:(void (^)(HDRequestRedirection))redirection response:(HDNetworkResponse *)response {

    // 处理错误的状态码
    if (response.error) {
        HDResponseErrorType errorType;
        switch (response.error.code) {
            case NSURLErrorTimedOut:
                errorType = HDResponseErrorTypeTimedOut;
                break;
            case NSURLErrorCancelled:
                errorType = HDResponseErrorTypeCancelled;
                break;
            default:
                errorType = HDResponseErrorTypeNoNetwork;
                break;
        }
        response.errorType = errorType;
    }

    // 自定义重定向，根据实际业务修改逻辑
    NSDictionary *responseDic = response.responseObject;
    if ([[NSString stringWithFormat:@"%@", responseDic[@"error_code"]] isEqualToString:@"2"]) {
        redirection(HDRequestRedirectionFailure);
        response.errorType = HDResponseErrorTypeServerError;
        return;
    }
    redirection(HDRequestRedirectionSuccess);
}

- (NSDictionary *)hd_preprocessParameter:(NSDictionary *)parameter {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:parameter ?: @{}];
    // 给每一个请求，添加额外的参数
    tmp[@"termType"] = @"iOS";
    return tmp;
}

- (NSString *)hd_preprocessURLString:(NSString *)URLString {
    return URLString;
}

- (void)hd_preprocessSuccessInChildThreadWithResponse:(HDNetworkResponse *)response {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:response.responseObject];
    // 为每一个返回结果添加字段
    res[@"timestamp"] = @([[NSDate date] timeIntervalSince1970]);
    response.responseObject = res;
    response.extraData = [HDRspModel modelWithDict:res];
}

- (void)hd_preprocessSuccessInMainThreadWithResponse:(HDNetworkResponse *)response {
}

- (void)hd_preprocessFailureInChildThreadWithResponse:(HDNetworkResponse *)response {
}

- (void)hd_preprocessFailureInMainThreadWithResponse:(HDNetworkResponse *)response {
}

@end
