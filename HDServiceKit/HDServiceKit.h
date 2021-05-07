//
//  HDServiceKit.h
//  HDServiceKit
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2020 VanJay. All rights reserved.
//  This file is generated automatically.

#ifndef HDServiceKit_h
#define HDServiceKit_h

#import <UIKit/UIKit.h>

/// 版本号
static NSString *const HDServiceKit_VERSION = @"1.3.9";

#if __has_include("HDWHViewControllerPreRender.h")
#import "HDWHViewControllerPreRender.h"
#endif

#if __has_include("HDWHSimpleWebViewController.h")
#import "HDWHSimpleWebViewController.h"
#endif

#if __has_include("HDWHWebViewPreLoader.h")
#import "HDWHWebViewPreLoader.h"
#endif

#if __has_include("HDWebViewHostProtocol.h")
#import "HDWebViewHostProtocol.h"
#endif

#if __has_include("HDWebViewHostViewController+Extend.h")
#import "HDWebViewHostViewController+Extend.h"
#endif

#if __has_include("HDWebViewHostViewController+Callback.h")
#import "HDWebViewHostViewController+Callback.h"
#endif

#if __has_include("HDWHSchemeTaskDelegate.h")
#import "HDWHSchemeTaskDelegate.h"
#endif

#if __has_include("HDWebViewHostResponse.h")
#import "HDWebViewHostResponse.h"
#endif

#if __has_include("HDWebViewHostResponseCode.h")
#import "HDWebViewHostResponseCode.h"
#endif

#if __has_include("HDWebViewHostViewController+Dispatch.h")
#import "HDWebViewHostViewController+Dispatch.h"
#endif

#if __has_include("HDWHJSCoreManager.h")
#import "HDWHJSCoreManager.h"
#endif

#if __has_include("HDWebViewHostViewController+Timing.h")
#import "HDWebViewHostViewController+Timing.h"
#endif

#if __has_include("HDWebViewHostViewController+Utils.h")
#import "HDWebViewHostViewController+Utils.h"
#endif

#if __has_include("HDWebViewHostEnum.h")
#import "HDWebViewHostEnum.h"
#endif

#if __has_include("HDWebViewHostViewController+Scripts.h")
#import "HDWebViewHostViewController+Scripts.h"
#endif

#if __has_include("HDWebViewHostViewController+Progressor.h")
#import "HDWebViewHostViewController+Progressor.h"
#endif

#if __has_include("HDWebViewHost.h")
#import "HDWebViewHost.h"
#endif

#if __has_include("HDWebViewHostViewController.h")
#import "HDWebViewHostViewController.h"
#endif

#if __has_include("HTMLNode.h")
#import "HTMLNode.h"
#endif

#if __has_include("HTMLParser.h")
#import "HTMLParser.h"
#endif

#if __has_include("HDWHAppLoggerResponse.h")
#import "HDWHAppLoggerResponse.h"
#endif

#if __has_include("HDWHNavigationResponse.h")
#import "HDWHNavigationResponse.h"
#endif

#if __has_include("HDWHHudActionResponse.h")
#import "HDWHHudActionResponse.h"
#endif

#if __has_include("HDWHDebugResponse.h")
#import "HDWHDebugResponse.h"
#endif

#if __has_include("HDWHWebViewConfigResponse.h")
#import "HDWHWebViewConfigResponse.h"
#endif

#if __has_include("HDWHNavigationBarResponse.h")
#import "HDWHNavigationBarResponse.h"
#endif

#if __has_include("HDWHCapacityResponse.h")
#import "HDWHCapacityResponse.h"
#endif

#if __has_include("HDWHSystemCapabilityResponse.h")
#import "HDWHSystemCapabilityResponse.h"
#endif

#if __has_include("HDWHResponseManager.h")
#import "HDWHResponseManager.h"
#endif

#if __has_include("NSObject+HDWebViewHost.h")
#import "NSObject+HDWebViewHost.h"
#endif

#if __has_include("NSBundle+HDWebViewHost.h")
#import "NSBundle+HDWebViewHost.h"
#endif

#if __has_include("HDWHRequestMediate.h")
#import "HDWHRequestMediate.h"
#endif

#if __has_include("HDWHUtil.h")
#import "HDWHUtil.h"
#endif

#if __has_include("HDWebViewHostCookie.h")
#import "HDWebViewHostCookie.h"
#endif

#if __has_include("HDWHWebViewScrollPositionManager.h")
#import "HDWHWebViewScrollPositionManager.h"
#endif

