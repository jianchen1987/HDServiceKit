//
//  NSURLProtocol+HDWebViewHost.h
//  HDServiceKit
//
//  Created by Tia on 2022/7/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLProtocol (HDWebViewHost)

/// /// 激活schemelist和自定义nsurlprotocol子类
/// @param schemeList schemelist
/// @param protocolClass nsurlprotocol子类
+ (void)hd_registerSchemeList:(NSArray *)schemeList protocolClass:(Class)protocolClass;

/// /// 注销schemelist和自定义nsurlprotocol子类
/// @param schemeList schemelist
/// @param protocolClass nsurlprotocol子类
+ (void)hd_unregisterSchemeList:(NSArray *)schemeList protocolClass:(Class)protocolClass;

@end

NS_ASSUME_NONNULL_END
