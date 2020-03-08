//
//  NSBundle+HDWebViewHost.h
//  HDUIKit
//
//  Created by VanJay on 2020/3/4.
//  Copyright © 2019 chaos network technology. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (HDWebViewHost)

/// HDWebViewHostRemoteDebug 资源包
+ (NSBundle *)hd_WebViewHostCoreResources;

/// HDWebViewHostRemoteDebugResources 资源包
+ (NSBundle *)hd_WebViewHostRemoteDebugResourcesBundle;

/// HDWebViewHostPreloaderResources 资源包
+ (NSBundle *)hd_WebViewHostPreloaderResourcesBundle;
@end

NS_ASSUME_NONNULL_END