#if __has_include("HDWHScriptMessageDelegate.h")
#import "HDWHScriptMessageDelegate.h"
#endif

#if __has_include("HDWHAppWhiteListParser.h")
#import "HDWHAppWhiteListParser.h"
#endif

#if __has_include("HDWHURLChecker.h")
#import "HDWHURLChecker.h"
#endif

#if __has_include("HDWebViewHostAuxiliaryEntryWindow.h")
#import "HDWebViewHostAuxiliaryEntryWindow.h"
#endif

#if __has_include("HDWHDebugServerManager.h")
#import "HDWHDebugServerManager.h"
#endif

#if __has_include("HDWebViewHostAuxiliaryMainWindow.h")
#import "HDWebViewHostAuxiliaryMainWindow.h"
#endif

#if __has_include("HDWHDebugViewController.h")
#import "HDWHDebugViewController.h"
#endif

#if __has_include("HDImageCompressTool.h")
#import "HDImageCompressTool.h"
#endif

#if __has_include("RSACipher.h")
#import "RSACipher.h"
#endif

#if __has_include("HDPodAsset.h")
#import "HDPodAsset.h"
#endif

#if __has_include("HDSystemCapabilityUtil.h")
#import "HDSystemCapabilityUtil.h"
#endif

#if __has_include("HDFileUtil.h")
#import "HDFileUtil.h"
#endif

#if __has_include("HDLocationUtils.h")
#import "HDLocationUtils.h"
#endif

#if __has_include("HDLocationAreaManager.h")
#import "HDLocationAreaManager.h"
#endif

#if __has_include("HDLocationConverter.h")
#import "HDLocationConverter.h"
#endif

#if __has_include("HDLocationManager.h")
#import "HDLocationManager.h"
#endif

#if __has_include("HDCache.h")
#import "HDCache.h"
#endif

#if __has_include("HDCacheStorage.h")
#import "HDCacheStorage.h"
#endif

#if __has_include("HDCacheUtility.h")
#import "HDCacheUtility.h"
#endif

#if __has_include("HDCacheStorageObject.h")
#import "HDCacheStorageObject.h"
#endif

#if __has_include("HDCacheManager.h")
#import "HDCacheManager.h"
#endif

#if __has_include("NSData+HDCache.h")
#import "NSData+HDCache.h"
#endif

#if __has_include("NSJSONSerialization+HDCache.h")
#import "NSJSONSerialization+HDCache.h"
#endif

#if __has_include("NSString+HDCache.h")
#import "NSString+HDCache.h"
#endif

#if __has_include("HDNetworkRequest.h")
#import "HDNetworkRequest.h"
#endif

#if __has_include("HDNetwork.h")
#import "HDNetwork.h"
#endif

#if __has_include("HDNetworkDefine.h")
#import "HDNetworkDefine.h"
#endif

#if __has_include("HDNetworkResponse.h")
#import "HDNetworkResponse.h"
#endif

#if __has_include("HDNetworkCache.h")
#import "HDNetworkCache.h"
#endif

#if __has_include("HDNetworkCache+Internal.h")
#import "HDNetworkCache+Internal.h"
#endif

#if __has_include("HDNetworkRetryConfig.h")
#import "HDNetworkRetryConfig.h"
#endif

#if __has_include("HDNetworkRequest+Internal.h")
#import "HDNetworkRequest+Internal.h"
#endif

#if __has_include("HDNetworkManager.h")
#import "HDNetworkManager.h"
#endif

#if __has_include("HDReachability.h")
#import "HDReachability.h"
#endif

#if __has_include("HDDeviceInfo.h")
#import "HDDeviceInfo.h"
#endif

#if __has_include("HDScanCodeViewController.h")
#import "HDScanCodeViewController.h"
#endif

#if __has_include("HDScanCodeView.h")
#import "HDScanCodeView.h"
#endif

#if __has_include("NSBundle+HDScanCode.h")
#import "NSBundle+HDScanCode.h"
#endif

#if __has_include("HDScanCodeDefines.h")
#import "HDScanCodeDefines.h"
#endif

#if __has_include("HDScanCodeManager.h")
#import "HDScanCodeManager.h"
#endif

#if __has_include("NSObjectSafe.h")
#import "NSObjectSafe.h"
#endif

#if __has_include("SANetwork.h")
#import "SANetwork.h"
#endif

#if __has_include("SANetworkRequest.h")
#import "SANetworkRequest.h"
#endif

#endif /* HDServiceKit_h */