//
//  HDLocationUtils.m
//  HDServiceKit
//
//  Created by VanJay on 2019/4/22.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDLocationUtils.h"

@implementation HDLocationUtils
+ (CLLocationDistance)distanceFromLocation:(CLLocation *)fromLocation toLocation:(CLLocation *)toLocation {
    return [toLocation distanceFromLocation:fromLocation];
}

+ (HDCLAuthorizationStatus)getCLAuthorizationStatus {
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse || CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways) {
        return HDCLAuthorizationStatusAuthed;
    } else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied || CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted) {
        return HDCLAuthorizationStatusNotAuthed;
    }
    return HDCLAuthorizationStatusNotDetermined;
}

+ (double)calcMapZoomLevelWithMapWidth:(CGFloat)width longitudeDelta:(CLLocationDegrees)longitudeDelta {
    double zoomLevel = log2(360 * width / (256.0 * longitudeDelta));
    return zoomLevel;
}

+ (BOOL)isCoordinate2DValid:(CLLocationCoordinate2D)coordinate2D {
    BOOL isLatitudeValid = coordinate2D.latitude >= -90 && coordinate2D.latitude <= 90;
    BOOL isLongitudeValid = coordinate2D.longitude >= -180 && coordinate2D.longitude <= 180;
    return isLatitudeValid && isLongitudeValid;
}

@end
