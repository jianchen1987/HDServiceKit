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
#import <UserNotifications/UserNotifications.h>

@interface HDHelloPlatformViewController () <WNHelloClientDelegate, WMHelloClientListenerDelegate, UNUserNotificationCenterDelegate>

@end

@implementation HDHelloPlatformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    [btn setTitle:@"连接" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickOnConnect) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:btn];

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:authOptions
                                                                      completionHandler:^(BOOL granted, NSError *_Nullable error){

                                                                      }];
}

- (void)updateViewConstraints {

    [super updateViewConstraints];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {

    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
}

- (void)clickOnConnect {
    WNApp *app = [WNApp appWithAppId:@"16EuLXnkwc2J8" secrectKey:@"" privateKey:@""];

    WNHelloClient *client = [WNHelloClient sharedClient];
    [client initWithApp:app];
    [client signInWithUserId:@"855088127127"
                  completion:^(NSString *_Nonnull deviceToken, NSError *_Nonnull error) {
                      HDLog(@"登陆成功");
                  }];
    client.delegate = self;
    [client addListener:self forEvent:WNHelloEventDataMessage];
}

- (void)didReciveMessage:(id)message forEvent:(WNHelloEvent)type {
    HDLog(@"收到消息");
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    // 标题
    content.title = @"本地通知";
    content.subtitle = @"测试通知副标题";
    // 内容
    content.body = @"测试内容";
    // 声音
    // 默认声音
    //    content.sound = [UNNotificationSound defaultSound];
    // 添加自定义声音
    //    content.sound = [UNNotificationSound soundNamed:@"Alert_ActivityGoalAttained_Salient_Haptic.caf"];
    // 角标 （我这里测试的角标无效，暂时没找到原因）
    content.badge = @1;
    // 多少秒后发送,可以将固定的日期转化为时间
    NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:5] timeIntervalSinceNow];
    //        NSTimeInterval time = 10;
    // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
    //    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];

    /*
     //如果想重复可以使用这个,按日期
     // 周一早上 8：00 上班
     NSDateComponents *components = [[NSDateComponents alloc] init];
     // 注意，weekday默认是从周日开始
     components.weekday = 2;
     components.hour = 8;
     UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
     */
    // 添加通知的标识符，可以用于移除，更新等操作
    NSString *identifier = @"noticeId";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];

    [center addNotificationRequest:request
             withCompletionHandler:^(NSError *_Nullable error) {
                 HDLog(@"成功添加推送");
             }];
}

- (void)loginSuccess:(NSString *)deviceToken {
    HDLog(@"登录成功");
}

- (void)helloClientError:(NSError *)error {
    HDLog(@"失败:%@", error.localizedDescription);
}

@end
