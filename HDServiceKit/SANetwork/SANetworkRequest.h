//
//  SANetworkRequest.h
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import <HDServiceKit/HDNetwork.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SANetworkRequestCipherMode) {
    SANetworkRequestCipherModeMD5V1 = 0,  ///< md5  1.0方案
    SANetworkRequestCipherModeRSA = 1,       ///< RSA 方案
    SANetworkRequestCipherModeMD5V2 = 2   ///< md5 2.0 方案
};

@interface SANetworkRequest : HDNetworkRequest

/// 加密类型
@property (nonatomic, assign) SANetworkRequestCipherMode cipherMode;

/** md5 或者 RSA 方案公有的 key, 默认 SuperApp */
@property (nonatomic, copy) NSString *key;

/** RSA 方案使用的公钥字符串（与公钥文件二选一） */
@property (nonatomic, copy, nullable) NSString *rsaPublicKeyString;

/** RSA 方案使用的公钥 pem 或者 der 文件路径（与公钥字符串二选一） */
@property (nonatomic, copy, nullable) NSString *rsaPublicKeyFile;

#pragma mark - 重试参数
/** 请求重试次数，默认 0，即不重试，交由业务控制 */
@property (nonatomic, assign) NSInteger retryCount;

/** 重试间隔，即过多久重试，默认 0，即失败了就重试 */
@property (nonatomic, assign) NSTimeInterval retryInterval;

/** 重试间隔是否步进，默认否，即随着失败次数增加，重试间隔加长，如 1 -> 3 -> 9 */
@property (nonatomic, assign) BOOL isRetryProgressive;

@end

@interface SANetworkRequest (SA_RequestHeaderFieldInterceptor)
/** 预处理请求头*/
- (NSDictionary<NSString *, NSString *> *)sa_preprocessHeaderFields:(NSDictionary<NSString *, NSString *> *)headerFields;

@end

@interface SANetworkRequest (SA_RequestSignInterceptor)
/** 自定义签名算法*/
- (NSString *)sa_customSignatureProcess;

/** 自定义加密因子，参与加签的资源 */
- (NSDictionary *)sa_customSignatureEncryptFactors;

@end

NS_ASSUME_NONNULL_END
