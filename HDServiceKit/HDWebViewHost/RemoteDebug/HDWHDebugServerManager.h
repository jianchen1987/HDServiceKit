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

- (void)start;

- (void)startWithPort:(NSUInteger)port bonjourName:(NSString *)name;

- (void)stop;

- (void)showDebugWindow;
@end

NS_ASSUME_NONNULL_END
