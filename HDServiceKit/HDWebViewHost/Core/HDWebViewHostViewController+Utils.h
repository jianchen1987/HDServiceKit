//
//  HDWebviewHostViewController+Utils.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewHostViewController (Utils)

- (NSDictionary *)supportListByNow;

- (void)showTextTip:(NSString *)text;

- (void)showTextTip:(NSString *)text hideAfterDelay:(CGFloat)delay;

- (void)dealWithViewHistory;

- (void)popOutImmediately;

- (BOOL)isExternalSchemeRequest:(NSString *)url;

- (BOOL)isItmsAppsRequest:(NSString *)url;

- (void)logRequestAndResponse:(NSString *)str type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
