//
//  HDServiceKitViewController.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController.h"
#import "HDReachability.h"
#import "HDWHAppLoggerResponse.h"
#import "HDWHDebugResponse.h"
#import "HDWHNavigationBarResponse.h"
#import "HDWHRequestMediate.h"
#import "HDWHResponseManager.h"
#import "HDWHScriptMessageDelegate.h"
#import "HDWHURLChecker.h"
#import "HDWHWebViewScrollPositionManager.h"
#import "HDWebViewHostCookie.h"
#import "HDWebViewHostViewController+Dispatch.h"
#import "HDWebViewHostViewController+Progressor.h"
#import "HDWebViewHostViewController+Scripts.h"
#import "HDWebViewHostViewController+Timing.h"
#import "HDWebViewHostViewController+Utils.h"
#import "NSBundle+HDWebViewHost.h"
#import <HDUIKit/UIViewController+HDNavigationBar.h>
#import <Masonry/Masonry.h>
#import <HDUIKit/UIViewPlaceholder.h>
#import <HDKitCore/HDCommonDefines.h>
#import <HDKitCore/NSBundle+HDKitCore.h>

#define LocalizableString(key, value) \
    HDLocalizedStringInBundleForLanguageFromTable([NSBundle hd_bundleInFramework:@"HDServiceKit" bundleName:@"HDWebViewHostCoreResources"], [self getCurrentLanguage], key, value, nil)

static NSTimeInterval const kTimeoutInterval = 60;

HDWebViewBakcButtonStyle const HDWebViewBakcButtonStyleClose = @"close";    ///< 关闭
HDWebViewBakcButtonStyle const HDWebViewBakcButtonStyleGoBack = @"goBack";  ///< 返回

@interface HDWebViewHostViewController () <UIScrollViewDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) HDWHSchemeTaskDelegate *taskDelegate API_AVAILABLE(ios(11));
@end

// 是否将客户端的 cookie 同步到 WKWebview 的 cookie 当中
// 作为写 cookie 的假地址
NSString *_Nonnull kFakeCookieWebPageURLWithQueryString;
// 以下两个是为了设置进度条颜色和日志开关
long long kWebViewProgressTintColorRGB;
#if DEBUG
BOOL kGCDWebServer_logging_enabled = true;
#else
BOOL kGCDWebServer_logging_enabled = false;
#endif

/**
 * 代理类，管理所有 HDWebViewHostViewController 自身和 HDWebViewHostViewController 子类。
 * 使更具模块化，在保持灵活的同时，也保留了可读性。
 * 整体设计思路是：
 1. 维护了所有可支持 h5 的类名的数组（如[HDWHLogger]，以及这些类名的实例化的对象)，未使用到的不必实例化，做延迟实例化。
 2. 设计一个 protocol ，所有可支持 h5 的类名 都遵循这一协议。
 */

@implementation HDWebViewHostViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.view addSubview:self.webView];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.navigationBarStyle = HDViewControllerNavigationBarStyleWhite;
    }
    return self;
}

- (instancetype)initWithScript:(NSString *_Nullable)script {
    self = [super init];
    if (self) {
        self.startupScript = script;
        [self.view addSubview:self.webView];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.navigationBarStyle = HDViewControllerNavigationBarStyleWhite;
    }
    return self;
}

