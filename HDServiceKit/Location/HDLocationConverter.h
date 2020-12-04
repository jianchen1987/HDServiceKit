//
//  HDLocationConverter.h
//  HDServiceKit
//
//  Created by Chaos on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDLocationConverter : NSObject

+ (instancetype)shared;

+ (void)start;
+ (void)startWithFilePath:(NSString *)filePath;

/**
 *    @brief    世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *  ####只在中国大陆的范围的坐标有效，以外直接返回世界标准坐标
 *
 *    @param     location     世界标准地理坐标(WGS-84)
 *
 *    @result    中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (void)wgs84ToGcj02:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result;


/**
 *    @brief    中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *    @param     location     中国国测局地理坐标（GCJ-02）
 *
 *    @result    世界标准地理坐标（WGS-84）
 */
+ (void)gcj02ToWgs84:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result;


/**
 *    @brief    世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 *
 *    @param     location     世界标准地理坐标(WGS-84)
 *
 *    @result    百度地理坐标（BD-09)
 */
+ (void)wgs84ToBd09:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result;


/**
 *    @brief    中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 *
 *    @param     location     中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *    @result    百度地理坐标（BD-09)
 */
+ (void)gcj02ToBd09:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result;


/**
 *    @brief    百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 *
 *    @param     location     百度地理坐标（BD-09)
 *
 *    @result    中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (void)bd09ToGcj02:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result;


/**
 *    @brief    百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 *
 *  ####此接口有1－2米左右的误差，需要精确定位情景慎用
 *
 *    @param     location     百度地理坐标（BD-09)
 *
 *    @result    世界标准地理坐标（WGS-84）
 */
+ (void)bd09ToWgs84:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result;


@end

NS_ASSUME_NONNULL_END
