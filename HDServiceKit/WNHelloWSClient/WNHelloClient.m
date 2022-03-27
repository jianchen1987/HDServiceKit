//
//  WNHelloClient.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/17.
//

#import "WNHelloClient.h"
#import "HDDeviceInfo.h"
#import "WNHelloAckMsg.h"
#import "WNHelloDownloadMsg.h"
#import <HDKitCore/HDLog.h>
#import <HDKitCore/WNApp.h>
#import <SocketRocket/SocketRocket.h>

@interface WNHelloClient () <SRWebSocketDelegate>
///< ws 服务
@property (nonatomic, strong) SRWebSocket *socket;
///< 心跳定时器
@property (nonatomic, strong) NSTimer *timer;

///< 应用配置
@property (nonatomic, strong) WNApp *app;
///< 当前用户
@property (nonatomic, copy) NSString *currentUser;

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
    self.app = app;
}

/// 登陆
/// @param userId 用户id
/// @param completion 成功回调
- (void)signInWithUserId:(NSString *)userId completion:(void (^)(NSString *deviceToken, NSError *error))completion {
    if (self.socket && self.socket.readyState == SR_OPEN) {
        [self.socket close];
        self.socket = nil;
    }
    self.currentUser = userId;
    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"wss://hello-sit.lifekh.com/hello-worker/?userId=%@&appid=%@&deviceId=%@&EIO=3&transport=websocket", userId, self.app.appId, [HDDeviceInfo getUniqueId]]]];
    self.socket.delegate = self;
    [self.socket open];
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

- (void)sendPing {
    if (self.socket.readyState != SR_OPEN) {
        return;
    }
    HDLog(@"send ping: 2");
    [self.socket sendString:@"2" error:nil];
}

- (void)sendAckWithMessageId:(NSString *)messageId {
    if (self.socket.readyState != SR_OPEN) {
        return;
    }
    WNHelloAckMsg *ack = [[WNHelloAckMsg alloc] initWithMessageID:messageId];
    [self.socket sendString:[ack toString] error:nil];
}

#pragma mark - Delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    HDLog(@"连接建立啦！wss://hello-sit.lifekh.com/hello-worker/?userId=%@&appid=%@&deviceId=%@&EIO=3&transport=websocket", self.currentUser, self.app.appId, [HDDeviceInfo getUniqueId]);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string {
    HDLog(@"收到服务端消息:%@", string);
    WNHelloDownloadMsg *downloadMsg = [[WNHelloDownloadMsg alloc] initWithMessage:string];

    if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeConnectd]) {

        HDLog(@"send:40/worker/send?userId=%@&appid=%@&deviceId=%@", self.currentUser, self.app.appId, [HDDeviceInfo getUniqueId]);
        [self.socket sendString:[NSString stringWithFormat:@"40/worker/send?userId=%@&appid=%@&deviceId=%@", self.currentUser, self.app.appId, [HDDeviceInfo getUniqueId]] error:nil];
    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeReady]) {
        //发送心跳
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
        [self.timer fire];
    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeLogin]) {
        // 已登录
    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeMessage]) {
        // 有消息
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data {
    HDLog(@"收到服务端数据:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    HDLog(@"异常:[%d]%@", error.code, error.localizedDescription);
    [self.timer invalidate];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
    HDLog(@"连接关闭:%@", reason);
    [self.timer invalidate];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(nullable NSData *)pongData {
    HDLog(@"收到服务端pong:%@", [[NSString alloc] initWithData:pongData encoding:NSUTF8StringEncoding]);
}

@end
