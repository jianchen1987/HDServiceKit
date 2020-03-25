//
//  HDNetworkResponse+CM.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDNetworkResponse+CM.h"
#import <objc/runtime.h>

@implementation HDNetworkResponse (CM)
- (void)setErrorType:(CMResponseErrorType)errorType {
    [self willChangeValueForKey:@"errorType"];
    objc_setAssociatedObject(self, @selector(errorType), @(errorType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"errorType"];
}

- (CMResponseErrorType)errorType {
    NSNumber *value = objc_getAssociatedObject(self, _cmd);
    if (!value) return CMResponseErrorTypeUnknown;
    return [value integerValue];
}
@end
