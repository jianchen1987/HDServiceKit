//
//  WNHelloDataMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/27.
//

#import "WNHelloDataMsg.h"

//42/worker/send,["event-message",{"messageID":"MWOhLmcEju4wNaBsIuXysyzReYNJaQmJLpza","abfjksdf":"3223[2022-03-25 18:09:37.979]","messageContent":"哈哈哈哈哈哈","event":"test-send"}]
@implementation WNHelloDataMsg

- (instancetype)initWithMessage:(NSString *)text {
    self = [super initWithMessage:text];
    if (self) {
        self.messageContent = [self.data objectForKey:@"messageContent"];
    }
    return self;
}

@end
