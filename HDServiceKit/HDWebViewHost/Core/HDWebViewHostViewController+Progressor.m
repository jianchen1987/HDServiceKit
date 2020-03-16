//
//  HDServiceKitViewController+Progressor.m
//  HDServiceKit
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
    self.progressorView.hidden = NO;
}

- (void)addWebviewProgressor {
    // 仿微信进度条
    self.progressorView = [[UIProgressView alloc] init];

    self.progressorView.progressTintColor = kWebViewProgressTintColorRGB > 0 ? HDWHColorFromRGB(kWebViewProgressTintColorRGB) : [UIColor grayColor];
    self.progressorView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressorView];

    self.progressorView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.progressorView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.progressorView.topAnchor constraintEqualToAnchor:self.hd_navigationBar.bottomAnchor],
        [self.progressorView.heightAnchor constraintEqualToConstant:1.5f],
        [self.progressorView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress >= 1) {
            // 0.25s 后消失
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self invalidateClearProgressorTimer];

                self.clearProgressorTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(stopProgressor) userInfo:nil repeats:NO];
                [[NSRunLoop currentRunLoop] addTimer:self.clearProgressorTimer forMode:NSRunLoopCommonModes];
            }];
            self.progressorView.hidden = NO;
            [self.progressorView setProgress:1 animated:YES];
            [CATransaction commit];
        } else {
            [self invalidateClearProgressorTimer];

            self.progressorView.hidden = NO;
            [self.progressorView setProgress:newprogress animated:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)stopProgressor {
    self.progressorView.hidden = YES;
    [self.progressorView setProgress:0 animated:NO];

    [self invalidateClearProgressorTimer];
}

- (void)invalidateClearProgressorTimer {
    if (self.clearProgressorTimer) {
        [self.clearProgressorTimer invalidate];
        self.clearProgressorTimer = nil;
    }
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
