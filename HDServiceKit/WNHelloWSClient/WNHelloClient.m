//
//  WNHelloClient.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/17.
//

#import "WNHelloClient.h"
#import <SocketRocket/SocketRocket.h>

@interface WNHelloClient ()
///< ws 服务
@property (nonatomic, strong) SRWebSocket *socket;

@end

@implementation WNHelloClient

#pragma mark - public methods

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    static WNHelloClient *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedClient];
}
/// 初始化sdk
/// @param app 参数
- (void)initWithApp:(WNApp *)app {
}

/// 登陆
/// @param userId 用户id
/// @param completion 成功回调
- (void)signInWithUserId:(NSString *)userId completion:(void (^)(NSString *deviceToken, NSError *error))completion {
}

/// 登出
/// @param userId 用户id
- (void)signOutWithUserId:(NSString *)userId {
}

/// 订阅消息
/// @param listener 接收者
/// @param type 订阅类型
- (void)addListener:(id<WMHelloClientDelegate>)listener forMsgType:(WNMessageType)type {
}

/// 取消订阅
/// @param listener 订阅者
/// @param type 订阅类型
- (void)removeListener:(id<WMHelloClientDelegate>)listener forMsgType:(WNMessageType)type {
}

/// 强制重连
- (void)reconnect {
}

/// 断开连接
- (void)disConnect {
}

#pragma mark - private methods

@end
