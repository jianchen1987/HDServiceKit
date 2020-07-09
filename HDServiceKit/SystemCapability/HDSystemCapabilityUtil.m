//
//  HDSystemCapabilityUtil.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/16.
//

#import "HDSystemCapabilityUtil.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static CGFloat _currentBrightness;
static NSOperationQueue *_queue;

@implementation HDSystemCapabilityUtil
+ (void)makePhoneCall:(NSString *)phoneNum {

    if (!phoneNum || phoneNum.length <= 0) {
        return;
    }

    // 号码去空格，否则生成 url 为 nil
    phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNum]];
    [[UIApplication sharedApplication] openURL:phoneURL];
}

+ (void)sendSms:(NSString *)phoneNum {

    if (!phoneNum || phoneNum.length <= 0) {
        return;
    }

    NSString *urlStr = [NSString stringWithFormat:@"sms://%@", phoneNum];

    NSURL *url = [NSURL URLWithString:urlStr];

    [[UIApplication sharedApplication] openURL:url];
}

+ (void)sendEmailWithRecipient:(NSString *)recipient ccRecipient:(NSString *)ccRecipient bccRecipient:(NSString *)bccRecipient subject:(NSString *)subject body:(NSString *)body {

    if (!recipient || recipient.length <= 0) {
        return;
    }

    NSMutableString *mailUrl = [[NSMutableString alloc] init];

    // 收件人
    [mailUrl appendFormat:@"mailto:%@", recipient];

    // 抄送人
    if (ccRecipient) {
        [mailUrl appendFormat:@"?cc=%@", ccRecipient];
    }

    // 添加密送人
    if (bccRecipient) {
        [mailUrl appendFormat:@"&bcc=%@", bccRecipient];
    }

    // 添加邮件主题
    if (subject) {
        [mailUrl appendFormat:@"&subject=%@", subject];
    }

    // 添加邮件内容
    if (body) {
        [mailUrl appendFormat:@"&body=%@", body];
    }

    NSString *emailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailPath]];
}

+ (void)gotoAppStoreScoreWithAppID:(NSString *)appID {
    appID = appID ?: @"1440238257";
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8&action=write-review", appID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

+ (void)gotoAppStoreForAppID:(NSString *)appID {
    appID = appID ?: @"1440238257";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID]];
    [[UIApplication sharedApplication] openURL:url];
}

+ (void)jumpToMapWithAddress:(NSString *)address successHandler:(void (^)(void))successHandler failHandler:(void (^)(NSString *errMsg))failHandler {
    if (address.length == 0) {
        failHandler(@"地址为空");
        return;
    }

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address
                 completionHandler:^(NSArray<CLPlacemark *> *_Nullable placemarks, NSError *_Nullable error) {
                     if (placemarks.count == 0 || error) {
                         failHandler(@"地址出错");
                     } else {
                         MKPlacemark *placeMark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
                         MKMapItem *location = [[MKMapItem alloc] initWithPlacemark:placeMark];
                         [location openInMapsWithLaunchOptions:nil];
                         if (successHandler) {
                             successHandler();
                         }
                     }
                 }];
}

+ (void)jumpToMapWithLongitude:(double)longitude latitude:(double)latitude locationName:(NSString *)locationName {

    CLLocationCoordinate2D station = CLLocationCoordinate2DMake(latitude, longitude);
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toStation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:station addressDictionary:nil]];
    toStation.name = locationName;
    [MKMapItem openMapsWithItems:@[currentLocation, toStation] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
}

+ (void)saveDefaultBrightness {
    _currentBrightness = [UIScreen mainScreen].brightness;
}

+ (void)graduallySetBrightness:(CGFloat)value {

    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    [_queue cancelAllOperations];

    CGFloat brightness = [UIScreen mainScreen].brightness;
    CGFloat step = 0.005 * ((value > brightness) ? 1 : -1);
    int times = fabs((value - brightness) / 0.005);
    for (CGFloat i = 1; i < times + 1; i++) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            // 此处在 iOS 13 会 crash，跳主线程解决
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSThread sleepForTimeInterval:1 / 180.0];
                [UIScreen mainScreen].brightness = brightness + i * step;
            });
        }];
        [_queue addOperation:operation];
    }
}

+ (void)graduallyResumeBrightness {
    [self graduallySetBrightness:_currentBrightness];
}

+ (void)openAppSystemSettingPage {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

    if ([application canOpenURL:url]) {
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            if (@available(iOS 10.0, *)) {
                [application openURL:url options:@{} completionHandler:nil];
            } else {
                [application openURL:url];
            }
        } else {
            [application openURL:url];
        }
    }
}

+ (void)socialShareTitle:(NSString *_Nullable)title imageUrl:(NSString *_Nullable)imageUrl content:(NSString *_Nullable)content inViewController:(UIViewController *)viewController result:(void (^)(NSError *error_Nullable))result {
    NSMutableArray *shareItems = [[NSMutableArray alloc] initWithCapacity:3];

    void (^shareAll)(NSArray *) = ^void(NSArray *items) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if (completed) {
                !result ?: result(nil);
            } else {
                !result ?: result(activityError);
            }
        };
        [viewController presentViewController:activityVC animated:YES completion:nil];
    };

    if (title && ![title isEqual:[NSNull null]] && title.length > 0) {
        [shareItems addObject:title];
    }

    if (content && ![content isEqual:[NSNull class]] && content.length > 0) {
        NSURL *urlToShare = [NSURL URLWithString:content];
        if (urlToShare) {
            [shareItems addObject:urlToShare];
        } else {
            [shareItems addObject:content];
        }
    }

    if (imageUrl && ![imageUrl isEqual:[NSNull class]] && imageUrl.length > 0) {
        [HDWebImageManager setImageWithURL:imageUrl
                          placeholderImage:nil
                                 imageView:[UIImageView new]
                                  progress:nil
                                 completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
                                     if (!error) {
                                         [shareItems addObject:image];
                                         shareAll(shareItems);
                                     } else {
                                         !result ?: result(error);
                                     }
                                 }];
    } else {
        shareAll(shareItems);
    }
}
@end
