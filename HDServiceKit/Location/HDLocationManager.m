//
//  HDLocationManager.m
//  HDServiceKit
//
//  Created by VanJay on 2019/10/12.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLocationManager.h"

NSString *const kNotificationNameLocationPermissionChanged = @"kNotificationNameLocationPermissionChanged";
NSString *const kNotificationNameLocationChanged = @"kNotificationNameLocationChanged";
NSString *const kLocationChangedUserInfoKey = @"kLocationChangedUserInfoKey";
NSString *const kLocationPermissionChangedUserInfoKey = @"kLocationPermissionChangedUserInfoKey";

@interface HDLocationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;  ///< 位置管理者
@property (nonatomic, assign) BOOL mustCallDelegateFlag;           ///< 是否必须通知代理位置更新
@end

@implementation HDLocationManager
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static HDLocationManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];

        [instance invalidateCoordinate2D];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

#pragma mark - private methods
- (void)invalidateCoordinate2D {
    self.coordinate2D = CLLocationCoordinate2DMake(-91, -181);
}

#pragma mark - public methods
- (void)start {
    // 初始化
    [self initLocationManager];
}

- (BOOL)isCurrentCoordinate2DValid {
    return [self isCoordinate2DValid:self.coordinate2D];
}

- (BOOL)isCoordinate2DValid:(CLLocationCoordinate2D)coordinate2D {
    BOOL isLatitudeValid = coordinate2D.latitude >= -90 && coordinate2D.latitude <= 90;
    BOOL isLongitudeValid = coordinate2D.longitude >= -180 && coordinate2D.longitude <= 180;
    return isLatitudeValid && isLongitudeValid;
}

- (void)startUpdatingLocation {
    if (!_locationManager) {
        [self start];
    }
    if ([HDLocationUtils getCLAuthorizationStatus] == HDCLAuthorizationStatusAuthed) {
        [self.locationManager startUpdatingLocation];
    }
    self.mustCallDelegateFlag = true;
}

- (void)requestWhenInUseAuthorization {
    if (!_locationManager) {
        [self start];
    }
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"HDLocationManager - 位置请求权限变更");

    if ([HDLocationUtils getCLAuthorizationStatus] == HDCLAuthorizationStatusAuthed) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self invalidateCoordinate2D];
        [self.locationManager stopUpdatingLocation];
    }
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLocationPermissionChanged object:nil userInfo:@{kLocationPermissionChangedUserInfoKey: @(status)}];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"HDLocationManager - 位置变化");

    if (!self.isCurrentCoordinate2DValid) {
        self.coordinate2D = locations.lastObject.coordinate;
        // 发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLocationChanged object:nil userInfo:@{kLocationChangedUserInfoKey: locations}];
    } else {
        if (self.mustCallDelegateFlag) {
            self.coordinate2D = locations.lastObject.coordinate;
            // 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLocationChanged object:nil userInfo:@{kLocationChangedUserInfoKey: locations}];
            self.mustCallDelegateFlag = false;
        } else {
            // 计算距离
            CLLocation *l1 = [[CLLocation alloc] initWithLatitude:self.coordinate2D.latitude longitude:self.coordinate2D.longitude];
            CLLocation *l2 = [[CLLocation alloc] initWithLatitude:locations.lastObject.coordinate.latitude longitude:locations.lastObject.coordinate.longitude];
            CLLocationDistance distance = [HDLocationUtils distanceFromLocation:l1 toLocation:l2];

            if (distance > 50) {
                NSLog(@"距离变化超过 %f 米，发出通知", distance);
                self.coordinate2D = locations.lastObject.coordinate;

                // 发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLocationChanged object:nil userInfo:@{kLocationChangedUserInfoKey: locations}];
            }
        }
    }
}

#pragma mark - lazy load
- (void)initLocationManager {
    if (!_locationManager) {
        _locationManager = CLLocationManager.alloc.init;
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 有权限直接开始定位
        if ([HDLocationUtils getCLAuthorizationStatus] == HDCLAuthorizationStatusAuthed) {
            [self.locationManager startUpdatingLocation];
        }
        _locationManager.distanceFilter = 20.0;
    }
}
@end
