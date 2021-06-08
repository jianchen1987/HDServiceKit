//
//  HDWHSystemCapabilityResponse.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/16.
//

#import "HDWHSystemCapabilityResponse.h"
#import "HDDeviceInfo.h"
#import "HDSystemCapabilityUtil.h"
#import "HDWebViewHostViewController+Callback.h"
#import <HDVendorKit/HDWebImageManager.h>

@interface HDWHSystemCapabilityResponse ()

@end

@implementation HDWHSystemCapabilityResponse
+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"makePhoneCall_$": kHDWHResponseMethodOn,
        @"sendSms_": kHDWHResponseMethodOn,
        @"sendEmail_": kHDWHResponseMethodOn,
        @"gotoAppStoreScore_": kHDWHResponseMethodOn,
        @"gotoAppStore_": kHDWHResponseMethodOn,
        @"jumpToMapWithAddress_$": kHDWHResponseMethodOn,
        @"jumpToMapWithCoordinates_": kHDWHResponseMethodOn,
        @"graduallySetBrightness_": kHDWHResponseMethodOn,
        @"openAppSystemSettingPage": kHDWHResponseMethodOn,
        @"getUserDevice$": kHDWHResponseMethodOn,
        @"openLocation_": kHDWHResponseMethodOn,
        @"getCookies_$": kHDWHResponseMethodOn,
        @"clearCookies_": kHDWHResponseMethodOn
    };
}

- (void)getCookies:(NSDictionary *)params callback:(NSString *)callBackKey {

    NSString *domain = [params objectForKey:@"domainRegular"];
    if (!domain || HDIsStringEmpty(domain)) {
        [self.webViewHost fireCallback:callBackKey actionName:@"getCookies" code:HDWHRespCodeIllegalArg type:HDWHCallbackTypeFail params:nil];
        return;
    }

    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStore = self.webView.configuration.websiteDataStore.httpCookieStore;
        [cookieStore getAllCookies:^(NSArray *cookies) {
            __block NSString *result = @"";
            [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                HDWHLog(@"%@", obj);
                if ([obj.domain containsString:domain]) {
                    result = [result stringByAppendingFormat:@"&%@=%@", obj.name, obj.value];
                }
            }];
            if ([result hasPrefix:@"&"]) {
                result = [result substringFromIndex:1];
            }
            [self.webViewHost fireCallback:callBackKey actionName:@"getCookies" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:@{@"cookies": result}];
        }];
    } else {
        NSArray *cookArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        __block NSString *result = @"";
        [cookArray enumerateObjectsUsingBlock:^(NSHTTPCookie *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            HDWHLog(@"%@", obj);
            if ([obj.domain containsString:domain]) {
                result = [result stringByAppendingFormat:@"&%@=%@", obj.name, obj.value];
            }
        }];
        [self.webViewHost fireCallback:callBackKey actionName:@"getCookies" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:@{@"cookies": result}];
    }
}

- (void)clearCookies:(NSDictionary *)params {
    NSString *domain = [params objectForKey:@"domainRegular"];
    if (!domain || HDIsStringEmpty(domain)) {
        return;
    }
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookiesStore = self.webView.configuration.websiteDataStore.httpCookieStore;
        [cookiesStore getAllCookies:^(NSArray<NSHTTPCookie *> *_Nonnull cookies) {
            [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                if ([obj.domain containsString:domain]) {
                    [cookiesStore deleteCookie:obj completionHandler:nil];
                    HDWHLog(@"删除cookies成功! %@", domain);
                }
            }];
        }];
    } else {
        NSArray *cookArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookArray) {
            if ([cookie.domain isEqualToString:domain]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                HDWHLog(@"删除cookies成功! %@", domain);
            }
        }
    }
}

// clang-format off
wh_doc_begin(makePhoneCall_, "拨打电话")
wh_doc_param(phoneNum, "字符串，电话号码")
wh_doc_code(window.webViewHost.invoke("makePhoneCall",{"phoneNum": "855987657867"},function()))
wh_doc_code_expect("调用系统功能，弹出拨打电话弹窗")
wh_doc_end;
// clang-format on
- (void)makePhoneCall:(NSDictionary *)paramDict callback:(NSString *)callBackKey {
    NSString *phoneNum = [paramDict objectForKey:@"phone"];
    [HDSystemCapabilityUtil makePhoneCall:phoneNum];
    [self.webViewHost fireCallback:callBackKey actionName:@"makePhoneCall" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:nil];
}

