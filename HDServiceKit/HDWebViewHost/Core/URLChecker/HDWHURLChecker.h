//
//  HDWHURLChecker.h
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2016 smilly.co. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  定义授权的类型
 */
typedef NS_ENUM(NSUInteger, HDWHAuthorizationType) {

    HDWHAuthorizationTypeSchema,
    /**
     *  是否容许调用webviewhost接口
     */
    HDWHAuthorizationTypeWebViewHost
};

@interface HDWHURLChecker : NSObject

+ (instancetype)sharedManager;

/**
 *  检查是否容许url访问authype的接口
 *
 *  @param url      NSURL对象
 *  @param authType 授权类型的枚举
 *
 *  @return 是否容许，yes表示容许
 */
- (BOOL)checkURL:(NSURL *)url forAuthorizationType:(HDWHAuthorizationType)authType;

/// 添加白名单
/// @param whiteList 白名单列表
/// @param authType 授权类型
- (BOOL)addWhiteList:(NSArray<NSString *> *)whiteList forAuthorizationType:(HDWHAuthorizationType)authType;

@end