- (void)updateViewConstraints {

    HDViewControllerNavigationBarStyle style = [self hd_preferredNavigationBarStyle];

    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        if (HDViewControllerNavigationBarStyleHidden == style || HDViewControllerNavigationBarStyleTransparent == style) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
        } else {
            make.top.equalTo(self.hd_navigationBar.mas_bottom);
        }
    }];

    [super updateViewConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self setupProgressor];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(reloadPage:) name:kWebViewHostNotificationReload object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *urlStr = nil;
    if (self.webView && !self.webView.isLoading) {
        urlStr = [[self.webView URL] absoluteString];
    }
    if (urlStr.length == 0) {
        urlStr = self.url;
    }

    [self fire:@"pageshow" param:@{@"url": urlStr ?: @"null"}];
    // 检查是否有上次遗留下来的进度条,避免 webview 在 tabbar 第一屏时出现进度条残留
    if (self.webView.estimatedProgress >= 1.f) {
        [self stopProgressor];
    }
    if (!self.backButtonStyle || [self.backButtonStyle isEqualToString:@""]) {
        self.backButtonStyle = HDWebViewBakcButtonStyleClose;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSString *urlStr = [[self.webView URL] absoluteString];
    if (urlStr.length == 0) {
        urlStr = self.url;
    }
    [self fire:@"pagehide" param:@{@"url": urlStr ?: @"null"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    [[HDWHWebViewScrollPositionManager sharedInstance] clearAllCache];
}

- (void)dealloc {
    [self teardownProgressor];

    [NSNotificationCenter.defaultCenter removeObserver:self name:kWebViewHostNotificationReload object:nil];

    [_webView.configuration.userContentController removeScriptMessageHandlerForName:kWHScriptHandlerName];

    _webView.navigationDelegate = nil;
    _webView.scrollView.delegate = nil;
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
    HDWHLog(@"HDWebViewHostViewController dealloc");
}

#pragma mark - public
//https://stackoverflow.com/questions/49826107/wkwebview-custom-url-scheme-doesnt-work-with-https-mixed-content-blocked
- (void)loadLocalFile:(NSURL *)url domain:(NSString *)domain {
    _url = domain;
    NSError *err;
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *content = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&err];

    if (err == nil && content.length > 0 && domain.length > 0) {
        [self mark:kWebViewHostTimingLoadRequest];
        [self.webView loadHTMLString:content baseURL:[NSURL URLWithString:domain]];
    } else {
        NSAssert(NO, @"加载本地文件出错，关键参数为空");
        HDWHLog(@"加载本地文件出错，关键参数为空");
    }
}

- (void)loadIndexFile:(NSString *)fileName inDirectory:(NSURL *)directory domain:(NSString *)domain {
    if (fileName.length == 0 && directory == nil) {
        HDWHLog(@"文件参数错误");
        return;
    }
    _url = domain;
    NSString *htmlContent = nil;
    [HDWHRequestMediate interMediateFile:fileName inDirectory:directory domain:domain output:&htmlContent];

    if (htmlContent.length > 0 && domain.length > 0) {
        [self mark:kWebViewHostTimingLoadRequest];
        [self.webView loadHTMLString:htmlContent baseURL:[NSURL URLWithString:domain]];
    } else {
        NSAssert(NO, @"加载文件夹出错，关键参数为空");
        HDWHLog(@"加载文件夹出错，关键参数为空");
    }
}

#pragma mark - private methods

/// 修复打开链接Cookie丢失问题
/// @param request 请求
- (NSURLRequest *)fixedRequest:(NSURLRequest *)request {
    NSMutableURLRequest *fixedRequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        fixedRequest = (NSMutableURLRequest *)request;
    } else {
        fixedRequest = request.mutableCopy;
    }
    // 防止Cookie丢失
    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    if (dict.count) {
        NSMutableDictionary *mDict = request.allHTTPHeaderFields.mutableCopy;
        [mDict setValuesForKeysWithDictionary:dict];
        fixedRequest.allHTTPHeaderFields = mDict;
    }
    fixedRequest.cachePolicy = NSURLRequestReloadRevalidatingCacheData;
    fixedRequest.timeoutInterval = kTimeoutInterval;
    [self updateRequestAcceptLanguage:fixedRequest];
    return fixedRequest;
}

