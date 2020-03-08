//
//  HDWebviewHostViewController+Timing.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController+Timing.h"
#import <objc/runtime.h>

NSString *kWebViewHostTimingLoadRequest = @"loadRequest";
NSString *kWebViewHostTimingWebViewInit = @"webViewInit";
NSString *kWebViewHostTimingDidFinishNavigation = @"didFinishNavigation";
NSString *kWebViewHostTimingDecidePolicyForNavigationAction = @"decidePolicyForNavigationAction";
NSString *kWebViewHostTimingAddUserScript = @"addUserScript";

@implementation HDWebViewHostViewController (Timing)

#ifdef HDWH_DEBUG

- (void)mark:(NSString *)markName {
    NSMutableDictionary *marks = self.marks;
    if (marks == nil) {
        marks = [NSMutableDictionary dictionaryWithCapacity:10];
        self.marks = marks;
    }

    [marks setObject:@(NOW_TIME) forKey:markName];
}

- (void)measure:(NSString *)endMarkName to:(NSString *)startMark {
    long long time = [[self.marks objectForKey:startMark] longLongValue];
    HDWHLog(@"[Timing] %@ ~ %@ 耗时共 %f", endMarkName, startMark, NOW_TIME - time);
}
#else

- (void)mark:(NSString *)markName{};
- (void)measure:(NSString *)endMarkName to:(NSString *)startMark{};

#endif

#pragma mark - getter

- (void)setMarks:(NSMutableDictionary *)marks {
    objc_setAssociatedObject(self, @selector(setMarks:), marks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)marks {
    return objc_getAssociatedObject(self, @selector(setMarks:));
}

@end
