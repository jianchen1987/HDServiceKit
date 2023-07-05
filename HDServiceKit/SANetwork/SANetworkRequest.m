//
//  SANetworkRequest.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "SANetworkRequest.h"
#import "HDDeviceInfo.h"
#import "RSACipher.h"
#import <HDKitCore/HDCommonDefines.h>
#import <HDKitCore/NSArray+HDKitCore.h>

@interface SANetworkRequest ()
@end

@implementation SANetworkRequest

#pragma mark - life cycle

- (instancetype)init {
    if (self = [super init]) {
        self.baseURI = @"http://japi.juhe.cn";
        self.requestMethod = HDRequestMethodPOST;
        self.cipherMode = SANetworkRequestCipherModeMD5V1;
    }
    return self;
}

#pragma mark - 签名
/// 获取签名
- (NSString *)getSignatureWithEncryptFactors:(NSDictionary *)factors {

    NSMutableDictionary *finalParams = [NSMutableDictionary dictionary];
    [finalParams addEntriesFromDictionary:[self hd_preprocessParameter:self.requestParameter]];
    [finalParams addEntriesFromDictionary:factors];
    if([self respondsToSelector:@selector(sa_customSignatureEncryptFactors)]) {
        [finalParams addEntriesFromDictionary:[self sa_customSignatureEncryptFactors]];
    }

    NSArray *keys = [[finalParams allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return (NSComparisonResult)[str1 compare:str2 options:NSNumericSearch];
    }];

    NSArray *kvPairs = [keys mapObjectsUsingBlock:^id _Nonnull(id _Nonnull key, NSUInteger idx) {
        id value = [finalParams valueForKey:key];
        return [NSString stringWithFormat:@"%@=%@", key, [self stringForRecursiveNestedObject:value]];
    }];
    NSString *oriSign = [kvPairs componentsJoinedByString:@"&"];
    NSString *signature = @"";
//    HDLog(@"[%@][%@] 参与签名的参数:%@", self.identifier, self.requestURI, finalParams);
//    HDLog(@"[%@][%@] orignature:%@", self.identifier, self.requestURI, oriSign);
    if (self.cipherMode == SANetworkRequestCipherModeMD5V1 || self.cipherMode == SANetworkRequestCipherModeMD5V2) {
        signature = oriSign.hd_md5;
    } else if (self.cipherMode == SANetworkRequestCipherModeRSA) {
        if (HDIsStringNotEmpty(self.rsaPublicKeyString)) {
            signature = [RSACipher encrypt:oriSign publicKey:self.rsaPublicKeyString];
        } else if (HDIsStringNotEmpty(self.rsaPublicKeyFile)) {
            signature = [RSACipher encrypt:oriSign keyFilePath:self.rsaPublicKeyFile];
        }
    }
//    HDLog(@"[%@][%@] signature:%@", self.identifier, self.requestURI, signature);
    return signature;
}

/** 对数组或者字典嵌套递归输出用于加密的字符串 */
- (NSString *)stringForRecursiveNestedObject:(id)object {
    NSString *jsonStr = @"";

    if ([object isKindOfClass:NSDictionary.class]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        NSArray *keys = [[dictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
            return (NSComparisonResult)[str1 compare:str2 options:NSNumericSearch];
        }];
        NSMutableString *oriSig = [[NSMutableString alloc] init];
        [oriSig appendString:@"{"];
        for (int i = 0; i < dictionary.count; i++) {
            [oriSig appendString:keys[i]];
            [oriSig appendString:@"="];
            id value = [dictionary objectForKey:keys[i]];

            value = [self stringForRecursiveNestedObject:value];
            [oriSig appendString:[NSString stringWithFormat:@"%@", value]];
            if (i < keys.count - 1) {
                [oriSig appendString:@"&"];
            }
        }
        [oriSig appendString:@"}"];
        jsonStr = oriSig;
    } else if ([object isKindOfClass:NSArray.class]) {
        jsonStr = @"[";
        NSArray *array = (NSArray *)object;
        for (NSInteger i = 0; i < array.count; ++i) {
            if (i != 0) {
                jsonStr = [jsonStr stringByAppendingString:@","];
            }
            id value = [self stringForRecursiveNestedObject:array[i]];
            jsonStr = [jsonStr stringByAppendingString:[NSString stringWithFormat:@"%@", value]];
        }
        jsonStr = [jsonStr stringByAppendingString:@"]"];
        
    } else if([object isKindOfClass:NSNumber.class]) {
        jsonStr = [jsonStr stringByAppendingString:[(NSNumber *)object stringValue]];
        
    } else {
        jsonStr = object;
    }
    return jsonStr;
}

