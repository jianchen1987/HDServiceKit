//
//  WNHelloDownloadMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloDownloadMsg.h"

@implementation WNHelloDownloadMsg

- (instancetype)initWithMessage:(NSString *)text {
    self = [super initWithMessage:text];
    if (self) {
        self.messageID = [self.data objectForKey:@"messageID"];
    }
    return self;
}

@end
