//
//  WNHelloLoginMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/27.
//

#import "WNHelloDownloadMsg.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNHelloLoginMsg : WNHelloDownloadMsg

///< DeviceToken
@property (nonatomic, copy) NSString *token;
///< 过期时间
@property (nonatomic, assign) NSTimeInterval expiredTime;

@end

NS_ASSUME_NONNULL_END
