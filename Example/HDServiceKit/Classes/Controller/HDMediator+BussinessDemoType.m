//
//  HDMediator+BussinessDemoType.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/22.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDBaseViewController.h"
#import "HDMediator+BussinessDemoType.h"
#import <objc/runtime.h>

@implementation HDMediator (BussinessDemoType)
- (UIViewController *)h5ViewController {
    UIViewController *vc = [self performTarget:@"DemoTarget" action:@"h5ViewController" shouldCacheTarget:false];
    if (!vc) {
        vc = UIViewController.new;
    }
    return vc;
}

- (UIViewController *)scanCodeViewController {
    UIViewController *vc = [self performTarget:@"DemoTarget" action:@"scanCodeViewController" shouldCacheTarget:false];
    if (!vc) {
        vc = UIViewController.new;
    }
    return vc;
}

- (UIViewController *)defaultViewController {
    UIViewController *vc = [self performTarget:@"DemoTarget" action:@"anyNotExistAction" shouldCacheTarget:false];
    if (!vc) {
        vc = UIViewController.new;
    }
    return vc;
}

- (void)showUnsupprtedEntryTipWithActionName:(NSString *)action {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"action：%@ 不支持", action] preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
}

- (void)showUnsupprtedEntryTipWithRouteURL:(NSString *)routeURL {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"警告" message:[NSString stringWithFormat:@"route：%@ 不支持", routeURL] preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
}
@end
