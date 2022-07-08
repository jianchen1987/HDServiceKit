//
//  NSURLProtocol+HDWebViewHost.m
//  HDServiceKit
//
//  Created by Tia on 2022/7/7.
//

#import "NSURLProtocol+HDWebViewHost.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
/**
 * The functions below use some undocumented APIs, which may lead to rejection by Apple.
 */

FOUNDATION_STATIC_INLINE Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    }
    return cls;
}

FOUNDATION_STATIC_INLINE SEL RegisterSchemeSelector() {
    return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
}

FOUNDATION_STATIC_INLINE SEL UnregisterSchemeSelector() {
    return NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
}

@implementation NSURLProtocol (HDWebViewHost)

#pragma mark public methods
+ (void)hd_registerSchemeList:(NSArray *)schemeList protocolClass:(Class)protocolClass {
    [self _hookSchemeList:schemeList protocolClass:protocolClass sel:RegisterSchemeSelector() isgister:YES];
}

+ (void)hd_unregisterSchemeList:(NSArray *)schemeList protocolClass:(Class)protocolClass {
    [self _hookSchemeList:schemeList protocolClass:protocolClass  sel:UnregisterSchemeSelector() isgister:NO];
}

#pragma mark private methods
+ (void)_hookSchemeList:(NSArray *)schemeList protocolClass:(Class)protocolClass sel:(SEL)sel isgister:(BOOL)isRegister {
    if (!protocolClass) return;
    //是否存在该类
    if (![NSStringFromClass(protocolClass) length]) return;
    //是否为NSURLProtocol子类
    if (![protocolClass isKindOfClass:object_getClass(self)]) return;

    Class cls = ContextControllerClass();

    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        for (NSString *scheme in schemeList) {
            [(id)cls performSelector:sel withObject:scheme];
        }
#pragma clang diagnostic pop
    }
    isRegister ? [self registerClass:protocolClass] : [self unregisterClass:protocolClass];
}

@end
