//
//  WNHelloConnectedMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/27.
//

#import "WNHelloDownloadMsg.h"

NS_ASSUME_NONNULL_BEGIN

//0{"sid":"jKgT1aCOCt4yGuZuAAAH","upgrades":[],"pingInterval":5000,"pingTimeout":10000}
@interface WNHelloConnectedMsg : WNHelloDownloadMsg
///< 会话ID
@property (nonatomic, copy) NSString *sid;
///< 心跳间隔
@property (nonatomic, assign) NSTimeInterval pingInterval;
///< 心跳超时时间
@property (nonatomic, assign) NSTimeInterval pingTimeout;
@end

NS_ASSUME_NONNULL_END
