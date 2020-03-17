//
//  HDWHDebugResponse.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostResponse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *kWebViewHostTestCaseFileName = @"testcase.html";
@interface HDWHDebugResponse : HDWebViewHostResponse

+ (void)setupDebugger;


/// 检测命令是否是 debug 命令
/// @param action 命令名
+ (BOOL)isDebugAction:(NSString *)action;

@end

NS_ASSUME_NONNULL_END
