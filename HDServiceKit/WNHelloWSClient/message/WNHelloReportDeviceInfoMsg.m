//
//  WNReportDeviceInfoMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/4/14.
//

#import "WNHelloReportDeviceInfoMsg.h"
#import "HDDeviceInfo.h"
#import "HDLocationManager.h"
#import "HDLocationUtils.h"
#import <ContactsUI/ContactsUI.h>
#import <Photos/Photos.h>

@implementation WNHelloReportDeviceInfoMsg

- (instancetype)init {
    self = [super init];
    if (self) {
        self.command = @"42";
        self.nameSpace = @"/worker/send";
        self.msgType = WNHelloMessageTypeReportDeviceInfo;
    }
    return self;
}

//42/worker/send, ["report-device-status", {设备信息}],
- (NSString *)toString {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:5];
    ///< 型号
    [dic setValue:[HDDeviceInfo modelName] forKey:@"机型"];
    ///< 厂家
    [dic setValue:[UIDevice currentDevice].name forKey:@"手机名"];
    ///< 系统版本
    [dic setValue:[HDDeviceInfo deviceVersion] forKey:@"系统版本"];
    ///< 屏幕宽高
    [dic setValue:[HDDeviceInfo screenSize] forKey:@"屏幕宽高"];
    ///< 手机内存
    [dic setValue:[NSString stringWithFormat:@"%llu", [NSProcessInfo processInfo].physicalMemory] forKey:@"内存大小"];
    ///< 语言
    [dic setValue:[HDDeviceInfo getDeviceLanguage] forKey:@"系统语言"];
    ///< 国家地区
    [dic setValue:[NSLocale currentLocale].localeIdentifier forKey:@"国家地区"];
    ///< app版本号
    [dic setValue:[HDDeviceInfo appVersion] forKey:@"App版本"];
    ///< 设备号
    [dic setValue:[HDDeviceInfo getUniqueId] forKey:@"设备号"];

    if ([HDLocationUtils getCLAuthorizationStatus] == HDCLAuthorizationStatusAuthed && [[HDLocationManager shared] isCurrentCoordinate2DValid]) {
        ///< 经度
        [dic setValue:[NSString stringWithFormat:@"%f", [HDLocationManager shared].realCoordinate2D.latitude] forKey:@"经度"];
        ///< 纬度
        [dic setValue:[NSString stringWithFormat:@"%f", [HDLocationManager shared].realCoordinate2D.longitude] forKey:@"纬度"];
    } else {
        ///< 经度
        [dic setValue:@"未授权" forKey:@"经度"];
        ///< 纬度
        [dic setValue:@"未授权" forKey:@"纬度"];
    }
    ///<  广告标识符
    [dic setValue:[HDDeviceInfo idfaString] forKey:@"IDFA"];
    ///<  设备标识符
    [dic setValue:[HDDeviceInfo idfvString] forKey:@"UUID"];
    ///< 磁盘总大小
    [dic setValue:[NSString stringWithFormat:@"%llu", [HDDeviceInfo deviceStorageSpace:YES]] forKey:@"硬盘大小"];
    ///< 运营商
    [dic setValue:[HDDeviceInfo getCarrierName] forKey:@"网络运营商"];
    ///< 网络类型
    [dic setValue:[HDDeviceInfo getNetworkType] forKey:@"网络类型"];
    ///< 电池状态
    [dic setValue:[NSString stringWithFormat:@"%ld", [UIDevice currentDevice].batteryState] forKey:@"电池状态"];
    ///< 电量
    [dic setValue:[NSString stringWithFormat:@"%.2f", [UIDevice currentDevice].batteryLevel] forKey:@"当前电量"];

    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    NSString *pushStatus = @"开启";
    if (settings.types & UIUserNotificationTypeAlert) {
        pushStatus = [pushStatus stringByAppendingString:@"|弹窗"];
    }
    if (settings.types & UIUserNotificationTypeBadge) {
        pushStatus = [pushStatus stringByAppendingString:@"|数量"];
    }
    if (settings.types & UIUserNotificationTypeSound) {
        pushStatus = [pushStatus stringByAppendingString:@"|声音"];
    }
    if (settings.types == UIUserNotificationTypeNone) {
        pushStatus = @"未开启";
    }
    [dic setValue:pushStatus forKey:@"推送权限"];

    NSString *contactStatus = @"";
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusAuthorized) {
        contactStatus = @"已授权";
    } else {
        contactStatus = @"未授权";
    }
    [dic setValue:contactStatus forKey:@"通讯录权限"];

    NSString *picStatus = @"未授权";
    PHAuthorizationStatus *authorizationStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        picStatus = @"仅添加";
    }
    authorizationStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
        picStatus = @"可读写";
    }

    [dic setValue:picStatus forKey:@"相册权限"];

    NSString *str = [NSString stringWithFormat:@"%@%@,[\"%@\", %@]", self.command, self.nameSpace, self.msgType, [dic yy_modelToJSONString]];
    return str;
}

@end