/// 设置语言
- (void)updateRequestAcceptLanguage:(NSMutableURLRequest *)request {
    NSString *currentLanguage = [self getCurrentLanguage];
    [request setValue:currentLanguage forHTTPHeaderField:@"Accept-Language"];

    NSString *ua = [NSString stringWithFormat:@" %@/%@ AcceptLanguage/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                                              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], currentLanguage];

    if (@available(iOS 12.0, *)) {
        NSString *baseAgent = [self.webView valueForKey:@"applicationNameForUserAgent"];
        if ([baseAgent rangeOfString:ua].location == NSNotFound) {
            NSString *userAgent = [NSString stringWithFormat:@"%@%@", baseAgent, ua];
            [self.webView setValue:userAgent forKey:@"applicationNameForUserAgent"];
        }
    }

    if (@available(iOS 9.0, *)) {
        __weak __typeof(self) weakSelf = self;
        [self.webView evaluateJavaScript:@"navigator.userAgent"
                       completionHandler:^(id _Nullable result, NSError *_Nullable error) {
                           __strong __typeof(weakSelf) strongSelf = weakSelf;
                           if (!error) {
                               HDWHLog(@"获取UA成功:%@", result);
                               if ([result rangeOfString:ua].location == NSNotFound) {
                                   [strongSelf.webView setCustomUserAgent:[result stringByAppendingString:ua]];
                               }
                           } else {
                               [strongSelf.webView setCustomUserAgent:ua];
                           }
                       }];
    } else {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:ua, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.webView setValue:ua forKey:@"applicationNameForUserAgent"];
    }
}

- (void)reloadPage:(NSNotification *)notification {
    [self.webView reload];
}

- (void)showPlacholderViewWithErrorMessage:(NSString *)errorMessage {
    UIViewPlaceholderViewModel *placeholderViewModel = UIViewPlaceholderViewModel.new;
    placeholderViewModel.title = errorMessage;
    placeholderViewModel.image = @"no_data_placeholder";
    placeholderViewModel.needRefreshBtn = YES;
    __weak __typeof(self) weakSelf = self;
    placeholderViewModel.clickOnRefreshButtonHandler = ^{
        __strong __typeof(weakSelf) self = weakSelf;
        [self.view hd_removePlaceholderView];
        [self loadWebPageWithURL];
    };
    placeholderViewModel.refreshBtnTitle = LocalizableString(@"refresh_loading", @"刷新");
    
    [self.view hd_showPlaceholderViewWithModel:placeholderViewModel];
}

#pragma mark - UI相关
- (void)loadWebPageWithURL {
    NSURL *url = [NSURL URLWithString:self.url];
    if (url == nil) {
        HDWHLog(@"loadUrl is nil，loadUrl = %@", self.url);
        [self showTextTip:LocalizableString(@"empty_url", @"地址为空")];
        [self showPlacholderViewWithErrorMessage:LocalizableString(@"empty_url", @"地址为空")];
        return;
    }
    // 检查网络是否联网
    HDReachability *reachability = [HDReachability reachabilityForInternetConnection];
    if ([reachability isReachable]) {
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeoutInterval];
        [self mark:kWebViewHostTimingLoadRequest];
        [self updateRequestAcceptLanguage:mutableRequest];
        [self.webView loadRequest:mutableRequest];
    } else {
        [self showTextTip:LocalizableString(@"network_down", @"网络断开了，请检查网络。") hideAfterDelay:10.f];
        [self showPlacholderViewWithErrorMessage:LocalizableString(@"network_down", @"网络断开了，请检查网络。")];
    }
}

#pragma mark - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
    // 不打开新窗口
    if (!navigationAction.targetFrame.isMainFrame) {
        [self.webView loadRequest:[self fixedRequest:navigationAction.request]];
    }
    HDWHLog(@"%@", NSStringFromSelector(_cmd));
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizableString(@"prompt", @"提示") message:message ?: @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:LocalizableString(@"confirm", @"确认")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           completionHandler();
                                                       }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:LocalizableString(@"cancel", @"取消")
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(NO);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:LocalizableString(@"confirm", @"确定")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [self presentViewController:alertController
                       animated:YES
                     completion:^{
                     }];
}

#pragma mark - WKNavigationDelegate

