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

        // 检查数据正确性，保证缓存有用的内容
        /*
        self.cacheHandler.shouldWriteCacheBlock = ^BOOL(HDNetworkResponse *_Nonnull response) {
            HDRspModel *rspModel = response.extraData;
            return [rspModel.code isEqualToString:SAResponseTypeSuccess];
        };
        */

        // 是否使用缓存，比如判断时间间隔
        /*
        self.cacheHandler.shouldReadCacheBlock = ^BOOL(HDNetworkResponse *_Nonnull response) {
            HDRspModel *rspModel = response.extraData;
            NSTimeInterval minus = NSDate.date.timeIntervalSince1970 - rspModel.timeStamp;
            return minus < 60;
        };
        */
    }
    return self;
}

#pragma mark - 签名
/// 获取签名
- (NSString *)getSignatureWithRequestTime:(NSString *)requestTime deviceId:(NSString *)deviceId {

    NSMutableDictionary *finalParams = [NSMutableDictionary dictionary];
    [finalParams addEntriesFromDictionary:self.requestParameter];
    [finalParams addEntriesFromDictionary:self.extraParams];
    [finalParams addEntriesFromDictionary:@{@"requestTm": requestTime,
                                            @"deviceId": deviceId}];

    NSArray *keys = [[finalParams allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return (NSComparisonResult)[str1 compare:str2 options:NSNumericSearch];
    }];

    NSArray *kvPairs = [keys mapObjectsUsingBlock:^id _Nonnull(id _Nonnull key, NSUInteger idx) {
        id value = [finalParams valueForKey:key];
        return [NSString stringWithFormat:@"%@=%@", key, value];
    }];
    NSString *oriSign = [kvPairs componentsJoinedByString:@"&"];
    NSString *signature = @"";
    if (self.cipherMode == SANetworkRequestCipherModeMD5) {
        signature = oriSign.hd_md5;
    } else if (self.cipherMode == SANetworkRequestCipherModeRSA) {
        if (HDIsStringNotEmpty(self.rsaPublicKeyString)) {
            signature = [RSACipher encrypt:oriSign publicKey:self.rsaPublicKeyString];
        } else if (HDIsStringNotEmpty(self.rsaPublicKeyFile)) {
            signature = [RSACipher encrypt:oriSign keyFilePath:self.rsaPublicKeyFile];
        }
    }
    return signature;
}

/** 对数组或者字典嵌套递归输出用于加密的字符串 */
- (NSString *)stringForRecursiveNestedObject:(id)object {
    NSString *jsonStr = object;

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
                jsonStr = [jsonStr stringByAppendingString:@", "];
            }
            id value = [self stringForRecursiveNestedObject:array[i]];
            jsonStr = [jsonStr stringByAppendingString:[NSString stringWithFormat:@"%@", value]];
        }
        jsonStr = [jsonStr stringByAppendingString:@"]"];
    }
    return jsonStr;
}

- (NSDictionary *)extraParams {
    NSMutableDictionary *extraParams = [NSMutableDictionary dictionaryWithCapacity:2];
    if (self.isNeedLogin && HDIsStringNotEmpty(self.userName)) {
        extraParams[@"loginName"] = self.userName;
    }
    return extraParams;
}

#pragma mark - override
- (AFHTTPRequestSerializer *)requestSerializer {
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer new];
    // 设置 HTTPHeaderField
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [fmt setLocale:[NSLocale currentLocale]];
    NSString *requestTm = [fmt stringFromDate:NSDate.date];
    NSString *deviceId = HDDeviceInfo.getUniqueId;
    NSMutableDictionary<NSString *, NSString *> *headerFieldsDict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"requestTm": requestTm,
        @"termTyp": @"IOS",
        @"deviceId": deviceId,
        @"signVer": @"1.0",
        @"sign": [self getSignatureWithRequestTime:requestTm deviceId:deviceId],
        @"type": self.cipherMode == SANetworkRequestCipherModeMD5 ? @"md5" : @"rsa",
        @"Accept-Language": HDIsStringNotEmpty(self.acceptLanguage) ? self.acceptLanguage : HDDeviceInfo.getDeviceLanguage,
        @"appVersion": HDIsStringNotEmpty(self.appVersion) ? self.appVersion : HDDeviceInfo.appVersion,
        @"channel": HDIsStringNotEmpty(self.channel) ? self.channel : @"AppStore",
        @"appId": HDIsStringNotEmpty(self.appID) ? self.appID : @"SuperApp",
        @"projectName": HDIsStringNotEmpty(self.projectName) ? self.projectName : @"SuperApp",
        @"Content-Type": @"application/json",
    }];
    if (self.isNeedLogin && HDIsStringNotEmpty(self.accessToken)) {
        headerFieldsDict[@"accessToken"] = self.accessToken;
    }
    [headerFieldsDict enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
        [serializer setValue:obj forHTTPHeaderField:key];
    }];
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

- (NSDictionary *)hd_preprocessParameter:(NSDictionary *)parameter {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameter ?: @{}];
    [params addEntriesFromDictionary:self.extraParams];
    return params;
}
@end
