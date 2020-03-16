//
//  MKBuiltInResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHHudActionResponse.h"
#import "HDWebViewHostViewController.h"
#import <HDUIKit/HDTips.h>

@implementation HDWHHudActionResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"toast_": kHDWHResponseMethodOn,
        @"showLoading_": kHDWHResponseMethodOn,
        @"hideLoading": kHDWHResponseMethodOn
    };
}

#pragma mark - inner

// clang-format off
wh_doc_begin(showLoading_, "loading 的 HUD 动画，这里是HDWebViewHost默认实现显示。")
wh_doc_param(text, "字符串，设置和 loading 动画一起显示的文案")
wh_doc_code(window.webViewHost.invoke("showLoading",{"text":"请稍等..."}))
wh_doc_code_expect("在屏幕上出现 loading 动画，多次调用此接口，不应该出现多个")
wh_doc_end;
// clang-format on
- (void)showLoading:(NSDictionary *)paramDict {
    NSString *tip = [paramDict objectForKey:@"text"];
    if (tip && [tip isKindOfClass:NSString.class] && tip.length > 0) {
        [HDTips showLoading:tip inView:self.webViewHost.webView];
    } else {
        [HDTips showLoadingInView:self.webViewHost.webView];
    }
}

// clang-format off
wh_doc_begin(hideLoading, "隐藏 loading 的 HUD 动画，这里是HDWebViewHost默认实现显示。")
wh_doc_code(window.webViewHost.invoke("hideLoading"))
wh_doc_code_expect("在有 loading 动画的情况下，调用此接口，会隐藏 loading。")
wh_doc_end;
// clang-format on
- (void)hideLoading {
    [HDTips hideAllTipsInView:self.webViewHost.webView];
}

// clang-format off
wh_doc_begin(toast_, "显示居中的提示，过几秒后消失，这里是HDWebViewHost默认实现显示。")
wh_doc_param(text, "字符串，显示的文案，可多行")
wh_doc_code(window.webViewHost.invoke("toast",{"text":"请稍等..."}))
wh_doc_code_expect("在屏幕上出现 '请稍等...'，多次调用此接口，不应该出现多个")
wh_doc_end;
// clang-format on
- (void)toast:(NSDictionary *)paramDict {
    CGFloat delay = [[paramDict objectForKey:@"delay"] floatValue];
    NSString *text = [paramDict objectForKey:@"text"];
    [self showTextTip:text delay:delay];
}

- (void)showTextTip:(NSString *)text delay:(CGFloat)delay {
    delay = delay <= 0 ? -1 : delay;
    HDTips *tip = [HDTips showWithText:text inView:self.webViewHost.webView hideAfterDelay:delay];
    tip.toastPosition = HDToastViewPositionBottom;
}
@end
