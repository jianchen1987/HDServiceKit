//
//  HDWebviewHostViewController+Progressor.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController+Progressor.h"
#import <objc/runtime.h>

@implementation HDWebViewHostViewController (Progressor)

- (void)startProgressor {
    [self stopProgressor];
    if (self.progressorView == nil) {
        [self addWebviewProgressor];
    }
}

- (void)addWebviewProgressor {
    // 仿微信进度条
    self.progressorView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, HDWH_NAVIGATION_BAR_HEIGHT, HDWH_SCREEN_WIDTH, 20.0f)];

    self.progressorView.progressTintColor = kWebViewProgressTintColorRGB > 0 ? HDWHColorFromRGB(kWebViewProgressTintColorRGB) : [UIColor grayColor];
    self.progressorView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressorView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        double progress = [change[@"new"] doubleValue];
        HDWHLog(@"[Timing] progress = %f, %f", progress, [[NSDate date] timeIntervalSince1970] * 1000);
        if (progress >= 1) {
            // 0.25s 后消失
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.clearProgressorTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(stopProgressor) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:self.clearProgressorTimer forMode:NSRunLoopCommonModes];
            }];
            [self.progressorView setProgress:1 animated:YES];
            [CATransaction commit];
        } else {
            [self.progressorView setProgress:progress animated:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)stopProgressor {
    [self.progressorView setProgress:0];
    [self.clearProgressorTimer invalidate];
}

- (void)setupProgressor {
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)teardownProgressor {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - setter, setter

- (NSTimer *)clearProgressorTimer {
    return objc_getAssociatedObject(self, @selector(clearProgressorTimer));
}

- (void)setClearProgressorTimer:(NSTimer *)clearProgressorTimer {
    objc_setAssociatedObject(self, @selector(clearProgressorTimer), clearProgressorTimer, OBJC_ASSOCIATION_RETAIN);
}

- (UIProgressView *)progressorView {
    return objc_getAssociatedObject(self, @selector(progressorView));
}

- (void)setProgressorView:(UIProgressView *)progressorView {
    objc_setAssociatedObject(self, @selector(progressorView), progressorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
