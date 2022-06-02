//
//  WNHelloClient.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/17.
//

#import "WNHelloClient.h"
#import "HDDeviceInfo.h"
#import "WNHelloAckMsg.h"
#import "WNHelloConnectedMsg.h"
#import "WNHelloDisconnectMsg.h"
#import "WNHelloDownloadMsg.h"
#import "WNHelloLoginMsg.h"
#import "WNHelloReportDeviceInfoMsg.h"
#import <HDKitCore/HDKitCore.h>
#import <HDKitCore/WNApp.h>
#import <HDVendorKit/WNFMDBManager.h>
#import <SocketRocket/SocketRocket.h>

WNHelloEvent const WNHelloEventDataMessage = @"event.dataMsg";        ///< 数据消息
WNHelloEvent const WNHelloEventNotification = @"event.notification";  ///< 通知

@interface WNHelloClient () <SRWebSocketDelegate>
///< ws 服务
@property (nonatomic, strong) SRWebSocket *socket;
///< 心跳定时器
@property (nonatomic, strong) NSTimer *timer;

///< 应用配置
@property (nonatomic, strong) WNApp *app;
///< 主机地址
@property (nonatomic, copy) NSString *host;
///< 当前用户
@property (nonatomic, copy) NSString *currentUser;

///< 订阅者
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<id<WMHelloClientListenerDelegate>> *> *listeners;

///< 数据库
@property (nonatomic, strong) WNFMDBManager *dbManager;

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
- (void)initWithApp:(WNApp *)app host:(NSString *_Nonnull)host {
    self.app = app;
    self.host = [host copy];
}

/// 登陆
/// @param userId 用户id
/// @param completion 成功回调
- (void)signInWithUserId:(NSString *)userId {
    if (self.socket && self.socket.readyState == SR_OPEN) {
        [self.socket close];
        self.socket = nil;
    }
    self.currentUser = userId;

    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.wownow.helloWebSocket"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:NULL]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db", userId]];
    self.dbManager = [[WNFMDBManager alloc] initWithPath:filePath];

    self.socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/?userId=%@&appid=%@&deviceId=%@&EIO=3&transport=websocket", self.host, userId, self.app.appId, [HDDeviceInfo getUniqueId]]]];
    self.socket.delegate = self;
    [self.socket open];
}

/// 登出
/// @param userId 用户id
- (void)signOutWithUserId:(NSString *)userId {

    if (self.socket.readyState != SR_OPEN) {
        return;
    }

    [self sendMessage:[WNHelloDisconnectMsg disconnectWithReason:@"sign out"]];
    [self.socket closeWithCode:200 reason:@"sign out"];
    [self.timer invalidate];
    self.timer = nil;

    self.currentUser = @"";
}

/// 订阅消息
/// @param listener 接收者
/// @param event 订阅事件
- (void)addListener:(id<WMHelloClientListenerDelegate>)listener forEvent:(WNHelloEvent)event {
    NSMutableArray<id<WMHelloClientListenerDelegate>> *tmp = [self.listeners objectForKey:event];
    if (tmp.count) {
        [tmp addObject:listener];
    } else {
        tmp = [[NSMutableArray alloc] initWithCapacity:5];
        [tmp addObject:listener];
        [self.listeners setObject:tmp forKey:event];
    }
}

/// 取消订阅
/// @param listener 订阅者
/// @param event 订阅事件
- (void)removeListener:(id<WMHelloClientListenerDelegate>)listener forEvent:(nonnull WNHelloEvent)event {
    NSMutableArray<id<WMHelloClientListenerDelegate>> *tmp = [self.listeners objectForKey:event];
    if (tmp.count) {
        [tmp removeObject:listener];
    }
}

/// 强制重连
- (void)reconnect {
    if (HDIsStringNotEmpty(self.currentUser)) {
        [self signInWithUserId:self.currentUser];
    }
}

