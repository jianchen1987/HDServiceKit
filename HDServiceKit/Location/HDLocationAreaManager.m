//
//  HDLocationAreaManager.m
//  HDServiceKit
//
//  Created by Chaos on 2020/12/3.
//

#import "HDLocationAreaManager.h"

@interface HDLocationAreaManager ()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSArray<NSArray<NSNumber *> *> *points;

@end

@implementation HDLocationAreaManager

+ (instancetype)shared {
    static HDLocationAreaManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:NULL] init];
    });
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

+ (void)startWithFilePath:(NSString *)filePath {
    if (!filePath) {
        NSLog(@"中国边境线数据文件路径为空");
        return;
    }
    HDLocationAreaManager *manager = [self shared];
    dispatch_async(manager.queue, ^{
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        if (!jsonData) {
            NSLog(@"获取中国边境线数据失败");
            return;
        }
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            NSLog(@"解析中国边境线数据失败");
            return;
        }
        if (array) {
            manager.points = array;
            NSLog(@"获取中国边境线数据成功");
            return;
        }
        NSLog(@"获取中国边境线数据为空");
    });
}

- (void)isOutOfAreaWithGcj02Point:(CLLocationCoordinate2D)gcj02Point result:(void(^)(BOOL))result {
    dispatch_async(self.queue, ^{
        if (!self.points) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result(false);
            });
            return;
        }
        
        BOOL flag = false;
        for (NSInteger idx = 0; idx < self.points.count; idx++) {
            NSInteger nextIdx = (idx + 1) == self.points.count ? 0 : idx + 1;
            NSArray *edgePoint = self.points[idx];
            NSArray *nextPoint = self.points[nextIdx];
            
            double pointX = [edgePoint[1] doubleValue];
            double pointY = [edgePoint[0] doubleValue];
            
            double nextPointX = [nextPoint[1] doubleValue];
            double nextPointY = [nextPoint[0] doubleValue];
            
            if ((gcj02Point.longitude == pointX && gcj02Point.latitude == pointY) ||
            (gcj02Point.longitude == nextPointX && gcj02Point.latitude == nextPointY)) {
                flag = true;
            }
            if ((nextPointY < gcj02Point.latitude && pointY >= gcj02Point.latitude) ||
               (nextPointY >= gcj02Point.latitude && pointY < gcj02Point.latitude)) {
                double thX = nextPointX + (gcj02Point.latitude - nextPointY) * (pointX - nextPointX) / (pointY - nextPointY);
                if (thX == gcj02Point.longitude) {
                    flag = true;
                    break;
                }
                if (thX > gcj02Point.longitude) {
                    flag = !flag;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            result(!flag);
        });
    });
}

#pragma mark - lazy load
- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.hdlocation.areamanager", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}

@end
