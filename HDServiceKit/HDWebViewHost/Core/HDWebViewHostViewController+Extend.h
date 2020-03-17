//
//  HDServiceKitViewController+Extend.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHost.h"

NS_ASSUME_NONNULL_BEGIN

/**
 这个分类的意义在于为 HDWebViewHost 调用方，
 有对 webview 什么周期有特殊需要的时候，可以继承 HDWebViewHostViewController，并重载相应的方法实现自有逻辑。
 注意：一旦重载之后，在方法体里，需要调用 super 方法。
 
 重要提示: 为了让调用方可以自定义逻辑，有两种方式，
 一种是开放 super，使用继承的方式；
 一种是新增一个代理类，在不同的回调里，让调用方自行实现需要的方法。
 
 此外，我们也使用过 webviewjsbridge 对 UIWebview 和 WKWebview 上面封装的方式来提供接口分离，解耦。
 然后在实际的使用过程中，发现这是一种非常丑陋的提供灵活的方式。
 综合考虑，我们使用第一种，更灵活，缺点是开放了较多的接口，所以如非必要，不要继承 HDWebViewHostViewController 类。
 */
@interface HDWebViewHostViewController (Extend)

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error NS_REQUIRES_SUPER;

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
