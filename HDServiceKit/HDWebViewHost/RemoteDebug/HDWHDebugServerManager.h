//
//  HDWHDebugServerManager.h
//  HDWebViewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface HDWHDebugServerManager : NSObject

+ (instancetype)sharedInstance;

/// 启动 web server，默认端口 8081，默认 bonjourName：chaos-mac.local
- (void)start;

/// 停止 web server
- (void)stop;

/// 启动 web server
/// @param port 端口
/// @param name bonjourName：chaos
- (void)startWithPort:(NSUInteger)port bonjourName:(NSString *)name;

/// 展示入口
- (void)showDebugWindow;
@end

NS_ASSUME_NONNULL_END
