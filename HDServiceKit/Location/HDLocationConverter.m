//
//  HDLocationConverter.m
//  HDServiceKit
//
//  Created by Chaos on 2020/12/3.
//

#import "HDLocationConverter.h"
#import "HDLocationAreaManager.h"

@interface HDLocationConverter ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation HDLocationConverter

+ (instancetype)shared {
    static HDLocationConverter *locationConverter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationConverter = [[super allocWithZone:NULL] init];
    });
    return locationConverter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

#pragma mark - public methods
+ (void)start {
    NSString *bundlePath = [[NSBundle bundleForClass:self] pathForResource:@"HDLocation" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *filePath = [bundle pathForResource:@"GCJ02" ofType:@"json"];
    [self startWithFilePath:filePath];
}

+ (void)startWithFilePath:(NSString *)filePath {
    [HDLocationAreaManager startWithFilePath:filePath];
}

+ (void)wgs84ToGcj02:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    [self gcj02Encrypt:location result:result];
}

+ (void)gcj02ToWgs84:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    [self gcj02Decrypt:location result:result];
}

+ (void)wgs84ToBd09:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    [self gcj02Decrypt:location result:^(CLLocationCoordinate2D gcj02Point) {
        [self bd09Encrypt:gcj02Point result:result];
    }];
}

+ (void)gcj02ToBd09:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    [self bd09Encrypt:location result:result];
}

+ (void)bd09ToGcj02:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    [self bd09Decrypt:location result:result];
}

+ (void)bd09ToWgs84:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    [self bd09Decrypt:location result:^(CLLocationCoordinate2D gcj02Point) {
        [self gcj02Decrypt:gcj02Point result:result];
    }];
}


#pragma mark - private methods
+ (CLLocationCoordinate2D)gcj02OffsetWithCoordinate:(CLLocationCoordinate2D)coordinate {
    static double A = 6378245.0;
    static double EE = 0.00669342162296594323;
    
    double x = coordinate.longitude - 105.0;
    double y = coordinate.latitude - 35.0;
    double latitude = (-100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))) +
                        ((20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0) +
                        ((20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0) +
                        ((160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0);
    double longitude = (300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))) +
                        ((20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0) +
                        ((20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0) +
                        ((150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0);
    double radLat = coordinate.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - EE * magic * magic;
    double sqrtMagic = sqrt(magic);
    double dLat = (latitude * 180.0) / ((A * (1 - EE)) / (magic * sqrtMagic) * M_PI);
    double dLon = (longitude * 180.0) / (A / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(dLat, dLon);
}

//GCJ02
+ (void)gcj02Encrypt:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    HDLocationConverter *coverter = [HDLocationConverter shared];
    dispatch_async(coverter.queue, ^{
        CLLocationCoordinate2D offsetPoint = [self gcj02OffsetWithCoordinate:location];
        CLLocationCoordinate2D resultPoint = CLLocationCoordinate2DMake(location.latitude + offsetPoint.latitude, location.longitude + offsetPoint.longitude);
        [[HDLocationAreaManager shared] isOutOfAreaWithGcj02Point:resultPoint result:^(BOOL isOut) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isOut) {
                    result(location);
                } else {
                    result(resultPoint);
                }
            });
        }];
    });
}

+ (void)gcj02Decrypt:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    HDLocationConverter *coverter = [HDLocationConverter shared];
    [[HDLocationAreaManager shared] isOutOfAreaWithGcj02Point:location result:^(BOOL isOut) {
        if (isOut) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(location);
            });
        } else {
            [self gcj02Encrypt:location result:^(CLLocationCoordinate2D mgPoint) {
                dispatch_async(coverter.queue, ^{
                    CLLocationCoordinate2D resultPoint = CLLocationCoordinate2DMake(location.latitude * 2 - mgPoint.latitude, location.longitude * 2 - mgPoint.longitude);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        result(resultPoint);
                    });
                });
            }];
        }
    }];
}

//BD09
+ (void)bd09Encrypt:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    HDLocationConverter *coverter = [HDLocationConverter shared];
    dispatch_async(coverter.queue, ^{
        double x = location.longitude;
        double y = location.latitude;
        double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
        double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
        CLLocationCoordinate2D resultPoint = CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
        dispatch_async(dispatch_get_main_queue(), ^{
            result(resultPoint);
        });
    });
}

+ (void)bd09Decrypt:(CLLocationCoordinate2D)location result:(void(^)(CLLocationCoordinate2D))result {
    HDLocationConverter *coverter = [HDLocationConverter shared];
    dispatch_async(coverter.queue, ^{
        double x = location.longitude - 0.0065;
        double y = location.latitude - 0.006;
        double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
        double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
        CLLocationCoordinate2D resultPoint = CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta));
        dispatch_async(dispatch_get_main_queue(), ^{
            result(resultPoint);
        });
    });
}

#pragma mark - lazy load
- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.hdnetwork.locationcoverter", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}

@end
