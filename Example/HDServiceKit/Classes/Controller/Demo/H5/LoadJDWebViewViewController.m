//
//  LoadJDWebViewViewController.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/11.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "LoadJDWebViewViewController.h"
#import <HDServiceKit/HDWebViewHost.h>

@interface LoadJDWebViewViewController ()

@end

@implementation LoadJDWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.webView.allowsBackForwardNavigationGestures = true;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURLRequest *request = navigationAction.request;
    //此url解析规则自己定义
    NSString *rurl = [[request URL] absoluteString];
    NSString *kProtocol = @"openapp.jdmobile://virtual?params=";
    if ([rurl hasPrefix:kProtocol]) {
        NSString *param = [rurl stringByReplacingOccurrencesOfString:kProtocol withString:@""];

        NSDictionary *contentJSON = nil;
        NSError *contentParseError;
        if (param) {
            param = [self stringDecodeURIComponent:param];
            contentJSON = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&contentParseError];
        }

        [self callNative:@"toast"
               parameter:@{
                   @"text": [contentJSON description]
               }];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        [super webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
}

- (NSString *)stringDecodeURIComponent:(NSString *)encoded {
    NSString *decoded = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)encoded, CFSTR(""));
    return decoded;
}
@end
