//
//  HDHelloPlatformViewController.m
//  HDServiceKit_Example
//
//  Created by seeu on 2022/3/23.
//  Copyright © 2022 wangwanjie. All rights reserved.
//

#import "HDHelloPlatformViewController.h"
#import <HDKitCore/WNApp.h>
#import <HDServiceKit/WNHelloClient.h>

@interface HDHelloPlatformViewController ()

@end

@implementation HDHelloPlatformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [btn setTitle:@"连接" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickOnConnect) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:btn];
}

- (void)updateViewConstraints {

    [super updateViewConstraints];
}

- (void)clickOnConnect {
    WNApp *app = [WNApp appWithAppId:@"16EuLXnkwc2J8" secrectKey:@"" privateKey:@""];

    WNHelloClient *client = [WNHelloClient sharedClient];
    [client initWithApp:app];
    [client signInWithUserId:@"855088127127"
                  completion:^(NSString *_Nonnull deviceToken, NSError *_Nonnull error) {
                      HDLog(@"登陆成功");
                  }];
}

@end
