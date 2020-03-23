//
//  Target_NoTargetAction.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/22.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "Target_NoTargetAction.h"
#import <HDKitCore/HDLog.h>

@implementation Target_NoTargetAction
- (void)action_response:(NSDictionary *)params {
    HDLog(@"无 target 或者 无 action 响应，%@", params);
}
@end
