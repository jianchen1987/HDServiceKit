//
//  NSBundle+HDWebViewHost.m
//  HDUIKit
//
//  Created by VanJay on 2020/3/4.
//  Copyright © 2019 chaos network technology. All rights reserved.

#import "NSBundle+HDWebViewHost.h"

@implementation NSBundle (HDWebViewHost)
+ (NSBundle *)hd_WebViewHostRemoteDebugResourcesBundle {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *resourcePath = [mainBundle pathForResource:@"Frameworks/HDServiceKit.framework/HDWebViewHostRemoteDebugResources" ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [mainBundle pathForResource:@"HDWebViewHostRemoteDebugResources" ofType:@"bundle"];
        }
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    return resourceBundle;
}
@end
