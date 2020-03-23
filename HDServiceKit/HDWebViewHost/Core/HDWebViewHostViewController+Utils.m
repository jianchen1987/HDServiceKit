//
//  HDServiceKitViewController+Utils.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHResponseManager.h"
#import "HDWHWebViewScrollPositionManager.h"
#import "HDWebViewHostViewController+Dispatch.h"
#import "HDWebViewHostViewController+Utils.h"

NSString *const kHDWHSupportMethodListKey = @"supportMethodList";
NSString *const kHDWHAppInfoKey = @"appInfo";

@implementation HDWebViewHostViewController (Utils)

#pragma mark - supportType
- (NSDictionary *)supportMethodListAndAppInfo {
    // 人肉维护支持列表；
    NSMutableDictionary *supportedFunctions = [@{
        // 增加 webviewhost 的supportTypeFunction
        @"pageshow": kHDWHResponseMethodOn,
        @"pagehide": kHDWHResponseMethodOn
    } mutableCopy];
    // 内置接口
    // 各个response 的 supportFunction
    [[HDWHResponseManager defaultManager].customResponseClasses enumerateObjectsUsingBlock:^(Class resp, NSUInteger idx, BOOL *_Nonnull stop) {
        [supportedFunctions addEntriesFromDictionary:[resp supportActionList]];
    }];

    NSMutableDictionary *lst = [NSMutableDictionary dictionaryWithCapacity:10];
    [lst setObject:supportedFunctions forKey:kHDWHSupportMethodListKey];

    NSMutableDictionary *appInfo = [NSMutableDictionary dictionaryWithCapacity:5];
    if (HDWH_IS_SCREEN_HEIGHT_X) {
        [appInfo setObject:@"1" forKey:@"isIPhoneXSeries"];
    }

    [lst setObject:appInfo forKey:kHDWHAppInfoKey];
    return lst;
}

#pragma mark - shim

- (void)showTextTip:(NSString *)text {
    [self showTextTip:text hideAfterDelay:2.f];
}

- (void)showTextTip:(NSString *)text hideAfterDelay:(CGFloat)delay {
    [self callNative:@"toast"
           parameter:@{
               @"text": text ?: @"",
               @"hideAfterDelay": @(delay > 0 ?: 2.f)
           }];
}

#pragma mark - view history
- (void)dealWithViewHistory {
    if (self.disableScrollPositionMemory) {
        return;
    }

    NSURL *url = self.webView.URL;
    UIScrollView *sv = self.webView.scrollView;
    CGFloat oldY = [[HDWHWebViewScrollPositionManager sharedInstance] positionForCacheURL:url];
    if (oldY != sv.contentOffset.y) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sv.contentOffset = CGPointMake(0, oldY);
        });
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.disableScrollPositionMemory) {
        return;
    }
    CGFloat y = scrollView.contentOffset.y;
    // HDWHLog(@"contentOffset.y = %.2f", y);
    [[HDWHWebViewScrollPositionManager sharedInstance] cacheURL:self.webView.URL position:y];
}

#pragma mark - utils

- (void)popOutImmediately {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (BOOL)isExternalSchemeRequest:(NSString *)url {
    NSArray<NSString *> *prefixs = @[@"http://", @"https://"];
    BOOL __block external = YES;

    [prefixs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([url hasPrefix:obj]) {
            external = NO;
            *stop = YES;
        }
    }];

    return external;
}

static NSString *const kWHRequestItmsApp = @"itms-apps://";
- (BOOL)isItmsAppsRequest:(NSString *)url {
    // https://itunes.apple.com/cn/app/id1440238257
    NSArray<NSString *> *prefixs = @[kWHRequestItmsApp, @"https://itunes.apple.com", @"itms-appss://", @"itms-services://", @"itmss://"];
    BOOL __block pass = NO;

    [prefixs enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([url hasPrefix:obj]) {
            pass = YES;
            *stop = YES;
        }
    }];

    return pass;
}

@end
