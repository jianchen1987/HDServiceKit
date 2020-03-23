//
//  Target_DemoTarget.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/22.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "Target_DemoTarget.h"
#import "HDH5ViewController.h"
#import "HDScanCodeViewController.h"
#import <objc/runtime.h>

@implementation _Target (DemoTarget)
- (UIViewController *)_Action(h5ViewController):(NSDictionary *)params {
    HDH5ViewController *vc = [HDH5ViewController new];
    return vc;
}

- (UIViewController *)_Action(scanCodeViewController):(NSDictionary *)params {
    HDScanCodeViewController *vc = [HDScanCodeViewController new];
    return vc;
}

- (NSUInteger)_Action(plus):(NSDictionary *)params {
    NSUInteger value1 = [[params valueForKey:@"value1"] integerValue];
    NSUInteger value2 = [[params valueForKey:@"value2"] integerValue];
    typedef void (^ResultBlock)(NSUInteger);
    ResultBlock callback = [params valueForKey:@"callback"];
    if (callback) {
        callback(value1 + value2);
    }
    return value1 + value2;
}

- (UIViewController *)_Action(notF2ound):(NSDictionary *)params {
    Class cls = NSClassFromString(@"HDNotFoundViewController");
    if (!cls) {
        // 创建一个类
        const char *className = [@"HDNotFoundViewController" cStringUsingEncoding:NSASCIIStringEncoding];
        Class superClass = [HDBaseViewController class];
        cls = objc_allocateClassPair(superClass, className, 0);
        // 注册你创建的这个类
        objc_registerClassPair(cls);
    }
    UIViewController *vc = [[cls alloc] init];
    return vc;
}
@end