#define TIMING_WK_METHOD \
    HDWHLog(@"[Timing] %@, nowTime = %f", NSStringFromSelector(_cmd), [[NSDate date] timeIntervalSince1970] * 1000);

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    TIMING_WK_METHOD;
    [self measure:kWebViewHostTimingDecidePolicyForNavigationAction
               to:kWebViewHostTimingLoadRequest];
    [self measure:kWebViewHostTimingDecidePolicyForNavigationAction to:kWebViewHostTimingWebViewInit];

    NSURLRequest *request = navigationAction.request;
    // 此url解析规则自己定义
    NSString *rurl = [[request URL] absoluteString];
    HDWHLog(@"加载网页地址 = %@", rurl);
    WKNavigationActionPolicy policy = WKNavigationActionPolicyAllow;

    if ([self isItmsAppsRequest:rurl]) {
        // URL Scheme and App Store links won't work https://github.com/ShingoFukuyama/WKWebViewTips#url-scheme-and-app-store-links-wont-work
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(popOutImmediately) userInfo:nil repeats:NO];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[request URL] options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [[UIApplication sharedApplication] openURL:[request URL]];
        }
        policy = WKNavigationActionPolicyCancel;
    } else if ([self isExternalSchemeRequest:rurl]) {  // 非 http，https 协议的请求，走默认逻辑，容许广告页面之间唤起响应的 App
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[request URL] options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [[UIApplication sharedApplication] openURL:[request URL]];
        }
        policy = WKNavigationActionPolicyCancel;
    }

    // 解决Cookie丢失问题
    NSURLRequest *originalRequest = navigationAction.request;
    [self fixedRequest:originalRequest];

    decisionHandler(policy);
    if (self.disabledProgressor) {
        self.progressorView.hidden = YES;
    } else if (policy == WKNavigationActionPolicyAllow) {
        [self startProgressor];
    }

    //H5页面跳转不一定会触发 didFinishNavigation 回调，在这里重新获取一次
    [self callNative:@"setNavigationBarTitle"
           parameter:@{
               @"title": self.webView.title ?: self.pageTitle
           }];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    TIMING_WK_METHOD;
    [self startProgressor];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler {
    TIMING_WK_METHOD;

    //    [self getWebViewCookiesWithNavigationResponse:navigationResponse];

    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    TIMING_WK_METHOD;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    TIMING_WK_METHOD;
    // 开始加载网页时，将上一次的加载失败页面关闭
    [self.view hd_removePlaceholderView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    TIMING_WK_METHOD;
    [self measure:kWebViewHostTimingDidFinishNavigation
               to:kWebViewHostTimingLoadRequest];
    [self measure:kWebViewHostTimingDidFinishNavigation to:kWebViewHostTimingWebViewInit];

    if (webView.isLoading) {
        return;
    }
    NSURL *targetURL = webView.URL;
    // 如果是指明了 kFakeCookieWebPageURLWithQueryString 说明，需要同步此域下 Cookie；
    if (kFakeCookieWebPageURLWithQueryString.length > 0 && targetURL.query.length > 0 && [kFakeCookieWebPageURLWithQueryString containsString:targetURL.query]) {
        if ([HDWebViewHostCookie loginCookieHasBeenSynced] == NO) {
            [HDWebViewHostCookie setLoginCookieHasBeenSynced:YES];
            // 加载真正的页面；此时已经有 App 的 cookie 存在了。
            [webView removeFromSuperview];
        }
        [self loadWebPageWithURL];
        return;
    }
    // 如果是全新加载页面，而不是从历史里弹出的情况下，需要渲染导航
    if (![self.webView canGoForward] && self.rightActionBarTitle.length > 0) {
        [self callNative:@"setNavRight"
               parameter:@{
                   @"text": self.rightActionBarTitle
               }];
    }
    [self callNative:@"setNavigationBarTitle"
           parameter:@{
               @"title": self.webView.title ?: self.pageTitle
           }];

    // 设置发现的后台接口
    NSDictionary *inserted = [self supportMethodListAndAppInfo];
    [inserted enumerateKeysAndObjectsUsingBlock:^(NSString *keyStr, id obj, BOOL *stop) {
        [self insertData:obj intoPageWithVarName:keyStr];
    }];

    [self fire:@"ready" param:@{}];
    [self dealWithViewHistory];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    TIMING_WK_METHOD;
    [self stopProgressor];
    [self showPlacholderViewWithErrorMessage:error.localizedDescription];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    TIMING_WK_METHOD;
    HDWHLog(@"load page error = %@", error);
    [self stopProgressor];
    [self showPlacholderViewWithErrorMessage:error.localizedDescription];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kWHScriptHandlerName]) {
        NSURL *actualUrl = [NSURL URLWithString:self.url];
        if (![[HDWHURLChecker sharedManager] checkURL:actualUrl forAuthorizationType:HDWHAuthorizationTypeWebViewHost]) {
            HDWHLog(@"invalid url visited : %@", self.url);
        } else {
            id body = message.body;
            if ([body isKindOfClass:NSString.class]) {
                NSData *jsonData = [body dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                body = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&err];
            }
            // 测试用例触发的就不要验签
            if ([self.url isEqualToString:kHDWHTestcaseDomain]) {
                [self dispatchParsingParameter:body];
            } else {
                BOOL isDebugAction = false;
#ifdef HDWH_DEBUG
                // debug 命令也不要验签
                if ([HDWHDebugResponse isDebugAction:[body objectForKey:kWHActionKey]]) {
                    isDebugAction = true;
                    [self dispatchParsingParameter:body];
                }
#endif
                if (!isDebugAction) {
                    // 验签
                    NSDictionary *paramDict = [body objectForKey:kWHParamKey];
                    NSString *callbackKey = [body objectForKey:kWHCallbackKey];

                    // 取出业务参数
                    NSMutableDictionary *neededBody = [NSMutableDictionary dictionaryWithCapacity:3];
                    neededBody[kWHActionKey] = [body objectForKey:kWHActionKey];
                    neededBody[kWHCallbackKey] = callbackKey;
                    NSDictionary *bussParams = [paramDict objectForKey:kWHBussParamKey];
                    neededBody[kWHParamKey] = bussParams;
                    [self dispatchParsingParameter:neededBody];
                }
            }
        }
    } else {
#ifdef DEBUG
        [self showTextTip:@"没有实现的接口"];
#endif
        HDWHLog(@"unknown methods : %@", message.name);
    }
}

