//
//  HDWebviewHostViewController+Timing.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHost.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *kWebViewHostTimingLoadRequest;
FOUNDATION_EXPORT NSString *kWebViewHostTimingWebViewInit;
FOUNDATION_EXPORT NSString *kWebViewHostTimingDidFinishNavigation;
FOUNDATION_EXPORT NSString *kWebViewHostTimingDecidePolicyForNavigationAction;
FOUNDATION_EXPORT NSString *kWebViewHostTimingAddUserScript;

@interface HDWebViewHostViewController (Timing)

/**
 保存所有 mark 的起点数据。
 */
@property (nonatomic, strong) NSMutableDictionary *marks;

/**
 记录起点

 @param markName 起点的别名，用来和后面 mearsue 配合使用
 */
- (void)mark:(NSString *)markName;

/**
 计算从此时到 markName 别打标记时的时间耗时

 */
- (void)measure:(NSString *)endMarkName to:(NSString *)startMark;

@end

NS_ASSUME_NONNULL_END
