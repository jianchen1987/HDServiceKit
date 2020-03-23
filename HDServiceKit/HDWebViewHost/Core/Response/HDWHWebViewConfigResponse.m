//
//  HDWHWebViewConfigResponse.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/16.
//

#import "HDWHWebViewConfigResponse.h"
#import "HDWebViewHostViewController+Callback.h"
#import "HDWebViewHostViewController+Utils.h"

@implementation HDWHWebViewConfigResponse
+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"enablePageBounce_": kHDWHResponseMethodOn,
        @"allowsBackForwardNavigationGestures_": kHDWHResponseMethodOn,
        @"allowsLinkPreview_": kHDWHResponseMethodOn,
        @"interactivePopDisabled_": kHDWHResponseMethodOn,
        @"ready_$": kHDWHResponseMethodOn,
        @"config_$": kHDWHResponseMethodOn,
        @"checkJsApi_$": kHDWHResponseMethodOn
    };
}

// clang-format off
wh_doc_begin(enablePageBounce_, "容许触发 webview 下拉弹回的动画，传入 false 表示不容许；这个效果是 iOS 独有的")
wh_doc_param(value, "布尔值， true 表示开启，false 表示关闭")
wh_doc_code(window.webViewHost.invoke("enablePageBounce",{"value": false}))
wh_doc_code_expect("本测试页面在滑动到底部或顶部时，没有 bounce 效果，在执行之前，尝试滑动底部，会出现 bounce 效果。")
wh_doc_end;
// clang-format on
- (void)enablePageBounce:(NSDictionary *)paramDict {
    BOOL bounce = [[paramDict objectForKey:@"value"] boolValue];
    self.webView.scrollView.bounces = bounce;
}

// clang-format off
wh_doc_begin(allowsBackForwardNavigationGestures_, "设置当前 webView 是否可以手势返回上一个页面（注意，是设置 webView，不是控制器），如果开启，当页面前进了多次时，在页面左边缘右滑可以返回上个网页，否则会触发返回上个控制器页面")
wh_doc_param(value, "布尔值， true 表示允许，false 表示不允许")
wh_doc_code(window.webViewHost.invoke("allowsBackForwardNavigationGestures",{"value": true}))
wh_doc_code_expect("当页面前进了多次时，在页面左边缘右滑可以返回上个网页")
wh_doc_end;
// clang-format on
- (void)allowsBackForwardNavigationGestures:(NSDictionary *)paramDict {
    BOOL value = [[paramDict objectForKey:@"value"] boolValue];
    self.webView.allowsBackForwardNavigationGestures = value;
}

// clang-format off
wh_doc_begin(allowsLinkPreview_, "设置当前 webView 上链接是否允许通过 3D Touch按压预览界面，如果开启，可通过用力按压链接预览该链接界面，否则无效果")
wh_doc_param(value, "布尔值， true 表示允许，false 表示不允许")
wh_doc_code(window.webViewHost.invoke("allowsLinkPreview",{"value": true}))
wh_doc_code_expect("可通过用力按压链接预览该链接界面")
wh_doc_end;
// clang-format on
- (void)allowsLinkPreview:(NSDictionary *)paramDict {
    BOOL value = [[paramDict objectForKey:@"value"] boolValue];
    self.webView.allowsLinkPreview = value;
}

// clang-format off
wh_doc_begin(interactivePopDisabled_, "设置当前控制器页面是否允许通过边缘手势右滑返回，如果开启，可通过右滑返回上级界面，否则无效果")
wh_doc_param(value, "布尔值， true 表示禁止，false 表示不禁止")
wh_doc_code(window.webViewHost.invoke("interactivePopDisabled",{"value": true}))
wh_doc_code_expect("侧滑返回将失效")
wh_doc_end;
// clang-format on
- (void)interactivePopDisabled:(NSDictionary *)paramDict {
    BOOL value = [[paramDict objectForKey:@"value"] boolValue];
    self.webViewHost.hd_interactivePopDisabled = value;
}

- (void)ready:(NSDictionary *)paramDict callback:(NSString *)callbackKey {
    // 进行相应的判断

    // 触发回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webViewHost fireCallback:callbackKey actionName:@"ready" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:nil];
    });
}

- (void)config:(NSDictionary *)paramDict callback:(NSString *)callbackKey {
    // 进行相应的判断

    // 触发回调
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webViewHost fireCallback:callbackKey actionName:@"config" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:nil];
    });
}

// clang-format off
wh_doc_begin(checkJsApi_$, "检查 API 是否实现，以键值对的形式返回，可用的 api 值 1，不可用为 0")
wh_doc_param(jsApiList, "要检查的方法列表")
wh_doc_code(window.webViewHost.invoke("checkJsApi",{"jsApiList": ["config", "ready", "method1", "getUserDevice"]}, function(params) {
    alert(JSON.stringify(params));
}))
wh_doc_code_expect("config、ready、getUserDevice为 1，method1 为 0")
wh_doc_end;
// clang-format on
- (void)checkJsApi:(NSDictionary *)paramDict callback:(NSString *)callbackKey {
    NSArray<NSString *> *list = [paramDict objectForKey:@"jsApiList"];

    NSDictionary *supportMethodListAndAppInfo = [self.webViewHost supportMethodListAndAppInfo];
    NSDictionary *supportMethodList = [supportMethodListAndAppInfo objectForKey:kHDWHSupportMethodListKey];

    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:list.count];

    NSMutableArray<NSString *> *supportMethodNameList = supportMethodList.allKeys.mutableCopy;
    [supportMethodNameList enumerateObjectsUsingBlock:^(NSString *_Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
        key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"$" withString:@""];
        supportMethodNameList[idx] = key;
    }];

    [list enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([supportMethodNameList containsObject:obj]) {
            result[obj] = @(true);
        } else {
            result[obj] = @(false);
        }
    }];

    [self.webViewHost fireCallback:callbackKey actionName:@"checkJsApi" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:result];
}
@end
