//
//  HDRspModel.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDRspModel.h"

SAResponseType const SAResponseTypeSuccess = @"00000";

@implementation HDRspModel
+ (instancetype)modelWithDict:(NSDictionary *)dict {
    HDRspModel *model = [HDRspModel new];
    model.code = [dict objectForKey:@"code"];
    model.data = [dict objectForKey:@"data"];
    model.msg = [dict objectForKey:@"msg"];
    model.version = [dict objectForKey:@"version"];
    model.timeStamp = [[NSDate date] timeIntervalSince1970];
    return model;
}
@end
