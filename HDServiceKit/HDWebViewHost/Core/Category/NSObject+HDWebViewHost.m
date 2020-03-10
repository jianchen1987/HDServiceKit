//
//  NSObject+HDWebViewHost.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/10.
//

#import "NSObject+HDWebViewHost.h"

@implementation NSObject (HDWebViewHost)
- (id)hd_performSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];

    NSUInteger i = 1;
    if (objects.count) {
        for (id object in objects) {
            id tempObject = object;
            if ([tempObject isKindOfClass:NSString.class]) {
                // 解决字符串为空时崩溃
                NSString *str = (NSString *)tempObject;
                if (str.length <= 0) {
                    continue;
                }
            }
            [invocation setArgument:&tempObject atIndex:++i];
        }
    }
    [invocation invoke];

    if (methodSignature.methodReturnLength > 0) {
        id value;
        [invocation getReturnValue:&value];
        return value;
    }
    return nil;
}
@end
