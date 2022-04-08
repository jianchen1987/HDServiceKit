//
//  WNHelloBaseMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloDefines.h"
#import <Foundation/Foundation.h>
#import <HDKitCore/HDKitCore.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WNHelloMessageProtocol <NSObject>

@required
- (instancetype)initWithMessage:(NSString *)text;
- (NSString *_Nullable)toString;

@end

/// 消息基类
@interface WNHelloBaseMsg : NSObject <WNHelloMessageProtocol>

///< 消息类型指令
@property (nonatomic, copy) NSString *command;
///< 命名空间
@property (nonatomic, copy) NSString *nameSpace;
///< 消息类型
@property (nonatomic, copy) NSString *msgType;
///< 参数
@property (nonatomic, strong) NSDictionary *data;
///< 发送时间
@property (nonatomic, copy) NSString *sendTime;
///< 校验值
@property (nonatomic, copy) NSString *checksum;

// 解析
- (instancetype)initWithMessage:(NSString *)text;
// 组装
- (NSString *_Nullable)toString;

@end

NS_ASSUME_NONNULL_END
