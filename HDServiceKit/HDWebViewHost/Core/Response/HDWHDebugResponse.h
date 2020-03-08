//
//  HDWHDebugResponse.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDWebViewHostResponse.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *kWebViewHostTestCaseFileName = @"testcase.html";
@interface HDWHDebugResponse : HDWebViewHostResponse

+ (void)setupDebugger;

@end

NS_ASSUME_NONNULL_END
