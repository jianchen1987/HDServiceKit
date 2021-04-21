//
//  HDWHNavigationBarResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHNavigationBarResponse.h"
#import "HDWebViewHostViewController+Dispatch.h"
#import "NSBundle+HDWebViewHost.h"
#import "HDWebViewHostViewController+Callback.h"
#import <HDUIKit/UIViewController+HDNavigationBar.h>
#import <HDKitCore/UIColor+HDKitCore.h>

@interface HDWHNavigationBarResponse ()
/// 以下是 short hand，都是从 webViewHost 上的属性
@property (nonatomic, copy) NSString *rightActionBarTitle;
@end

@implementation HDWHNavigationBarResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"goBack": kHDWHResponseMethodOn,
        @"setNavRightTitle_": kHDWHResponseMethodOn,
        @"setNavigationBarTitle_": kHDWHResponseMethodOn,
        @"showRightMenu": kHDWHResponseMethodOn,
        @"hideRightMenu": kHDWHResponseMethodOn,
        @"setWebViewBackStyle_$": kHDWHResponseMethodOn,
        @"setNavigationBarColor_": kHDWHResponseMethodOn,
        @"setNavigationBarStyle_": kHDWHResponseMethodOn
    };
}

- (void)setWebViewBackStyle:(NSDictionary *)paramDict callback:(NSString *)callBackKey {
    NSString *style = paramDict[@"style"];
    if(!style || !([style isEqualToString:HDWebViewBakcButtonStyleGoBack] || [style isEqualToString:HDWebViewBakcButtonStyleClose])) {
        [self.webViewHost fireCallback:callBackKey actionName:@"setWebViewBackStyle" code:HDWHRespCodeIllegalArg type:HDWHCallbackTypeFail params:@{}];
        return;
    }
    self.webViewHost.backButtonStyle = style;
    [self.webViewHost fireCallback:callBackKey actionName:@"setWebViewBackStyle" code:HDWHRespCodeSuccess type:HDWHCallbackTypeSuccess params:@{}];
}

#pragma mark - inner
// clang-format off
wh_doc_begin(goBack, "h5 页面的返回，如果可以返回到上一个 h5 页面则返回上一个 h5，否则退出 webview 页面，如果是弹出的 webview，还可能关闭这个 presented 的 ViewController。")
wh_doc_code(window.webViewHost.invoke("goBack"))
wh_doc_code_expect("会关闭本页面")
wh_doc_end;
// clang-format on
- (void)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        [self initNavigationBarButtons];
    } else {
        [self.webViewHost callNative:@"closeWindow"];
    }
}

- (void)initNavigationBarButtons {
    if (self.webViewHost.presentingViewController) {
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
        self.webViewHost.navigationItem.leftBarButtonItem = close;
        self.webViewHost.navigationItem.accessibilityHint = @"关闭 HDWebViewHost 弹窗";
    }
}

- (void)dismissViewController:(id)sender {
    [self.webViewHost dismissViewControllerAnimated:YES completion:nil];
    if ([self.webViewHost.webViewHostDelegate respondsToSelector:@selector(onResponseEventOccurred:response:)]) {
        [self.webViewHost.webViewHostDelegate onResponseEventOccurred:kWebViewHostEventDismissalFromPresented response:self];
    }
}

#pragma mark - nav
// clang-format off
wh_doc_begin(setNavRightTitle_, "h5 页面的返回，如果可以返回到上一个 h5 页面则返回上一个 h5，否则退出 webview 页面")
wh_doc_code(window.webViewHost.on('navigationBar.rightButton.onclick',function(p){alert('你点击了'+ p.text +'按钮')});window.webViewHost.invoke("setNavRightTitle",{"text":"发射"}))
wh_doc_param(text, "字符串，右上角按钮的文案")
wh_doc_code_expect("右上角出现一个’发射‘按钮，点击这个按钮，会触发 h5 对右上角按钮的监听。表现：弹出 alert，文案是’你点击了发射按钮‘。")
wh_doc_end;
// clang-format on
- (void)setNavRightTitle:(NSDictionary *)paramDict {
    NSString *title = [paramDict objectForKey:@"text"];
    self.rightActionBarTitle = title;
    UIBarButtonItem *rightBarButton = nil;
    if (self.rightActionBarTitle.length > 0) {
        UIButton *rightBtn = [UIButton new];
        [rightBtn setTitle:self.rightActionBarTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:HDWHColorFromRGB(0x333333) forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(menuButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn sizeToFit];

        rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    self.webViewHost.hd_navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)setNavigationBarColor:(NSDictionary *)paramsDic {
    NSString *colorHexStr = [paramsDic objectForKey:@"colorHexStr"];
    self.webViewHost.hd_navBackgroundColor = [UIColor hd_colorWithHexString:colorHexStr];
    
}

- (void)setNavigationBarStyle:(NSDictionary *)paramsDic {
    NSString *style = [paramsDic objectForKey:@"style"];
    self.webViewHost.navigationBarStyle = style.integerValue;
    
}

// clang-format off
wh_doc_begin(setNavTitle_, "设置 webview 页面中间的标题")
wh_doc_code(window.webViewHost.invoke("setNavTitle",{"text": "315大促现场"}))
wh_doc_param(text, "字符串，整个 ViewController 的标题")
wh_doc_code_expect("标题栏中间出现设置的文案，’315大促现场‘")
wh_doc_end;
// clang-format on
- (void)setNavigationBarTitle:(NSDictionary *)paramDict {
    NSString *title = [paramDict objectForKey:@"title"];
    self.webViewHost.hd_navigationItem.title = title;
}

// clang-format off
wh_doc_begin(showRightMenu, "控制导航栏的菜单按钮的显示")
wh_doc_code(window.webViewHost.invoke("showRightMenu"))
wh_doc_code_expect("会显示导航栏菜单按钮")
wh_doc_end;
// clang-format on
- (void)showRightMenu {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"menu" inBundle:[NSBundle hd_WebViewHostCoreResources] compatibleWithTraitCollection:nil];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(menuButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.webViewHost.hd_navigationItem.rightBarButtonItem = item;
}

// clang-format off
wh_doc_begin(hideRightMenu, "控制导航栏的菜单按钮的隐藏")
wh_doc_code(window.webViewHost.invoke("hideRightMenu"))
wh_doc_code_expect("会隐藏导航栏菜单按钮")
wh_doc_end;
// clang-format on
- (void)hideRightMenu {
    self.webViewHost.hd_navigationItem.rightBarButtonItem = nil;
}

#pragma mark - event response
- (void)menuButtonClickedHandler:(UIButton *)button {
    HDWHLog(@"菜单按钮被点击");
    [self fire:@"navigationBar.rightButton.onclick" param:@{@"text": self.rightActionBarTitle}];
}

@end
