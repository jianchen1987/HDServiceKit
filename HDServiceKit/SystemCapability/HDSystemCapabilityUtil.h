//
//  HDSystemCapabilityUtil.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDSystemCapabilityUtil : NSObject

/**
 打电话
 
 @param phoneNum 电话号码
 */
+ (void)makePhoneCall:(NSString *)phoneNum;

/**
 发短信
 
 @param phoneNum 电话号码
 */
+ (void)sendSms:(NSString *)phoneNum;

/**
 发Email
 
 @param recipient 收件人
 @param ccRecipient 抄送人
 @param bccRecipient 密送人
 @param subject 主题
 @param body 内容
 */
+ (void)sendEmailWithRecipient:(NSString *)recipient ccRecipient:(NSString *)ccRecipient bccRecipient:(NSString *)bccRecipient subject:(NSString *)subject body:(NSString *)body;

/// 去商店评分
/// @param appID 应用id
+ (void)gotoAppStoreScoreWithAppID:(NSString *)appID;

/// 商店中打开应用页面
/// @param appID 应用ID
+ (void)gotoAppStoreForAppID:(NSString *)appID;

/**
 跳地图
 */
+ (void)jumpToMapWithAddress:(NSString *)address successHandler:(void (^)(void))successHandler failHandler:(void (^)(NSString *errMsg))failHandler;

/**
 根据经纬度跳地图导航
 */
+ (void)jumpToMapWithLongitude:(double)longitude latitude:(double)latitude locationName:(NSString *)locationName;

/**
 保存当前亮度
 */
+ (void)saveDefaultBrightness;

/**
 逐级设置亮度

 @param value 亮度值 0 - 1
 */
+ (void)graduallySetBrightness:(CGFloat)value;

/**
 逐级恢复亮度
 */
+ (void)graduallyResumeBrightness;

/**
 打开 APP 系统设置页面
 */
+ (void)openAppSystemSettingPage;
@end

NS_ASSUME_NONNULL_END
