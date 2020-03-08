//
//  HDViewController.m
//  HDServiceKit
//
//  Created by wangwanjie on 03/03/2020.
//  Copyright (c) 2020 wangwanjie. All rights reserved.
//

#import "HDViewController.h"
#import <HDServiceKit/HDWebViewHost.h>

@interface HDViewController ()

@end

@implementation HDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;

    [HDWHDebugServerManager.sharedInstance showDebugWindow];
    [HDWHDebugServerManager.sharedInstance start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *url = @"https://www.baidu.com";
    // HDWebViewHostViewController *vc = [[HDWebViewHostViewController alloc] init];
    // vc.url = url;
    // [self.navigationController pushViewController:vc animated:true];

    // 也可以预热
    HDWHViewControllerPreRender *_Nonnull preRender = [HDWHViewControllerPreRender defaultRender];
    // 这里仅仅做演示。只有确定唯一的 url ，才调用这个方法。大部分时间都不应该调用 getWebViewController 浪费内存
    [preRender getWebViewController:HDWebViewHostViewController.class
                         preloadURL:url
                         completion:^(HDWebViewHostViewController *_Nonnull vc) {
                             if (![vc.url isEqualToString:url]) {
                                 vc.url = url;
                             }
                             [self.navigationController pushViewController:vc animated:YES];

                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [vc fire:@"callJsMethod" param:@{ @"name": @"wangwanjie",
                                                                   @"age": @26 }];
                                 [vc fireCallback:@"callBack" param:@{ @"name": @"wangwanjie",
                                                                       @"age": @26 }];
                             });
                         }];
}
@end
