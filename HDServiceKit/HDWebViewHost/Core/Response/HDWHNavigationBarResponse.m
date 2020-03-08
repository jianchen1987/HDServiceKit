//
//  HDWHNavigationBarResponse.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHNavigationBarResponse.h"
#import "HDWebViewHostViewController.h"

@interface HDWHNavigationBarResponse ()

// 以下是 short hand，都是从webViewHost 上的属性
@property (nonatomic, copy) NSString *rightActionBarTitle;

@end

@implementation HDWHNavigationBarResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList
{
    return @{
             @"goBack" : @"1",
             @"setNavRight_" : @"1",
             @"setNavTitle_" : @"1"
             };
}

#pragma mark - inner
// clang-format off
wh_doc_begin(goBack, "h5 页面的返回，如果可以返回到上一个 h5 页面则返回上一个 h5，否则退出 webview 页面，如果是弹出的 webview，还可能关闭这个 presented 的 ViewController。")
wh_doc_code(window.webViewHost.invoke("goBack"))
wh_doc_code_expect("会关闭本页面")
wh_doc_end
// clang-format on
- (void)goBack
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        //
        [self initNavigationBarButtons];
    }else{
        [self didTapClose:nil];
    }
}

- (void)didTapClose:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initNavigationBarButtons
{
    if (self.webViewHost.presentingViewController) {
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain  target:self action:@selector(dismissViewController:)];
        self.webViewHost.navigationItem.leftBarButtonItem = close;
        self.webViewHost.navigationItem.accessibilityHint = @"关闭 HDWebViewHost 弹窗";
    }
}

- (void)dismissViewController:(id)sender
{
    [self.webViewHost dismissViewControllerAnimated:YES completion:nil];
    if ([self.webViewHost.webViewHostDelegate respondsToSelector:@selector(onResponseEventOccurred:response:)]) {
        [self.webViewHost.webViewHostDelegate onResponseEventOccurred:kWebViewHostEventDismissalFromPresented response:self];
    }
}

#pragma mark - nav
// clang-format off
wh_doc_begin(setNavRight_, "h5 页面的返回，如果可以返回到上一个 h5 页面则返回上一个 h5，否则退出 webview 页面")
wh_doc_code(window.webViewHost.on('navigator.rightbar.click',function(p){alert('你点击了'+p.text+'按钮')});window.webViewHost.invoke("setNavRight",{"text":"发射"}))
wh_doc_param(text, "字符串，右上角按钮的文案")
wh_doc_code_expect("右上角出现一个’发射‘按钮，点击这个按钮，会触发 h5 对右上角按钮的监听。表现：弹出 alert，文案是’你点击了发射按钮‘。")
wh_doc_end
// clang-format on
- (void)setNavRight:(NSDictionary *)paramDict
{
    NSString *title = [paramDict objectForKey:@"text"];
    self.rightActionBarTitle = title;
    UIBarButtonItem *rightBarButton = nil;
    
    if (self.rightActionBarTitle.length > 0) {
        UIButton *rightBtn = [UIButton new];
        [rightBtn setTitle:self.rightActionBarTitle forState:UIControlStateNormal];
        [rightBtn setTitleColor:HDWHColorFromRGB(0x333333) forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(didTapMore:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn sizeToFit];
        
        rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    self.webViewHost.navigationItem.rightBarButtonItem = rightBarButton;
}

// clang-format off
wh_doc_begin(setNavTitle_, "设置 webview 页面中间的标题")
wh_doc_code(window.webViewHost.invoke("setNavTitle",{"text":"酒泉卫星发射中心"}))
wh_doc_param(text, "字符串，整个 ViewController 的标题")
wh_doc_code_expect("标题栏中间出现设置的文案，’酒泉卫星发射中心‘")
wh_doc_end
// clang-format on
- (void)setNavTitle:(NSDictionary *)paramDict
{
    NSString *title = [paramDict objectForKey:@"text"];
    self.webViewHost.hd_navigationItem.title = title;
}

#pragma mark - event
- (void)didTapMore:(id)sender
{
    if (self.rightActionBarTitle) {
        [self fire:@"navigator.rightbar.click" param:@{@"text": self.rightActionBarTitle}];
    }
}

@end
