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
    SANetworkRequestCipherModeMD5 = 0,  ///< md5 方案
    SANetworkRequestCipherModeRSA       ///< RSA 方案
};

@interface SANetworkRequest : HDNetworkRequest

/** 用户名 */
@property (nonatomic, copy, nullable) NSString *userName;

/** 渠道，默认 AppStore */
@property (nonatomic, copy, nullable) NSString *channel;

/** 项目名，默认 SuperApp */
@property (nonatomic, copy, nullable) NSString *projectName;

/** 语言，为空将默认使用系统语言 */
@property (nonatomic, copy, nullable) NSString *acceptLanguage;

/** APP 版本，默认传当前工程版本 */
@property (nonatomic, copy) NSString *appVersion;

/// 加密类型
@property (nonatomic, assign) SANetworkRequestCipherMode cipherMode;

/** md5 或者 RSA 方案公有的 key, 默认 chaos */
@property (nonatomic, copy) NSString *key;

/** RSA 方案使用的公钥字符串（与公钥文件二选一） */
@property (nonatomic, copy, nullable) NSString *rsaPublicKeyString;

/** RSA 方案使用的公钥 pem 或者 der 文件路径（与公钥字符串二选一） */
@property (nonatomic, copy, nullable) NSString *rsaPublicKeyFile;

/** 会话 ID */
@property (nonatomic, copy) NSString *tokenId;

/** 请求重试次数，默认 0，即不重试，交由业务控制 */
@property (nonatomic, assign) NSInteger retryCount;

/** 重试间隔，即过多久重试，默认 0，即失败了就重试 */
@property (nonatomic, assign) NSTimeInterval retryInterval;

/** 重试间隔是否步进，默认否，即随着失败次数增加，重试间隔加长，如 1 -> 3 -> 9 */
@property (nonatomic, assign) BOOL isRetryProgressive;

/** 是否需要登录，默认开启，如果需要，会自动添加用户名参数 */
@property (nonatomic, assign) BOOL isNeedLogin;

/** 额外数据，如果需要的话可以设置 */
@property (nonatomic, strong, nullable) id extraData;

@end

NS_ASSUME_NONNULL_END