/// 断开连接
- (void)disConnect {

    if (self.socket.readyState != SR_OPEN) {
        return;
    }

    [self sendMessage:[WNHelloDisconnectMsg disconnectWithReason:@"enter background"]];

    [self.socket closeWithCode:200 reason:@"enter background"];
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - private methods

- (void)sendPing {
    if (self.socket.readyState != SR_OPEN) {
        return;
    }
    [self.socket sendString:@"2" error:nil];
}

- (void)sendMessage:(id<WNHelloMessageProtocol>)msg {
    if (self.socket.readyState != SR_OPEN) {
        return;
    }

    if (msg && [msg respondsToSelector:@selector(toString)]) {
        HDLog(@"发送消息:%@", [msg toString]);
        [self.socket sendString:[msg toString] error:nil];
    }
}

#pragma mark - Delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    //    HDLog(@"连接建立啦！%@/?userId=%@&appid=%@&deviceId=%@&EIO=3&transport=websocket", self.host, self.currentUser, self.app.appId, [HDDeviceInfo getUniqueId]);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string {
    HDLog(@"收到服务端消息:%@", string);
    WNHelloDownloadMsg *downloadMsg = [[WNHelloDownloadMsg alloc] initWithMessage:string];

    if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeConnectd]) {
        WNHelloConnectedMsg *msg = [[WNHelloConnectedMsg alloc] initWithMessage:string];

        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        // 根据配置初始化定时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:msg.pingInterval target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.socket sendString:[NSString stringWithFormat:@"40/worker/send?userId=%@&appid=%@&deviceId=%@", self.currentUser, self.app.appId, [HDDeviceInfo getUniqueId]] error:nil];

    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeReady]) {
        //发送心跳
        [self.timer fire];
    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeLogin]) {
        // 已登录
        WNHelloLoginMsg *msg = [[WNHelloLoginMsg alloc] initWithMessage:string];
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginSuccess:)]) {
            [self.delegate loginSuccess:msg.token];
        }
        [self sendMessage:[WNHelloAckMsg ackMessageWithId:msg.messageID]];

    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeReportDeviceInfo]) {
        // 上报设备信息
        [self sendMessage:[WNHelloReportDeviceInfoMsg new]];

    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeKickedOutByRemote]) {
        // 被远端踢下线，不需要重新连接
        [self.socket closeWithCode:300 reason:@"KICK by remote"];
        [self.timer invalidate];
        self.timer = nil;

    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeDataMessage]) {
        // 有消息
        [self sendMessage:[WNHelloAckMsg ackMessageWithId:downloadMsg.messageID]];

        NSArray<id<WNHelloClientDelegate>> *result = [self.dbManager searchWithObject:downloadMsg];
        if (result.count) {
            HDLog(@"重复消息:%@", downloadMsg.messageID);
            return;
        } else {
            if ([self.dbManager insertObject:downloadMsg]) {
                HDLog(@"入库成功");
            } else {
                HDLog(@"入库失败");
            }
        }

        NSMutableArray<id<WMHelloClientListenerDelegate>> *tmp = [self.listeners objectForKey:WNHelloEventDataMessage];
        for (int i = 0; i < tmp.count; i++) {
            id<WMHelloClientListenerDelegate> listener = tmp[i];
            if (listener && [listener respondsToSelector:@selector(didReciveMessage:forEvent:)]) {
                [listener didReciveMessage:downloadMsg forEvent:WNHelloEventDataMessage];
            }
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    HDLog(@"异常:[%zd]%@", error.code, error.localizedDescription);
    [self.timer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(helloClientError:)]) {
        [self.delegate helloClientError:error];
    }
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
    HDLog(@"连接关闭:(%d)%@", code, reason);
    [self.timer invalidate];
    if (self.delegate && [self.delegate respondsToSelector:@selector(helloClientClosedWithReason:)]) {
        [self.delegate helloClientClosedWithReason:reason];
    }
}

- (NSMutableDictionary<NSString *, NSArray<id<WMHelloClientListenerDelegate>> *> *)listeners {
    if (!_listeners) {
        _listeners = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _listeners;
}

@end
