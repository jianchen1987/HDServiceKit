//
//  MKAppLoggerResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHAppLoggerResponse.h"

@implementation HDWHAppLoggerResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"log_": kHDWHResponseMethodOn
    };
}

// clang-format off
wh_doc_begin(log_, "在 xcode 控制台输出日志")
wh_doc_param(logData, "日志字段，通常是json 对象")
wh_doc_code(window.webViewHost.invoke("log", {"text": "Error"}))
wh_doc_code_expect("会在 xcode 控制台输出日志信息，输出 text: Error, 日志包含了 [HDWebViewHost] 前缀")
wh_doc_end;
// clang-format on
- (void)log:(NSDictionary *)logData {
    HDWHLog(@"Logs from webview: %@", logData);
}

@end
