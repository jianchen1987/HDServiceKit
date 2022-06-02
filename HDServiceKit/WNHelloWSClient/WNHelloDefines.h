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
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeConnectd;           ///< 连接成功
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeReady;              ///< ready
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypePing;               ///< ping
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypePong;               ///< pong
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeLogin;              ///< 已登录
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeAck;                ///< ack
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeDataMessage;        ///< 数据消息
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeDisconnect;         ///< 关闭连接
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeReportDeviceInfo;   ///<  上报设备信息
FOUNDATION_EXPORT WNHelloMessageType const WNHelloMessageTypeKickedOutByRemote;  ///< 被远端踢出

#endif /* WNHelloDefines_h */
