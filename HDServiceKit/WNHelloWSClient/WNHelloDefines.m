//
//  WNHelloDefines.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloDefines.h"

WNHelloMessageType const WNHelloMessageTypeConnectd = @"connected";                     ///< 连接成功
WNHelloMessageType const WNHelloMessageTypeReady = @"ready";                            ///< ready
WNHelloMessageType const WNHelloMessageTypePing = @"ping";                              ///< ping
WNHelloMessageType const WNHelloMessageTypePong = @"pong";                              ///< pong
WNHelloMessageType const WNHelloMessageTypeLogin = @"sign-in";                          ///< 已登录
WNHelloMessageType const WNHelloMessageTypeAck = @"send-callback";                      ///< ack
WNHelloMessageType const WNHelloMessageTypeDataMessage = @"event-message";              //数据消息
WNHelloMessageType const WNHelloMessageTypeDisconnect = @"receive-disconnect-event";    ///< 关闭连接
WNHelloMessageType const WNHelloMessageTypeReportDeviceInfo = @"report-device-status";  // 上报设备信息
