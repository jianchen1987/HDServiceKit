//
//  HDDeviceInfo.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDDeviceInfo : NSObject

/** 获取唯一标识 */
+ (nonnull NSString *)getUniqueId;

/** idfa 广告标识 */
+ (nonnull NSString *)idfaString;

/** idfv */
+ (nonnull NSString *)idfvString;

/** mac地址 */
+ (nonnull NSString *)macAddress;

/** 获取设备当前网络IP地址 */
+ (nonnull NSString *)getIPAddress:(BOOL)preferIPv4;

/** 设备机型名称 如：iPhone10,1 */
+ (nonnull NSString *)modelName;

/** 浏览器userAgent */
+ (nonnull NSString *)userAgent;

/** 屏幕尺⼨ */
+ (nonnull NSString *)screenSize;

/** app名 */
+ (nonnull NSString *)appName;

/** 应用包名 */
+ (nonnull NSString *)appPackageName;

/** 应用 bundleID */
+ (nonnull NSString *)appBundleId;

/** APP版本号 */
+ (nonnull NSString *)appVersion;

/** 设备系统版本 */
+ (nonnull NSString *)deviceVersion;

/** 磁盘使用情况 */
+ (nonnull NSString *)diskUsage;

/** 当前设备语言 */
+ (NSString *)getDeviceLanguage;

/** 当前网络类型 */
+ (NSString *)getNetworkType;

/** 获取运营商名称 */
+ (NSString *)getCarrierName;

/** 当前手机磁盘空间大小 ，totalSpace：YES：磁盘空间总大小，NO：磁盘剩余可用空间 */
+ (long long)deviceStorageSpace:(BOOL)totalSpace;
@end

NS_ASSUME_NONNULL_END
