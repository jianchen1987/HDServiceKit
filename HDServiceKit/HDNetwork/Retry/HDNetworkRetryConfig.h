//
//  HDNetworkRetryConfig.h
//  HDServiceKit
//
//  Created by VanJay on 2020/4/3.
//

#import "HDNetworkResponse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^HDNetworkRetryConfigShouldRetryBlock)(HDNetworkResponse *response);

@interface HDNetworkRetryConfig : NSObject
/** 请求重试次数，默认 0，即不重试，交由业务控制 */
@property (nonatomic, assign) NSInteger maxRetryCount;
/** 剩下的重试次数，作为标志，在每次赋值 maxRetryCount 会将该值重新赋值为 maxRetryCount */
@property (nonatomic, assign) NSInteger remainingRetryCount;
/** 重试间隔，即过多久重试，默认 0，即失败了就重试 */
@property (nonatomic, assign) NSTimeInterval retryInterval;
/** 重试间隔是否步进，随着失败次数增加，重试间隔加长，如0 -> 1 -> 2 -> 4 -> 8，默认否 */
@property (nonatomic, assign) BOOL isRetryProgressive;
/// 判断错误状态码数组，如果是这些状态码，不重试，直接回调失败，默认 nil
@property (nonatomic, copy) NSArray<NSNumber *> *_Nullable fatalStatusCodes;
/// 是否重试，优先级低于 fatalError 和 fatalStatusCodes
@property (nonatomic, copy, nullable) HDNetworkRetryConfigShouldRetryBlock shouldRetryBlock;
/// 是否打开日志，默认 YES
@property (nonatomic, assign) BOOL logEnabled;
@end

NS_ASSUME_NONNULL_END
