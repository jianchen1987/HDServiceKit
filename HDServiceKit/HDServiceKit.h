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
static NSString * const HDServiceKit_VERSION = @"0.3.9";

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

#if __has_include("HDWHSchemeTaskDelegate.h")
#import "HDWHSchemeTaskDelegate.h"
#endif

#if __has_include("HDWebViewHostResponse.h")
#import "HDWebViewHostResponse.h"
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

#if __has_include("HDWHDebugResponse.h")
#import "HDWHDebugResponse.h"
#endif

#if __has_include("HDWHNavigationBarResponse.h")
#import "HDWHNavigationBarResponse.h"
#endif

#if __has_include("HDWHBuiltInResponse.h")
#import "HDWHBuiltInResponse.h"
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

#if __has_include("GCDWebServerFunctions.h")
#import "GCDWebServerFunctions.h"
#endif

#if __has_include("GCDWebServerPrivate.h")
#import "GCDWebServerPrivate.h"
#endif

#if __has_include("GCDWebServerConnection.h")
#import "GCDWebServerConnection.h"
#endif

#if __has_include("GCDWebServer.h")
#import "GCDWebServer.h"
#endif

#if __has_include("GCDWebServerHTTPStatusCodes.h")
#import "GCDWebServerHTTPStatusCodes.h"
#endif

#if __has_include("GCDWebServerResponse.h")
#import "GCDWebServerResponse.h"
#endif

#if __has_include("GCDWebServerRequest.h")
#import "GCDWebServerRequest.h"
#endif

#if __has_include("GCDWebServerFileResponse.h")
#import "GCDWebServerFileResponse.h"
#endif

#if __has_include("GCDWebServerStreamedResponse.h")
#import "GCDWebServerStreamedResponse.h"
#endif

#if __has_include("GCDWebServerDataResponse.h")
#import "GCDWebServerDataResponse.h"
#endif

#if __has_include("GCDWebServerErrorResponse.h")
#import "GCDWebServerErrorResponse.h"
#endif

#if __has_include("GCDWebServerDataRequest.h")
#import "GCDWebServerDataRequest.h"
#endif

#if __has_include("GCDWebServerMultiPartFormRequest.h")
#import "GCDWebServerMultiPartFormRequest.h"
#endif

#if __has_include("GCDWebServerFileRequest.h")
#import "GCDWebServerFileRequest.h"
#endif

#if __has_include("GCDWebServerURLEncodedFormRequest.h")
#import "GCDWebServerURLEncodedFormRequest.h"
#endif

#if __has_include("HDPodAsset.h")
#import "HDPodAsset.h"
#endif

#if __has_include("HDFileUtil.h")
#import "HDFileUtil.h"
#endif

#if __has_include("HDLocationUtils.h")
#import "HDLocationUtils.h"
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

#if __has_include("HDReachability.h")
#import "HDReachability.h"
#endif

#if __has_include("NSObjectSafe.h")
#import "NSObjectSafe.h"
#endif

#endif /* HDServiceKit_h */