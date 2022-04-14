//
//  WNDisconnectMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/4/14.
//

#import "WNHelloDisconnectMsg.h"

@interface WNHelloDisconnectMsg ()

///< 关闭原因
@property (nonatomic, copy, nullable) NSString *reason;
@end

@implementation WNHelloDisconnectMsg

- (instancetype)initWithReason:(NSString *_Nullable)reason {
    self = [super init];
    if (self) {
        self.reason = reason;
        self.command = @"42";
        self.nameSpace = @"/worker/send";
        self.msgType = WNHelloMessageTypeDisconnect;
    }
    return self;
}

+ (instancetype)disconnectWithReason:(NSString *_Nullable)reason {
    WNHelloDisconnectMsg *msg = [[WNHelloDisconnectMsg alloc] initWithReason:reason];
    return msg;
}

//42/worker/send,["receive-disconnect-event",{"reason":"enterBackground"}]
- (NSString *)toString {
    NSDictionary *dic = @{@"reason": self.reason};
    NSString *str = [NSString stringWithFormat:@"%@%@,[\"%@\", %@]", self.command, self.nameSpace, self.msgType, [dic yy_modelToJSONString]];
    return str;
}

@end
