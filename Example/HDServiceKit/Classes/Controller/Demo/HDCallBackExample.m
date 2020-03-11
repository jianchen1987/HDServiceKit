//
//  HDCallBackExample.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/10.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDCallBackExample.h"

@implementation HDCallBackExample
+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"kissme_$": kHDWHResponseMethodOn,
        @"killme": kHDWHResponseMethodOn,
        @"print_": kHDWHResponseMethodOn,
    };
}

- (void)killme {
    HDWHLog(@"%@", NSStringFromSelector(_cmd));
}


// clang-format off
wh_doc_begin(kissme_$, "测试 h5 调用原生并且收到回调")
wh_doc_param(text, "字符串，亲之前你要说什么话？")
wh_doc_code(window.webViewHost.invoke('kissme', { "text": "送你花花" }, function (p) { alert('收到原生给的回调' + JSON.stringify(p)); });)
wh_doc_code_expect("原生收到调用后2秒回调被触发，h5 收到消息")
wh_doc_end;
// clang-format on
- (void)kissme:(NSDictionary *)dict callback:(NSString *)callback {
    
    NSString *text = [dict objectForKey:@"text"];
    HDWHLog(@"%@ --- %@", NSStringFromSelector(_cmd), text);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self fireCallback:callback param:@{@"cbParam": @"你是什么品种的蛤蟆？"}];
    });
}

- (void)print:(NSDictionary *)dict {
    NSString *text = [dict objectForKey:@"text"];
    HDWHLog(@"%@ -- %@", NSStringFromSelector(_cmd), text);
}
@end
