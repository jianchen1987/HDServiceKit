//
//  HDWHSchemeTaskResponse.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDWebViewHostEnum.h"

#import <WebKit/WebKit.h>

typedef NSData*_Nonnull(^HDWHURLSchemeTaskHandler)(WKWebView *_Nonnull, id<WKURLSchemeTask> _Nonnull, NSString *_Nullable * _Nullable mime);

NS_ASSUME_NONNULL_BEGIN

@interface HDWHSchemeTaskDelegate : NSObject <WKURLSchemeHandler>

/**
 添加自定义的处理逻辑
 */
- (void)addHandler:(HDWHURLSchemeTaskHandler)handler forDomain:(NSString */* js */)domain;

@end

NS_ASSUME_NONNULL_END
