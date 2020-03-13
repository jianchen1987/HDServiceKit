//
//  HDWebViewHostViewController+Callback.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/13.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController+Callback.h"
#import "HDWebViewHostViewController+Scripts.h"

@implementation HDWebViewHostViewController (Callback)
- (void)fireCallback:(NSString *)callbackKey actionName:(NSString *)actionName code:(NSString *)code type:(HDWHCallbackType)type params:(NSDictionary *)params {
    NSString *status;
    switch (type) {
        case HDWHCallbackTypeSuccess:
            status = @"ok";
            break;

        case HDWHCallbackTypeCancel:
            status = @"cancel";
            break;

        default:
            break;
    }
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithCapacity:3];
    finalParams[@"code"] = code;
    if (status.length > 0) {
        finalParams[@"msg"] = [NSString stringWithFormat:@"%@::%@", actionName, status];
    } else {
        finalParams[@"msg"] = actionName;
    }
    if (params && [params isKindOfClass:NSDictionary.class] && params.allKeys.count > 0) {
        finalParams[@"data"] = params;
    }
    [self fireCallback:callbackKey param:finalParams];
}
@end
