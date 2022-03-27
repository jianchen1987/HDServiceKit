//
//  WNHelloBaseMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloDefines.h"
#import <Foundation/Foundation.h>
#import <HDKitCore/HDLog.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WNHelloMessageDelegate <NSObject>

@required
- (instancetype)initWithMessage:(NSString *)text;
- (NSString *_Nullable)toString;

@end

/// 消息基类
@interface WNHelloBaseMsg : NSObject <WNHelloMessageDelegate>

///< 消息类型指令
@property (nonatomic, copy) NSString *command;
///< 命名空间
@property (nonatomic, copy) NSString *nameSpace;
///< 消息类型
@property (nonatomic, copy) NSString *msgType;
///< 参数
@property (nonatomic, strong) NSDictionary *data;

- (instancetype)initWithMessage:(NSString *)text;
- (NSString *_Nullable)toString;

@end

NS_ASSUME_NONNULL_END
