//
//  HDLocationManager.h
//  HDServiceKit
//
//  Created by VanJay on 2019/10/12.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLocationUtils.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 位置请求权限变更 */
FOUNDATION_EXPORT NSString *const kNotificationNameLocationPermissionChanged;
/** 位置变化 */
FOUNDATION_EXPORT NSString *const kNotificationNameLocationChanged;
/** 获取通知中位置的 key */
FOUNDATION_EXPORT NSString *const kLocationChangedUserInfoKey;
/** 获取通知中位置请求权限的 key */
FOUNDATION_EXPORT NSString *const kLocationPermissionChangedUserInfoKey;

/** 只是为了方便使用者代码提示 */
@protocol HDLocationManagerProtocol <NSObject>

@optional
/** 位置管理者监听到位置请求权限变化，变更后的权限请使用 key kLocationPermissionChangedUserInfoKey 从 notification.userInfo 中获取 */
- (void)locationManagerMonitoredLocationPermissionChanged:(NSNotification *)notification;
/** 位置管理者监听到位置变化，变更后的位置请使用 key kLocationChangedUserInfoKey 从 notification.userInfo 中获取 */
- (void)locationManagerMonitoredLocationChanged:(NSNotification *)notification;

@end

@interface HDLocationManager : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;      ///< 当前经纬度（不超过100米不会变化）
@property (nonatomic, assign) CLLocationCoordinate2D realCoordinate2D;  ///< 真实经纬度

/// 单例管理者
+ (instancetype)shared;

/// 开始监听
- (void)start;

/// 当前经纬度是否有效
- (BOOL)isCurrentCoordinate2DValid;

/// 判断目标经纬度是否有效
/// @param coordinate2D 目标经纬度
- (BOOL)isCoordinate2DValid:(CLLocationCoordinate2D)coordinate2D;

/// 开始更新位置
- (void)startUpdatingLocation;

/// 请求需要时使用位置权限
- (void)requestWhenInUseAuthorization;
@end

NS_ASSUME_NONNULL_END