// clang-format off
wh_doc_begin(sendSms_, "调用系统发送短信功能")
wh_doc_param(phoneNum, "字符串，电话号码")
wh_doc_code(window.webViewHost.invoke("sendSms",{"phoneNum": "855987657867"}))
wh_doc_code_expect("调用系统功能，跳转至发送短信页面")
wh_doc_end;
// clang-format on
- (void)sendSms:(NSDictionary *)paramDict {
    NSString *phoneNum = [paramDict objectForKey:@"phoneNum"];
    [HDSystemCapabilityUtil sendSms:phoneNum];
}

// clang-format off
wh_doc_begin(sendEmail_, "调用系统发送邮件")
wh_doc_param(recipient, "收件人")
wh_doc_param(ccRecipient, "抄送人")
wh_doc_param(bccRecipient, "密送人")
wh_doc_param(subject, "主题")
wh_doc_param(body, "内容")
wh_doc_code(window.webViewHost.invoke("sendEmail",{"recipient": "123@qq.com", "ccRecipient": "456@qq.com", "bccRecipient": "789@qq.com", "subject": "主题标题", "body": "一起吃饭"}))
wh_doc_code_expect("调用系统功能，跳转至发送邮件界面，收件人是 123@qq.com，抄送人是 456@qq.com，内容是一起吃饭")
wh_doc_end;
// clang-format on
- (void)sendEmail:(NSDictionary *)paramDict {
    // 收件人
    NSString *recipient = [paramDict objectForKey:@"recipient"];
    // 抄送人
    NSString *ccRecipient = [paramDict objectForKey:@"ccRecipient"];
    // 密送人
    NSString *bccRecipient = [paramDict objectForKey:@"bccRecipient"];
    // 主题
    NSString *subject = [paramDict objectForKey:@"subject"];
    // 内容
    NSString *body = [paramDict objectForKey:@"body"];
    [HDSystemCapabilityUtil sendEmailWithRecipient:recipient ccRecipient:ccRecipient bccRecipient:bccRecipient subject:subject body:body];
}

// clang-format off
wh_doc_begin(gotoAppStoreScore_, "去到应用评分界面")
wh_doc_param(appID, "应用ID")
wh_doc_code(window.webViewHost.invoke("gotoAppStoreScore",{"appID": "1440238257"}))
wh_doc_code_expect("跳转到 ViPay 评价界面")
wh_doc_end;
// clang-format on
- (void)gotoAppStoreScore:(NSDictionary *)paramDict {
    NSString *appID = [paramDict objectForKey:@"appID"];
    [HDSystemCapabilityUtil gotoAppStoreScoreWithAppID:appID];
}

// clang-format off
wh_doc_begin(gotoAppStore_, "去到应用评分界面")
wh_doc_param(appID, "应用ID")
wh_doc_code(window.webViewHost.invoke("gotoAppStore",{"appID": "1440238257"}))
wh_doc_code_expect("跳转到 ViPay 商店页面")
wh_doc_end;
// clang-format on
- (void)gotoAppStore:(NSDictionary *)paramDict {
    NSString *appID = [paramDict objectForKey:@"appID"];
    [HDSystemCapabilityUtil gotoAppStoreForAppID:appID];
}

// clang-format off
wh_doc_begin(jumpToMapWithAddress_$, "根据一个地址（不是经纬度）打开地图页面")
wh_doc_param(address, "要跳转的地址")
wh_doc_code(window.webViewHost.invoke("jumpToMapWithAddress",{"address": "广州市天河区TIT时代广场"}, function(params) {
    alert('跳转地图回调:' + JSON.stringify(params));
}))
wh_doc_code_expect("跳转到广州市天河区TIT时代广场")
wh_doc_end;
// clang-format on
- (void)jumpToMapWithAddress:(NSDictionary *)paramDict callback:(NSString *)callBackKey {
    NSString *address = [paramDict objectForKey:@"address"];
    __weak __typeof(self) weakSelf = self;
    [HDSystemCapabilityUtil jumpToMapWithAddress:address
        successHandler:^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.webViewHost fireCallback:callBackKey actionName:@"jumpToMapWithAddress" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:nil];
        }
        failHandler:^(NSString *_Nonnull errMsg) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.webViewHost fireCallback:callBackKey actionName:@"jumpToMapWithAddress" code:HDWHRespCodeCommonFailed type:HDWHCallbackTypeFail params:@{@"reason": errMsg}];
        }];
}

