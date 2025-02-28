//
//  HDRspModel.h
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *SAResponseType NS_STRING_ENUM;
/// 成功
FOUNDATION_EXPORT SAResponseType const SAResponseTypeSuccess;

@interface HDRspModel : NSObject
/// 码
@property (nonatomic, copy, nullable) SAResponseType code;
/// 信息
@property (nonatomic, copy, nullable) NSString *msg;
/// 版本
@property (nonatomic, copy, nullable) NSString *version;
/// 信息
@property (nonatomic, assign) NSTimeInterval timeStamp;
/// 数据
@property (nonatomic, copy, nullable) id<NSCopying> data;

+ (instancetype)modelWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
