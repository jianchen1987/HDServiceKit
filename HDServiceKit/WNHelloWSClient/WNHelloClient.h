//
//  WNHelloClient.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/17.
//

#import "WNHelloDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *WNHelloEvent NS_STRING_ENUM;
FOUNDATION_EXPORT WNHelloEvent const WNHelloEventDataMessage;   ///< 数据消息
FOUNDATION_EXPORT WNHelloEvent const WNHelloEventNotification;  ///< 通知

@protocol WMHelloClientListenerDelegate <NSObject>

@optional
- (void)didReciveMessage:(id)message forEvent:(WNHelloEvent)type;

@end

@protocol WNHelloClientDelegate <NSObject>

@required
- (void)loginSuccess:(NSString *)deviceToken;

@optional
- (void)helloClientError:(NSError *)error;
- (void)helloClientClosedWithReason:(NSString *_Nullable)reason;

@end

@class WNApp;

@interface WNHelloClient : NSObject

- (instancetype)init __attribute__((unavailable("Use +[WNHelloClient sharedClient] instead.")));

+ (instancetype)sharedClient;

///< 代理
@property (nonatomic, assign) id<WNHelloClientDelegate> delegate;

/// 初始化sdk
/// @param app 参数
- (void)initWithApp:(WNApp *)app host:(NSString *_Nonnull)host;

/// 登陆
/// @param userId 用户id
/// @param completion 成功回调
- (void)signInWithUserId:(NSString *)userId;

/// 登出
/// @param userId 用户id
- (void)signOutWithUserId:(NSString *)userId;

/// 订阅消息
/// @param listener 接收者
/// @param type 订阅类型
- (void)addListener:(id<WMHelloClientListenerDelegate>)listener forEvent:(WNHelloEvent)type;

/// 取消订阅
/// @param listener 订阅者
/// @param type 订阅类型
- (void)removeListener:(id<WMHelloClientListenerDelegate>)listener forEvent:(WNHelloEvent)type;

/// 强制重连
- (void)reconnect;

/// 断开连接
- (void)disConnect;

@end

NS_ASSUME_NONNULL_END