#pragma mark - Event
- (void)hd_backItemClick:(UIBarButtonItem *)sender {
    HDWHLog(@"返回按钮被点击啦！！");
    if ([self.backButtonStyle isEqualToString:HDWebViewBakcButtonStyleGoBack]) {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        } else {
            [self close];
        }
    } else {
        [self close];
    }
}

- (void)close {
    if (self.presentingViewController) {
        if (self.presentingViewController.presentedViewController == self) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            // 判断有没有导航控制器
            UINavigationController *navigationController = self.navigationController;
            if (navigationController) {
                // 判断是不是只有一个
                if (navigationController.viewControllers.count <= 1) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [navigationController popViewControllerAnimated:YES];
                }
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    !self.closeByUser ?: self.closeByUser();
}

#pragma mark - setters
- (void)setUrl:(NSString *)url {
    _url = url;

    if (kFakeCookieWebPageURLWithQueryString.length > 0 && [HDWebViewHostCookie loginCookieHasBeenSynced] == NO) {  // 此时需要同步 Cookie，走同步 Cookie 的流程
        NSURL *cookieURL = [NSURL URLWithString:kFakeCookieWebPageURLWithQueryString];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:cookieURL cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:kTimeoutInterval];
        WKWebView *cookieWebview = [self cookieWebview];
        [self.view addSubview:cookieWebview];
        [self mark:kWebViewHostTimingLoadRequest];
        [self updateRequestAcceptLanguage:mutableRequest];
        [cookieWebview loadRequest:mutableRequest];
    } else {
        [self loadWebPageWithURL];
    }
}

