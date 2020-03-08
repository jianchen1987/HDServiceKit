//
//  MKBuiltInResponse.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHBuiltInResponse.h"
#import "HDWebViewHostViewController.h"

@implementation HDWHBuiltInResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList
{
    return @{
             @"toast_" : @"1",
             @"showLoading_" : @"1",
             @"hideLoading" : @"1",
             @"enablePageBounce_" : @"1"
             };
}

#pragma mark - inner

// clang-format off
wh_doc_begin(showLoading_, "loading 的 HUD 动画，这里是HDWebViewHost默认实现显示。")
wh_doc_param(text, "字符串，设置和 loading 动画一起显示的文案")
wh_doc_code(window.webViewHost.invoke("showLoading",{"text":"请稍等..."}))
wh_doc_code_expect("在屏幕上出现 loading 动画，多次调用此接口，不应该出现多个")
wh_doc_end
// clang-format on
- (void)showLoading:(NSDictionary *)paramDict
{
    NSString *tip = [paramDict objectForKey:@"text"];
    NSLog(@"Info: 正在显示 Loading 提示: %@，请使用本 App 的的 HUD 接口实现，以保持一致体验", tip);
}

// clang-format off
wh_doc_begin(hideLoading, "隐藏 loading 的 HUD 动画，这里是HDWebViewHost默认实现显示。")
wh_doc_code(window.webViewHost.invoke("hideLoading"))
wh_doc_code_expect("在有 loading 动画的情况下，调用此接口，会隐藏 loading。")
wh_doc_end
// clang-format on
- (void)hideLoading
{
    NSLog(@"Info: 关闭显示 HUD ，请使用本 App 的的 HUD 接口实现，以保持一致体验");
}

// clang-format off
wh_doc_begin(toast_, "显示居中的提示，过几秒后消失，这里是HDWebViewHost默认实现显示。")
wh_doc_param(text, "字符串，显示的文案，可多行")
wh_doc_code(window.webViewHost.invoke("toast",{"text":"请稍等..."}))
wh_doc_code_expect("在屏幕上出现 '请稍等...'，多次调用此接口，不应该出现多个")
wh_doc_end
// clang-format on
- (void)toast:(NSDictionary *)paramDict
{
    CGFloat delay = [[paramDict objectForKey:@"delay"] floatValue];
    [self showTextTip:[paramDict objectForKey:@"text"] delay:delay];
}

- (void)showTextTip:(NSString *)tip delay:(CGFloat)delay
{
    NSLog(@"Info: 正在显示 Toast 提示: %@, %f秒消失，请使用本 App 的的 HUD 接口实现，以保持一致体验", tip, delay);
}

// clang-format off
wh_doc_begin(enablePageBounce_, "容许触发 webview 下拉弹回的动画，传入 false 表示不容许；这个效果是 iOS 独有的")
wh_doc_param(enabled, "布尔值， true 表示开启，false 表示关闭")
wh_doc_code(window.webViewHost.invoke("enablePageBounce",{"enabled":false}))
wh_doc_code_expect("本测试页面在滑动到底部或顶部时，没有 bounce 效果，在执行之前，尝试滑动底部，会出现 bounce 效果。")
wh_doc_end
// clang-format on
- (void)enablePageBounce:(NSDictionary *)paramDict
{
    BOOL bounce = [[paramDict objectForKey:@"enabled"] boolValue];
    self.webView.scrollView.bounces = bounce;
}

@end
