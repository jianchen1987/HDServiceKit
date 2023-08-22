//
//  HDWHNavigationResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHNavigationResponse.h"
#import "HDWebViewHostViewController+Callback.h"
#import "HDWebViewHostViewController.h"
#import <SafariServices/SafariServices.h>

@implementation HDWHNavigationResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"startNewPage_": kHDWHResponseMethodOn,
        @"openExternalUrl_": kHDWHResponseMethodOn,
        @"closeWindow": kHDWHResponseMethodOn,
        @"enableWebViewGesture_$": kHDWHResponseMethodOn
    };
}

- (void)enableWebViewGesture:(NSDictionary *)paramDic callback:(NSString *)callBackKey {
    NSNumber *enable = paramDic[@"enable"];
    self.webViewHost.disableGesture = enable.boolValue;
    [self.webViewHost fireCallback:callBackKey actionName:@"enableWebViewGesture" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:@{}];
}

#pragma mark - inner
// clang-format off
wh_doc_begin(openExternalUrl_, "打开外部资源链接，可以用 SFSafariViewController 打开，也可以用系统的 Safari 浏览器打开。")
wh_doc_code(window.webViewHost.invoke("openExternalUrl",{"url":"https://www.chaosource.com/"}))
wh_doc_param(url, "字符串，合法的 url 地址，包括 http/mailto/telephone/https 等协议头")
wh_doc_param(openInSafari, "布尔值，默认是 false，表示在 App 内部用 SFSafariViewController 内部打开；true 表示用系统的 Safari 浏览器打开")
wh_doc_code_expect("在 App 内的浏览器里打开了’https://www.chaosource.com/‘ 页面")
wh_doc_end;
// clang-format on
- (void)openExternalUrl:(NSDictionary *)paramDict {
    NSString *urlTxt = [paramDict objectForKey:@"url"];
    BOOL forceOpenInSafari = [[paramDict objectForKey:@"openInSafari"] boolValue];
    if (forceOpenInSafari) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTxt] options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTxt]];
        }
    } else {
        SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlTxt]];
        [self.navigationController presentViewController:safari animated:YES completion:nil];
    }
}

- (void)insertShadowView:(NSDictionary *)paramDict {
    HDWebViewHostViewController *freshOne = [[self.webViewHost.class alloc] init];
    freshOne.url = [paramDict objectForKey:@"url"];
    freshOne.pageTitle = [paramDict objectForKey:@"title"];
    freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];
    freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];

    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 0) {
        //在A->B页面里，点击返回到C，然后C返回到A，形成 A-C-B，简化下成A——C；
        NSMutableArray *newViewControllers = [viewControllers mutableCopy];
        [newViewControllers addObject:freshOne];
        freshOne.hidesBottomBarWhenPushed = YES;
        self.navigationController.viewControllers = newViewControllers;
    }
}

// clang-format off
wh_doc_begin(startNewPage_, "新开一个 webview 页面打开目标 url。有多个参数可以控制 webview 的样式和行为")
wh_doc_code(window.webViewHost.invoke('startNewPage', { 'url': 'https://m.jd.com/','title': 'title',
    'type': "push",
    'backPageParameter': {
        'url': 'https://www.baidu.com',
        'title': 'title',
        'type': 'push'
    }
}))
wh_doc_param(url, "字符串，合法的 url 地址，包括http/mailto:/telephone:/https 前缀")
wh_doc_param(title, "当前页面的标题")
wh_doc_param(type, "新页面呈现方式，目前有两个参数可选 “push”，“replace” ")
wh_doc_param(actionTitle, "顶栏右边的文字，可以响应点击事件。")
wh_doc_param(backPageParameter, "完整的一个startNewPage对应的参数； 这个参数代表了页面 c，包含这个参数的跳转执行完毕之后，到达 b 页面，此时点击返回按钮，返回到 c页面，再次点击才返回到 a 页面。即 a -> b , b -> c -> a;")
wh_doc_code_expect("新开一个 webview 打开’https://m.jd.com/‘页面，加载完毕之后，点击返回，返回到 ’https://www.baidu.com‘ 页面")
wh_doc_end;
// clang-format on
- (void)startNewPage:(NSDictionary *)paramDict {

    HDWebViewHostViewController *freshOne = [[self.webViewHost.class alloc] initWithScript:[paramDict objectForKey:@"script"]];
    freshOne.url = [paramDict objectForKey:@"url"];
    freshOne.pageTitle = [paramDict objectForKey:@"title"];
    freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];
    freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
    NSString *loadType = [paramDict objectForKey:@"type"];
    if (freshOne.backPageParameter) {
        // 额外插入一个页面
        [self insertShadowView:freshOne.backPageParameter];
    }
    if ([@"replace" isEqualToString:loadType]) {
        NSArray *viewControllers = self.navigationController.viewControllers;

        if (viewControllers.count > 1) {
            // replace的目的就是调整到新的list页面；需要替换旧list和新的回复页面；
            NSMutableArray *newViewControllers = [[viewControllers subarrayWithRange:NSMakeRange(0, [viewControllers count] - 2)] mutableCopy];
            [newViewControllers addObject:freshOne];
            freshOne.hidesBottomBarWhenPushed = YES;
            [self.navigationController setViewControllers:newViewControllers animated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.navigationController pushViewController:freshOne animated:YES];
    }
}

// clang-format off
wh_doc_begin(closeWindow, "关闭当前窗口，会判断当前窗口的呈现方式")
wh_doc_code(window.webViewHost.invoke("closeWindow"))
wh_doc_code_expect("关闭当前窗口，回到上级页面")
wh_doc_end;
// clang-format on
- (void)closeWindow {
    if (self.webViewHost.presentingViewController) {
        [self.webViewHost dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (self.navigationController.viewControllers.count > 0) {
            if ([self.navigationController.viewControllers.lastObject isKindOfClass:self.webViewHost.class]) {
                [self.navigationController popViewControllerAnimated:NO];
            }else{
                for (UIViewController *childVC in [self.navigationController.viewControllers reverseObjectEnumerator]) {
                    if ([childVC isKindOfClass:self.webViewHost.class]) {
                        [childVC removeFromParentViewController];
                        return;
                    }
                }
            }
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    
    if (!self.webViewHost.isExecutedCloseByUser && self.webViewHost.closeByUser) {
        self.webViewHost.closeByUser();
        self.webViewHost.isExecutedCloseByUser = YES;
    }
}

@end
