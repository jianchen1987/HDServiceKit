//
//  WNHelloAckMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloAckMsg.h"

@interface WNHelloAckMsg ()
@property (nonatomic, copy) NSString *messageID;
@end

@implementation WNHelloAckMsg

+ (instancetype)ackMessageWithId:(NSString *_Nonnull)messageId {
    WNHelloAckMsg *msg = [[WNHelloAckMsg alloc] initWithMessageID:messageId];
    return msg;
}

- (instancetype)initWithMessageID:(NSString *)messageId {
    self = [super init];
    if (self) {
        self.messageID = messageId;
        self.command = @"42";
        self.nameSpace = @"/worker/send";
        self.msgType = WNHelloMessageTypeAck;
    }
    return self;
}

//42/worker/send,["send-callback", {"messageID":"Zyl0ChfQzDG0pyd1JneO4So59J4Z1t04DEK9"}]
- (NSString *)toString {
    NSDictionary *dic = @{@"messageId": self.messageID};
    NSString *str = [NSString stringWithFormat:@"%@%@,[\"%@\", %@]", self.command, self.nameSpace, self.msgType, [dic yy_modelToJSONString]];
    return str;
}

@end
