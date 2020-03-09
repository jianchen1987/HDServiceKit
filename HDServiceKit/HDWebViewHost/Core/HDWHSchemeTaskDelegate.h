//
//  HDWHSchemeTaskResponse.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostEnum.h"
#import <Foundation/Foundation.h>

#import <WebKit/WebKit.h>

API_AVAILABLE(ios(11.0))
typedef NSData *_Nonnull (^HDWHURLSchemeTaskHandler)(WKWebView *_Nonnull, id<WKURLSchemeTask> _Nonnull, NSString *_Nullable *_Nullable mime);

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(11.0))
@interface HDWHSchemeTaskDelegate : NSObject <WKURLSchemeHandler>

/**
 添加自定义的处理逻辑
 */
- (void)addHandler:(HDWHURLSchemeTaskHandler)handler forDomain:(NSString * /* js */)domain;

@end

NS_ASSUME_NONNULL_END
