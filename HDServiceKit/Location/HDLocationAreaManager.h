//
//  HDLocationAreaManager.h
//  HDServiceKit
//
//  Created by Chaos on 2020/12/3.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDLocationAreaManager : NSObject

+ (instancetype)shared;

+ (void)startWithFilePath:(NSString *)filePath;

- (void)isOutOfAreaWithGcj02Point:(CLLocationCoordinate2D)gcj02Point result:(void(^)(BOOL))result;

@end

NS_ASSUME_NONNULL_END
