//
//  HDWHSchemeTaskResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHSchemeTaskDelegate.h"
#import "HDWebViewHostProtocol.h"

@interface HDWHSchemeTaskDelegate ()

/**
 保存自定义的
 handles
 */
@property (nonatomic, strong) NSMutableDictionary *customHandles;

@end

@implementation HDWHSchemeTaskDelegate

- (instancetype)init {
    if (self = [super init]) {
        self.customHandles = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

- (void)dealloc {
    HDWHLog(@"HDWHSchemeTaskDelegate dealloc");
}

- (void)addHandler:(HDWHURLSchemeTaskHandler)handler forDomain:(NSString * /* js */)domain {
    if (domain.length == 0 || handler == nil) {
        HDWHLog(@"domain or handle is null");
        return;
    }

    [self.customHandles setObject:handler forKey:domain];
}

#pragma mark - url task

- (void)webView:(WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    NSURLRequest *request = urlSchemeTask.request;
    NSString *path = [request.URL path];
    HDWHLog(@"URL = %@, allKey = %@", request.URL, [request.allHTTPHeaderFields allKeys]);
    NSData *data;
    NSString *host = [request.URL host];

    if (host.length == 0) {
        return;
    }

    NSString *mime = nil;
    HDWHURLSchemeTaskHandler handle = [self.customHandles objectForKey:host];
    if (handle) {
        data = handle(webView, urlSchemeTask, &mime);
    }

    // 上面没有处理，使用默认逻辑
    if (data == nil) {
        if ([host isEqualToString:kWebViewHostURLScriptHost]) {
            NSURL *url = [NSURL fileURLWithPath:path];
            data = [NSData dataWithContentsOfURL:url];
            mime = @"application/javascript";
            if (!data) {
                HDWHLog(@"Read script file error. The path is %@", url);
            }
        } else if ([host isEqualToString:kWebViewHostURLStyleHost]) {
            NSURL *url = [NSURL fileURLWithPath:path];
            data = [NSData dataWithContentsOfURL:url];
            mime = @"text/css";
            if (!data) {
                HDWHLog(@"Read style file error. The path is %@", url);
            }
        } else if ([host isEqualToString:kWebViewHostURLImageHost]) {
            NSURL *imageURL = [NSURL fileURLWithPath:path];
            data = [NSData dataWithContentsOfURL:imageURL];
            mime = @"image/png";
            if (!data) {
                HDWHLog(@"Read image file error. The path is %@", imageURL);
            }
        }
    }

    if (data == nil) {
        NSError *err = [[NSError alloc] initWithDomain:@"自定义的资源无法解析" code:-4003 userInfo:nil];
        [urlSchemeTask didFailWithError:err];
    } else {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:mime ?: @"text/plain" expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    }
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    HDWHLog(@"%@", NSStringFromSelector(_cmd));
}

@end
