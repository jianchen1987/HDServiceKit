//
//  HDLocationUtils.h
//  HDServiceKit
//
//  Created by VanJay on 2019/4/22.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

/** 定位授权状态 */
typedef NS_ENUM(NSInteger, HDCLAuthorizationStatus) {
    HDCLAuthorizationStatusNotDetermined = 0,  ///< 未请求过
    HDCLAuthorizationStatusAuthed,             ///< 同意了
    HDCLAuthorizationStatusNotAuthed           ///< 不同意
};

NS_ASSUME_NONNULL_BEGIN

@interface HDLocationUtils : NSObject

/**
 计算两个位置之间的距离

 @param fromLocation 起始位置
 @param toLocation 结束位置
 @return 距离
 */
+ (CLLocationDistance)distanceFromLocation:(CLLocation *)fromLocation toLocation:(CLLocation *)toLocation;

/**
 获取定位授权状态
 */
+ (HDCLAuthorizationStatus)getCLAuthorizationStatus;

/// 计算当前地图的缩放级别 2(最大)~20(最小)
/// @param width 地图宽度
/// @param longitudeDelta 经度范围
+ (double)calcMapZoomLevelWithMapWidth:(CGFloat)width longitudeDelta:(CLLocationDegrees)longitudeDelta;

/// 判断坐标是否合法
/// @param coordinate2D 坐标
+ (BOOL)isCoordinate2DValid:(CLLocationCoordinate2D)coordinate2D;
@end

NS_ASSUME_NONNULL_END
