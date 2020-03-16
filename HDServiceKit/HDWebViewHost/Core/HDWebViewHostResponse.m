//
//  HDWebViewHostResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostResponse.h"
#import "HDWebViewHostViewController+Scripts.h"
#import "HDWebViewHostViewController.h"
#import "NSObject+HDWebViewHost.h"
#import <objc/runtime.h>

@interface HDWebViewHostResponse ()

@property (nonatomic, weak, readwrite) WKWebView *webView;

@property (nonatomic, weak, readwrite) UINavigationController *navigationController;

@property (nonatomic, weak, readwrite) HDWebViewHostViewController *webViewHost;

@end

@implementation HDWebViewHostResponse

- (instancetype)initWithWebViewHost:(HDWebViewHostViewController *)webViewHost {
    if (self = [self init]) {
        self.webView = webViewHost.webView;
        self.navigationController = webViewHost.navigationController;
        self.webViewHost = webViewHost;
    }

    return self;
}

- (void)fireCallback:(NSString *)callbackKey param:(NSDictionary *)paramDict {
    [self.webViewHost fireCallback:callbackKey param:paramDict];
}

- (void)fire:(NSString *)actionName param:(NSDictionary *)paramDict {
    [self.webViewHost fire:actionName param:paramDict];
}

- (void)dealloc {
    _webView = nil;
    self.navigationController = nil;
    self.webViewHost = nil;
}

#pragma mark - HDWebViewHostProtocol

- (BOOL)handleAction:(NSString *)action withParam:(NSDictionary *)paramDict callbackKey:(NSString *)callbackKey {
    if (!action) {
        return false;
    }
    SEL sel = nil;
    if (!paramDict) {
        if (!callbackKey || callbackKey.length == 0) {
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@", action]);
        } else {
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@WithCallback:", action]);
        }
    } else {
        if (callbackKey.length == 0) {
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", action]);
        } else {
            sel = NSSelectorFromString([NSString stringWithFormat:@"%@:callback:", action]);
        }
    }

    if (![self respondsToSelector:sel]) {
        return NO;
    }

    [self hd_performSelector:sel withObjects:[NSArray arrayWithObjects:paramDict, callbackKey, nil]];
    return YES;
}

+ (BOOL)isSupportedActionSignature:(NSString *)signature {
    NSDictionary *support = [self supportActionList];

    // 如果数值大于0，表示是支持的，返回 YES
    if ([[support objectForKey:signature] integerValue] > 0) {
        return YES;
    }
    return NO;
}

+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    NSAssert(NO, @"Must implement handleActionFromH5 method");
    return @{};
}

#pragma - doc
/**
 TODO 可变参数如何传参？解决代码copy的问题
 解决生成 wh_doc 的文档里的参数对象
 
 @param desc 默认描述，如果是偶数个参数，则生成 param 对象。如果是单个参数则认为整体参数描述，不细分为小参数
 @return 返回一个字段对象
 */
+ (NSDictionary *)getParams:(NSString *)desc, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:4];

    va_list arg_list;
    va_start(arg_list, desc);  // 获取后续参数的偏移
    NSString *device = va_arg(arg_list, NSString *);
    NSMutableArray *lst = [NSMutableArray arrayWithCapacity:3];
    if (device) {
        [lst addObject:[device copy]];
    }

    while (device) {
        device = va_arg(arg_list, NSString *);
        [lst addObject:[device copy]];
    }
    va_end(arg_list);

    if (lst.count == 1) {
        [result setObject:[lst firstObject] forKey:@"paraDict"];
    } else if (lst.count > 1) {
        NSInteger count = lst.count / 2;
        for (NSInteger i = 0; i < count; i++) {
            [result setObject:[lst objectAtIndex:i * 2 + 1] forKey:[lst objectAtIndex:i * 2]];
        }
    }
    return result;
}
@end
