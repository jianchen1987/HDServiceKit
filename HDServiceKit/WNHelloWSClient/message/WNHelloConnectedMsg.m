//
//  WNHelloConnectedMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/27.
//

#import "WNHelloConnectedMsg.h"

//0{"sid":"jKgT1aCOCt4yGuZuAAAH","upgrades":[],"pingInterval":5000,"pingTimeout":10000}
@implementation WNHelloConnectedMsg

- (instancetype)initWithMessage:(NSString *)text {
    self = [super initWithMessage:text];
    if (self) {
        self.sid = [self.data valueForKey:@"sid"];
        self.pingInterval = [[self.data objectForKey:@"pingInterval"] integerValue] / 1000.0;
        self.pingTimeout = [[self.data objectForKey:@"pingTimeout"] integerValue] / 1000.0;
    }
    return self;
}

@end