- (void)setDisableGesture:(BOOL)disableGesture {
    _disableGesture = disableGesture;
    self.hd_interactivePopDisabled = !disableGesture;
    self.hd_fullScreenPopDisabled = !disableGesture;
}

- (void)setBackButtonStyle:(HDWebViewBakcButtonStyle)backButtonStyle {
    _backButtonStyle = backButtonStyle;
    UIImage *image = nil;
    if ([backButtonStyle isEqualToString:HDWebViewBakcButtonStyleGoBack]) {
        image = [UIImage imageNamed:@"goBack" inBundle:[NSBundle hd_WebViewHostCoreResources] compatibleWithTraitCollection:nil];
    } else {
        image = [UIImage imageNamed:@"close" inBundle:[NSBundle hd_WebViewHostCoreResources] compatibleWithTraitCollection:nil];
    }
    self.hd_backButtonImage = image;
}

- (void)setNavigationBarStyle:(HDViewControllerNavigationBarStyle)navigationBarStyle {
    _navigationBarStyle = navigationBarStyle;
    [self forceUpdateNavigationBarStyle];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - getter
- (WKWebView *)cookieWebview {
    if (![kFakeCookieWebPageURLWithQueryString containsString:@"?"]) {
        NSAssert(NO, @"请配置 kFakeCookieWebPageURLString 参数，如在调用 HDWebViewHostViewController 的 .m 文件里定义，NSString *_Nonnull kFakeCookieWebPageURLWithQueryString = @\"https://www.chaosource.com?028-983cnhd8-2\"");
        return nil;
    }
    // 设置加载页面完毕后，里面的后续请求，如 xhr 请求使用的cookie
    WKUserContentController *userContentController = [WKUserContentController new];

    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    webViewConfig.userContentController = userContentController;
    webViewConfig.processPool = [HDWebViewHostCookie sharedPoolManager];

    NSMutableArray<NSString *> *oldCookies = [HDWebViewHostCookie cookieJavaScriptArray];
    [oldCookies enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *setCookie = [NSString stringWithFormat:@"document.cookie='%@';", obj];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:setCookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        [userContentController addUserScript:cookieScript];
    }];

    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, -1, HDWH_SCREEN_WIDTH, 0.1f) configuration:webViewConfig];
    webview.navigationDelegate = self;

    return webview;
}

- (WKWebView *)webView {
    if (_webView == nil) {
        [self mark:kWebViewHostTimingWebViewInit];
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addScriptMessageHandler:[[HDWHScriptMessageDelegate alloc] initWithDelegate:self] name:kWHScriptHandlerName];
        WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
        webViewConfig.userContentController = userContentController;
        webViewConfig.allowsInlineMediaPlayback = YES;
        webViewConfig.processPool = [HDWebViewHostCookie sharedPoolManager];
        if (@available(iOS 11.0, *)) {
            self.taskDelegate = [HDWHSchemeTaskDelegate new];
            [webViewConfig setURLSchemeHandler:self.taskDelegate forURLScheme:kWebViewHostURLScheme];
        }
        [self injectScriptsToUserContent:userContentController];
        [self measure:kWebViewHostTimingAddUserScript to:kWebViewHostTimingWebViewInit];
        WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
        if (@available(iOS 11.0, *)) {
            webview.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        webview.navigationDelegate = self;
        webview.UIDelegate = self;
        webview.scrollView.delegate = self;
        webview.allowsBackForwardNavigationGestures = true;
        webview.allowsLinkPreview = true;

        _webView = webview;
    }
    return _webView;
}

#pragma mark - vc settings

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.navBarStyle;
}

- (HDViewControllerNavigationBarStyle)hd_preferredNavigationBarStyle {
    return self.navigationBarStyle;
}
- (BOOL)hd_shouldHideNavigationBarBottomShadow {
    return HDViewControllerNavigationBarStyleTransparent == self.navigationBarStyle;
}

@end
