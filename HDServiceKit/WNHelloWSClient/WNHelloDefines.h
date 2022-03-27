//
//  WNHelloDefines.h
//  Pods
//
//  Created by seeu on 2022/3/25.
//

#ifndef WNHelloDefines_h
#define WNHelloDefines_h

///消息类型
typedef NSString *WNHelloMessageType NS_STRING_ENUM;
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeConnectd;  ///< 连接成功
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeReady;     ///< ready
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypePing;      ///< ping
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypePong;      ///< pong
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeLogin;     ///< 已登录
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeAck;       ///< ack
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeMessage;   ///< 业务消息

#endif /* WNHelloDefines_h */
