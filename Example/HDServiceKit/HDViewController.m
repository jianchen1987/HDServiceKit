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
    [HDWHDebugServerManager.sharedInstance startWithPort:12333 bonjourName:@"12333.local"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *url = @"https://www.baidu.com";
    HDWebViewHostViewController *vc = [[HDWebViewHostViewController alloc] init];
    vc.url = url;
    [self.navigationController pushViewController:vc animated:true];
}
@end
