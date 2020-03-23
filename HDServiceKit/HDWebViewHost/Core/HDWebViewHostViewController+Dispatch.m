//
//  HDServiceKitViewController+Dispatch.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHResponseManager.h"
#import "HDWebViewHostViewController+Callback.h"
#import "HDWebViewHostViewController+Dispatch.h"
#import "HDWebViewHostViewController+Scripts.h"
#import "HDWebViewHostViewController+Utils.h"

@implementation HDWebViewHostViewController (Dispatch)

#pragma mark - core
- (void)dispatchParsingParameter:(NSDictionary *)contentJSON {
    // 增加对异常参数的catch
    @try {
        NSDictionary *paramDict = [contentJSON objectForKey:kWHParamKey];
        NSString *callbackKey = [contentJSON objectForKey:kWHCallbackKey];
        [self callNative:[contentJSON objectForKey:kWHActionKey] parameter:paramDict.allKeys.count > 0 ? paramDict : nil callbackKey:callbackKey];

        [[NSNotificationCenter defaultCenter] postNotificationName:kWebViewHostInvokeRequestEvent object:contentJSON];
    } @catch (NSException *exception) {
        [self showTextTip:@"H5接口异常"];
        HDWHLog(@"h5接口解析异常，接口数据：%@", contentJSON);
    } @finally {
    }
}

#pragma mark - public
- (BOOL)callNative:(NSString *)action {
    return [self callNative:action parameter:nil];
}

// 延迟初始化； 短路判断
- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict {
    return [self callNative:action parameter:paramDict callbackKey:nil];
}

- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict callbackKey:(NSString *)key {
    HDWHResponseManager *rm = [HDWHResponseManager defaultManager];
    NSString *actionSig = [rm actionSignature:action withParam:paramDict.allKeys.count > 0 withCallback:key.length > 0];
    id<HDWebViewHostProtocol> response = [rm responseForActionSignature:actionSig withWebViewHost:self];
    if (response == nil || ![response handleAction:action withParam:paramDict callbackKey:key]) {
        NSString *errMsg = [NSString stringWithFormat:@"action (%@) not supported yet.", action];
        HDWHLog(@"%@", errMsg);

        [self fireCallback:key actionName:action code:HDWHRespCodeCommonFailed type:HDWHCallbackTypeFail params:nil];

        // 通知 web 事件不支持
        [self fire:@"notSupported"
             param:@{
                 @"error": errMsg,
                 @"action": action
             }];
#ifdef DEBUG
        [self callNative:@"toast"
               parameter:@{@"text": errMsg}];
#endif
        return NO;
    } else {
        return YES;
    }
}

@end
