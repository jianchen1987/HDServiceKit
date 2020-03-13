//
//  HDWebViewHostCookie.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebKit/WebKit.h>

@interface HDWebViewHostCookie : NSObject
/**
 针对处理cookie发生变化时的调用。如登录成功后的页面内跳转
 */
+ (NSMutableArray<NSString *> *)cookieJavaScriptArray;

+ (WKProcessPool *)sharedPoolManager;

// 以下和 cookie 同步相关
+ (void)setLoginCookieHasBeenSynced:(BOOL)synced;

+ (BOOL)loginCookieHasBeenSynced;
@end
