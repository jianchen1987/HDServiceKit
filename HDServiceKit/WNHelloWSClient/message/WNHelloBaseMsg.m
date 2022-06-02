//
//  WNHelloBaseMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloBaseMsg.h"

@implementation WNHelloBaseMsg
- (instancetype)initWithMessage:(NSString *)text {
    self = [super init];
    if (self) {
        if ([text hasPrefix:@"0"]) {
            self.command = @"0";
            self.data = [NSJSONSerialization JSONObjectWithData:[[text substringFromIndex:1] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            self.nameSpace = @"";
            self.msgType = WNHelloMessageTypeConnectd;
        } else if ([text isEqualToString:@"3"]) {
            self.command = @"3";
            self.msgType = WNHelloMessageTypePong;
        } else if ([text isEqualToString:@"40"]) {
            self.command = @"40";
            self.msgType = @"unknow";
        } else if ([text hasPrefix:@"40"]) {
            self.command = @"40";
            self.msgType = WNHelloMessageTypeReady;
        } else {
            self.command = [text substringWithRange:NSMakeRange(0, 2)];
            self.nameSpace = [[[text substringFromIndex:2] componentsSeparatedByString:@","] firstObject];
            NSString *temp = [text substringFromIndex:self.command.length + self.nameSpace.length + 1];
            NSArray *array = [NSJSONSerialization JSONObjectWithData:[temp dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            self.msgType = array.firstObject;
            self.data = [array.lastObject isKindOfClass:NSDictionary.class] ? array.lastObject : @{};
        }
    }

    return self;
}
- (NSString *_Nullable)toString {
    return nil;
}
@end
