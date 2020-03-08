//
//  HDWebviewHostViewController+Scripts.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController+Scripts.h"
#import "HDWebViewHostViewController+Utils.h"

@implementation HDWebViewHostViewController (Scripts)

- (void)insertData:(NSDictionary *)json intoPageWithVarName:(NSString *)appProperty {
    NSData *objectOfJSON = nil;
    NSError *contentParseError = nil;

    objectOfJSON = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&contentParseError];
    if (contentParseError == nil && objectOfJSON) {
        NSString *str = [[NSString alloc] initWithData:objectOfJSON encoding:NSUTF8StringEncoding];
        [self executeJavaScriptString:[NSString stringWithFormat:@"if(window.webViewHost){window.webViewHost.%@ = %@;}", appProperty, str]];
    }
}

- (void)executeJavaScriptString:(NSString *)javaScriptString {
    [self.webView evaluateJavaScript:javaScriptString completionHandler:nil];
}

- (void)evalExpression:(NSString *)jsCode completion:(void (^)(id result, NSString *err))completion {
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"window.wh_eval(%@)", jsCode]
                   completionHandler:^(NSDictionary *data, NSError *_Nullable error) {
                       if (completion) {
                           completion([data objectForKey:@"result"], [data objectForKey:@"err"]);
                       } else {
                           NSLog(@"evalExpression result = %@", data);
                       }
                   }];
}

#pragma mark - public

- (void)fireCallback:(NSString *)callbackKey param:(NSDictionary *)paramDict {
    [self __execScript:callbackKey funcName:@"__callback" param:paramDict];
}

- (void)fire:(NSString *)actionName param:(NSDictionary *)paramDict {
    [self __execScript:actionName funcName:@"__fire" param:paramDict];
}

- (void)__execScript:(NSString *)actionName funcName:(NSString *)funcName param:(NSDictionary *)paramDict {
    NSData *objectOfJSON = nil;
    NSError *contentParseError;

    objectOfJSON = [NSJSONSerialization dataWithJSONObject:paramDict options:NSJSONWritingPrettyPrinted error:&contentParseError];

    NSString *jsCode = [NSString stringWithFormat:@"window.webViewHost.%@('%@',%@);", funcName, actionName, [[NSString alloc] initWithData:objectOfJSON encoding:NSUTF8StringEncoding]];
    jsCode = [jsCode stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [self executeJavaScriptString:jsCode];

    [[NSNotificationCenter defaultCenter] postNotificationName:kWebViewHostInvokeResponseEvent
                                                        object:@{
                                                            kWHActionKey: actionName,
                                                            kWHParamKey: paramDict
                                                        }];
}

+ (void)prepareJavaScript:(id)script when:(WKUserScriptInjectionTime)injectTime key:(NSString *)key {
    if ([script isKindOfClass:NSString.class]) {
        [self _addJavaScript:script when:injectTime forKey:key];
    } else if ([script isKindOfClass:NSURL.class]) {
        NSString *result = NULL;
        NSURL *urlToRequest = (NSURL *)script;
        if (urlToRequest) {
            // 这里使用异步下载的方式，也可以使用 stringWithContentOfURL 的方法，同步获取字符串
            // 注意1：http 的资源不会被 https 的网站加载 // upgrade-insecure-requests
            // 注意2：stringWithContentOfURL 获取的 weinre文件，需要设置 ServerURL blabla 的东西
            result = [NSString stringWithFormat:wh_ml((function(e) {
                                                          e.setAttribute("src", '%@');
                                                          document.getElementsByTagName('body')[0].appendChild(e);
                                                      })(document.createElement('script'));),
                                                urlToRequest.absoluteString];
            [self _addJavaScript:result when:injectTime forKey:key];
        }
    } else {
        HDWHLog(@"fail to inject javascript");
    }
}

static NSMutableArray *kWebViewHostCustomJavscripts = nil;
+ (void)_addJavaScript:(NSString *)script when:(WKUserScriptInjectionTime)injectTime forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kWebViewHostCustomJavscripts = [NSMutableArray arrayWithCapacity:4];
    });

    @synchronized(kWebViewHostCustomJavscripts) {
        [kWebViewHostCustomJavscripts addObject:@{
            @"script": script,
            @"when": @(injectTime),
            @"key": key
        }];
    }
}

+ (void)removeJavaScriptForKey:(NSString *)key {
    @synchronized(kWebViewHostCustomJavscripts) {
        [kWebViewHostCustomJavscripts enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if ([obj objectForKey:key]) {
                [kWebViewHostCustomJavscripts removeObject:obj];
                *stop = YES;
            }
        }];
    }
}

static NSString *kWebViewHostSource = nil;
- (void)injectScriptsToUserContent:(WKUserContentController *)userContentController {
    NSBundle *bundle = [NSBundle bundleForClass:HDWebViewHostViewController.class];
    // 注入关键 js 文件, 有缓存
    if (kWebViewHostSource == nil) {
        NSURL *jsLibURL = [[bundle bundleURL] URLByAppendingPathComponent:@"webViewHost_version_1.0.0.js"];
        kWebViewHostSource = [NSString stringWithContentsOfURL:jsLibURL encoding:NSUTF8StringEncoding error:nil];
        [self.class _addJavaScript:kWebViewHostSource when:WKUserScriptInjectionTimeAtDocumentStart forKey:@"webViewHost.js"];

        // 注入脚本，用来代替 self.webView evaluateJavaScript:javaScriptString completionHandler:nil
        // 因为 evaluateJavaScript 的返回值不支持那么多的序列化结构的数据结构，还有内存泄漏的问题
        jsLibURL = [[bundle bundleURL] URLByAppendingPathComponent:@"eval.js"];
        NSString *evalJS = [NSString stringWithContentsOfURL:jsLibURL encoding:NSUTF8StringEncoding error:nil];
        [self.class _addJavaScript:evalJS when:WKUserScriptInjectionTimeAtDocumentEnd forKey:@"eval.js"];
    }
    [kWebViewHostCustomJavscripts enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:[obj objectForKey:@"script"] injectionTime:[[obj objectForKey:@"when"] integerValue] forMainFrameOnly:YES];
        [userContentController addUserScript:cookieScript];
    }];
}

@end