// clang-format off
wh_doc_begin(jumpToMapWithCoordinates_, "根据一个地址以及经纬度打开地图页面")
wh_doc_param(longitude, "要跳转的地址的经度，字符串")
wh_doc_param(latitude, "要跳转的地址的纬度，字符串")
wh_doc_param(address, "要跳转的地址名")
wh_doc_code(window.webViewHost.invoke("jumpToMapWithCoordinates",{"address": "我也不知道这是哪里", "longitude": "123.896787878", "latitude": "34.986778977"}))
wh_doc_code_expect("我也不知道这是哪里")
wh_doc_end;
// clang-format on
- (void)jumpToMapWithCoordinates:(NSDictionary *)paramDict {
    double longitude = [[paramDict objectForKey:@"longitude"] doubleValue];
    double latitude = [[paramDict objectForKey:@"latitude"] doubleValue];
    NSString *address = [paramDict objectForKey:@"address"];
    [HDSystemCapabilityUtil jumpToMapWithLongitude:longitude latitude:latitude locationName:address];
}

// clang-format off
wh_doc_begin(graduallySetBrightness_, "渐变地调整当前屏幕亮度")
wh_doc_param(value, "要设置的亮度，范围 0 - 1")
wh_doc_code(window.webViewHost.invoke("graduallySetBrightness",{"value": "0.8"}))
wh_doc_code_expect("设置当前屏幕亮度为 80%")
wh_doc_end;
// clang-format on
- (void)graduallySetBrightness:(NSDictionary *)paramDict {
    double value = [[paramDict objectForKey:@"value"] doubleValue];
    [HDSystemCapabilityUtil graduallySetBrightness:value];
}

// clang-format off
wh_doc_begin(openAppSystemSettingPage, "打开当前应用在系统设置中的界面，无需参数")
wh_doc_code(window.webViewHost.invoke("openAppSystemSettingPage"))
wh_doc_code_expect("跳转到 demo 的系统设置界面")
wh_doc_end;
// clang-format on
- (void)openAppSystemSettingPage {
    [HDSystemCapabilityUtil openAppSystemSettingPage];
}

// clang-format off
wh_doc_begin(getUserDevice$, "获取用户当前设备硬件信息")
wh_doc_code(window.webViewHost.invoke("getUserDevice", {}, function(params) {
    alert("getUserDevice:" + JSON.stringify(params));
}))
wh_doc_code_expect("获取到设备信息")
wh_doc_end;
// clang-format on
- (void)getUserDeviceWithCallback:(NSString *)callBackKey {

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    params[@"deviceld"] = [HDDeviceInfo getUniqueId];
    params[@"lang"] = [HDDeviceInfo getDeviceLanguage];
    params[@"termType"] = @"iOS";
    params[@"deviceModel"] = [HDDeviceInfo modelName];
    params[@"version"] = [HDDeviceInfo appVersion];
    params[@"networkType"] = [HDDeviceInfo getNetworkType];

    [self.webViewHost fireCallback:callBackKey actionName:@"getUserDevice" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:params];
}

// clang-format off
wh_doc_begin(openLocation_, "根据一个地址以及经纬度打开地图页面")
wh_doc_param(longitude, "要跳转的地址的经度，字符串")
wh_doc_param(latitude, "要跳转的地址的纬度，字符串")
wh_doc_param(name, "位置名")
wh_doc_param(address, "要跳转的地址名")
wh_doc_param(scale, "地图缩放级别,整形值,范围从 1~28。默认为最大")
wh_doc_param(infoUrl, "在查看位置界面底部显示的超链接,可点击跳转")
wh_doc_code(window.webViewHost.invoke("openLocation",{"address": "江西省上饶市南昌市滕王阁", "name": "滕王阁", "longitude": "123.896787878", "latitude": "34.986778977"}))
wh_doc_code_expect("调到系统地图滕王阁")
wh_doc_end;
// clang-format on
- (void)openLocation:(NSDictionary *)paramDict {
    double longitude = [[paramDict objectForKey:@"longitude"] doubleValue];
    double latitude = [[paramDict objectForKey:@"latitude"] doubleValue];
    NSString *address = [paramDict objectForKey:@"address"];
    [HDSystemCapabilityUtil jumpToMapWithLongitude:longitude latitude:latitude locationName:address];
}

@end
