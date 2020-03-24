//
//  HDNetworkRequest+Internal.h
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDNetworkRequest ()

/// 请求方法字符串
- (NSString *)requestMethodString;

/// 请求 URL 字符串
- (NSString *)validRequestURLString;

/// 请求参数字符串
- (id)validRequestParameter;

@end

NS_ASSUME_NONNULL_END
