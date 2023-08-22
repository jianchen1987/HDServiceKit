//
//  HDHelloPlatformViewController.m
//  HDServiceKit_Example
//
//  Created by seeu on 2022/3/23.
//  Copyright © 2022 wangwanjie. All rights reserved.
//

#import "HDHelloPlatformViewController.h"
#import "RSACipher.h"
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
    //    WNApp *app = [WNApp appWithAppId:@"16EuLXnkwc2J8" secrectKey:@"" privateKey:@""];
    //
    //    WNHelloClient *client = [WNHelloClient sharedClient];
    //    [client initWithApp:app host:@"wss://hello-sit.lifekh.com/hello-worker"];
    //    [client signInWithUserId:@"855088127127"];
    //    client.delegate = self;
    //    [client addListener:self forEvent:WNHelloEventDataMessage];

    NSString *platformPubKey = @"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBALyV5bMSDCS5lGARPtAAknmOqrpB9/QQnfpA8ivFB2wo60M7Dej/Fl6kPO+NVaq72j4NEDXHNk9qXSGVe0wJ8DsCAwEAAQ==";
    NSString *platformPriKey = @"MIIBVAIBADANBgkqhkiG9w0BAQEFAASCAT4wggE6AgEAAkEAvJXlsxIMJLmUYBE+0ACSeY6qukH39BCd+kDyK8UHbCjrQzsN6P8WXqQ8741VqrvaPg0QNcc2T2pdIZV7TAnwOwIDAQABAkAFtMdpfq9NYSwjKAJtisbj1LRHxH07LlGJY/Ov7VtHI3x+Pv8Iey/5f7MsbWyTiybQZI2ZAX9UY43QTncx1ewBAiEA6/WHMDKLsPEa+uCb9pN84ftVovGpG30JeVjiFolHyjsCIQDMmlK/s1LvFgzZuzXr8K5VqCO9nx5y4X91rpZIMP4SAQIgK5q4+9grZmx37uq5B60jw+MdZTpBZPoLWShqx31hDecCIBHJ8RvduX40CpX7ouqKmH22CrV32ive0zgmH8bTC6QBAiEAwbvUZVFvWV1XncEa3JwxZdufTLuH+gsuUGmsj+89UrA=";

    NSString *userPubKey = @"MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAJvXMePnzcYZ8QCy5kru4I+MFuInYoKszArMsoXULmoUXuvjffQeEce9iU9TD1PF7wCYBnf31CuPJH3He2sV0rsCAwEAAQ==";
    NSString *userPriKey = @"MIIBVQIBADANBgkqhkiG9w0BAQEFAASCAT8wggE7AgEAAkEAm9cx4+fNxhnxALLmSu7gj4wW4idigqzMCsyyhdQuahRe6+N99B4Rx72JT1MPU8XvAJgGd/fUK48kfcd7axXSuwIDAQABAkA+va+fUsbcl7sYje37gxqzkDHyUOrvM0ReoLTK/nbFS9Wr4BHEfJk/utBlJHhJxSs0Cih8lFbY5Kbn7/gUzyFRAiEA52r5k3u0OYaTTbwPzG+fW/zTVs37+Xe9jKTQ3QJaaUMCIQCsZQWIWnzJW6luWUgyGAj93bsnOvDKEfKGe+ryTwI9KQIhAIn3nRPwjGI/eVK+7CxV4AxXjygRZkg0uy0+lcctv/lBAiAOVWPtX2CquUVQGHpJN/hfazUpYNwuYOmiRuFU/j64aQIhAMQI3pLeAHrHAK45O3ju666/Bh71kz61Y567734qgESl";

    NSDictionary *data = @{
        @"abc": @123,
        @"ccc": @"faw奥术大师大所大所大所大所大"
    };

    HDLog(@"平台公钥:%@", platformPubKey);
    HDLog(@"平台私钥:%@", platformPriKey);

    HDLog(@"用户公钥:%@", userPubKey);
    HDLog(@"用户私钥:%@", userPriKey);

    HDLog(@"实验数据:%@", [data yy_modelToJSONString]);

    NSString *serectText = [RSACipher encrypt:[data yy_modelToJSONString] publicKey:platformPubKey];
//    NSString *signature = [RSACipher signText:[data yy_modelToJSONString] privateKey:userPriKey];
    NSString *signature = [RSACipher signText:[data yy_modelToJSONString] privateKey:userPriKey tag:@""];

    HDLog(@"用户发送密文:%@", serectText);
    HDLog(@"用户发送签名:%@", signature);
//    NSString *plainText = [RSACipher decrypt:serectText privateKey:platformPriKey];
    NSString *plainText = [RSACipher decrypt:serectText privateKey:platformPriKey tag:@""];
    
    HDLog(@"服务端解密明文:%@", plainText);

    //    BOOL result = [RSACipher veriryData:[data yy_modelToJSONString] signature:signature publicKey:userPubKey];
    //    HDLog(@"验签结果:%@", result ? @"通过" : @"不通过");
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
