//
//  HDNetworkResponse+SuperApp.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDNetworkResponse+SuperApp.h"
#import <objc/runtime.h>

@implementation HDNetworkResponse (SuperApp)
- (void)setErrorType:(HDResponseErrorType)errorType {
    [self willChangeValueForKey:@"errorType"];
    objc_setAssociatedObject(self, @selector(errorType), @(errorType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"errorType"];
}

- (HDResponseErrorType)errorType {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) return HDResponseErrorTypeUnknown;
    return [value integerValue];
}
@end