- (NSDictionary<NSString *, NSString *> *)sa_preprocessHeaderFields:(NSDictionary<NSString *, NSString *> *)headerFields {
    return headerFields;
}

#pragma mark - setter
- (void)setRetryCount:(NSInteger)retryCount {
    _retryCount = retryCount;
    self.retryConfig.maxRetryCount = retryCount;
}

- (void)setRetryInterval:(NSTimeInterval)retryInterval {
    _retryInterval = retryInterval;
    self.retryConfig.retryInterval = retryInterval;
}

- (void)setIsRetryProgressive:(BOOL)isRetryProgressive {
    _isRetryProgressive = isRetryProgressive;
    self.retryConfig.isRetryProgressive = isRetryProgressive;
}

#pragma mark - override
- (AFHTTPRequestSerializer *)requestSerializer {
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer new];
    // 设置 HTTPHeaderField
    NSString *requestTm = [NSString stringWithFormat:@"%.0f", [[NSDate new] timeIntervalSince1970] * 1000.0];
    NSString *deviceId = HDDeviceInfo.getUniqueId;
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"ddHHmmss"];
    [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSString *traceId = [NSString stringWithFormat:@"%@%04d", [fmt stringFromDate:[NSDate new]], arc4random() % 10000];
    
    NSMutableDictionary<NSString *, NSString *> *headerFieldsDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"requestTm": requestTm,
        @"deviceId": deviceId,
        @"traceId" : traceId,
        @"Content-Type": @"application/json",
    }];
    
    if(self.cipherMode == SANetworkRequestCipherModeMD5V2) {
        [headerFieldsDict addEntriesFromDictionary:@{@"signVer": @"2.0"}];
    } else {
        [headerFieldsDict addEntriesFromDictionary:@{@"signVer": @"1.0"}];
    }
    
    [headerFieldsDict addEntriesFromDictionary:[self sa_preprocessHeaderFields:headerFieldsDict]];
    
    if ([self respondsToSelector:@selector(sa_customSignatureProcess)]) {
        [headerFieldsDict addEntriesFromDictionary:@{
            @"sign": [self sa_customSignatureProcess]
        }];
    } else {
        if(self.cipherMode == SANetworkRequestCipherModeMD5V2) {
            [headerFieldsDict addEntriesFromDictionary:@{ @"sign": [self getSignatureWithEncryptFactors: @{ @"requestTm" : requestTm, @"deviceId" : deviceId, @"traceId" : traceId }] }];
        } else {
            [headerFieldsDict addEntriesFromDictionary:@{ @"sign": [self getSignatureWithEncryptFactors: @{ @"requestTm" : requestTm, @"deviceId" : deviceId}] }];
        }
    }

    [headerFieldsDict enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        [serializer setValue:obj forHTTPHeaderField:key];
    }];
    serializer.HTTPShouldHandleCookies = NO;
    
    return serializer;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    static AFHTTPResponseSerializer *serializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *types = [NSMutableSet set];
        [types addObject:@"text/html"];
        [types addObject:@"text/plain"];
        [types addObject:@"application/json"];
        [types addObject:@"text/json"];
        [types addObject:@"text/javascript"];
        serializer.acceptableContentTypes = types;
    });
    return serializer;
}
@end
