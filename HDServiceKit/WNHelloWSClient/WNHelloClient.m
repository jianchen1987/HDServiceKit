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
#import "WNHelloDownloadMsg.h"
#import "WNHelloLoginMsg.h"
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
- (void)initWithApp:(WNApp *)app {
    self.app = app;
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

- (void)sendAckWithMessageId:(NSString *)messageId {
    if (self.socket.readyState != SR_OPEN) {
        return;
    }

    if (HDIsStringEmpty(messageId)) {
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
        WNHelloConnectedMsg *msg = [[WNHelloConnectedMsg alloc] initWithMessage:string];
        HDLog(@"连接成功!\nsid:%@\npingInterval:%f\npingTimeout:%f", msg.sid, msg.pingInterval, msg.pingTimeout);

        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        // 根据配置初始化定时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:msg.pingInterval target:self selector:@selector(sendPing) userInfo:nil repeats:YES];

        HDLog(@"send:40/worker/send?userId=%@&appid=%@&deviceId=%@", self.currentUser, self.app.appId, [HDDeviceInfo getUniqueId]);
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
        [self sendAckWithMessageId:msg.messageID];
    } else if ([downloadMsg.msgType isEqualToString:WNHelloMessageTypeDataMessage]) {
        // 有消息
        [self sendAckWithMessageId:downloadMsg.messageID];

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
    HDLog(@"连接关闭:%@", reason);
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
