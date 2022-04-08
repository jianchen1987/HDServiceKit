//
//  WNHelloLoginMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/27.
//

#import "WNHelloLoginMsg.h"

//42/worker/send,["sign-in",{"messageID":"LzLKi4Sc4AVZK8R3Qq6Nj4xpqQ6mJTRJK1Yh","token":"ffacda82baa0aba0e1df40fb5c89437f46e72386","expiredTime":1650939595005}]
@implementation WNHelloLoginMsg

- (instancetype)initWithMessage:(NSString *)text {
    self = [super initWithMessage:text];
    if (self) {
        self.token = [self.messageContent objectForKey:@"token"];
        self.expiredTime = [[self.messageContent objectForKey:@"expiredTime"] integerValue] * 1.0;
    }

    return self;
}

@end
