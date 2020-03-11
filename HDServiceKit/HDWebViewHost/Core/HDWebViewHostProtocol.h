//
//  HDWebViewHostProtocol.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class HDWebViewHostViewController;

static NSString *const kWebViewHostURLScheme = @"webviewhost";
static NSString *const kWebViewHostURLProtocal = @"webviewhost://";
static NSString *const kWebViewHostURLImageHost = @"image.webviewhost.chaos.cn";
static NSString *const kWebViewHostURLScriptHost = @"js.webviewhost.chaos.cn";
static NSString *const kWebViewHostURLStyleHost = @"css.webviewhost.chaos.cn";

#define HDWebViewHostURLScriptServer [kWebViewHostURLProtocal stringByAppendingString:kWebViewHostURLScriptHost]
#define HDWebViewHostURLStyleServer [kWebViewHostURLProtocal stringByAppendingString:kWebViewHostURLStyleHost]
#define HDWebViewHostURLImageServer [kWebViewHostURLProtocal stringByAppendingString:kWebViewHostURLImageHost]

@protocol HDWebViewHostProtocol <NSObject>

// 以下为 从HDWebViewHostViewController 里获得的 只读类属性
@property (nonatomic, weak, readonly) UINavigationController *navigationController;

@property (nonatomic, weak, readonly) WKWebView *webView;

@property (nonatomic, weak, readonly) HDWebViewHostViewController *webViewHost;

@required

- (instancetype)initWithWebViewHost:(HDWebViewHostViewController *)webViewHost;

/**
 尝试处理来自 h5 的请求，如果不能处理，则返回 NO。

 @param action h5 的 actionName
 @param paramDict 本次请求的参数
 @param callbackKey js 端匿名回调
 @return YES 表示可以处理，已处理；
 */
- (BOOL)handleAction:(NSString *)action withParam:(NSDictionary *)paramDict callbackKey:(NSString *)callbackKey;

/**
 类方法。表示当前请类型是否支持

 @param ActionSignature 表示 action 的签名，action 的名词加上"_","$",如 alert_$
 @return YES 表示支持，请注意
 */
+ (BOOL)isSupportedActionSignature:(NSString *)ActionSignature;

/**
 返回接口的支持情况， 申明为类方法是为了用同步的方法 返回给 webViewHost，作为 JS 的属性。
 其中 key 值后面的下划线 _ 表示是否需要参数。下划线 _ 数量表示有 param；$ 表示有 callback。在 HDWebViewHost 的接口中，只有 4 种接口；
 @return 形如，
    {
        @"alert": @"1",// 无参数
        @"alert$": @"1",// 有1参数，名字是 callbackKey
        @"alert_": @"1",// 有1参数，名字是 paramDict
        @"alert_$": @"1",// 有2参数， paramDict，callbackKey
    }
 */
+ (NSDictionary<NSString *, NSString *> *)supportActionList;

@end
