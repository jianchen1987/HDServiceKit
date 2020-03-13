//
//  HDWebViewHostAuxiliaryMainWindow.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/10.
//

#import "HDWebViewHostAuxiliaryMainWindow.h"
#import "HDWHDebugServerManager.h"

@implementation HDWebViewHostAuxiliaryMainWindow

+ (instancetype)shared {
    static dispatch_once_t once;
    static HDWebViewHostAuxiliaryMainWindow *instance;
    dispatch_once(&once, ^{
        instance = [[HDWebViewHostAuxiliaryMainWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1.f;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
    }
    return self;
}

- (void)openPlugin:(UIViewController *)vc {
    [self setRootVc:vc];
    self.hidden = NO;
}

- (void)show {
    HDWHDebugViewController *vc = [[HDWHDebugViewController alloc] init];
    [self setRootVc:vc];

    vc.debugViewDelegate = HDWHDebugServerManager.sharedInstance;
    self.hidden = NO;
}

- (void)hide {
    [self setRootVc:nil];
    self.hidden = YES;
}

- (void)setRootVc:(UIViewController *)rootVc {
    if (rootVc) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootVc];
        NSDictionary *attributesDic = @{
            NSForegroundColorAttributeName: [UIColor blackColor],
            NSFontAttributeName: [UIFont systemFontOfSize:18]
        };
        [nav.navigationBar setTitleTextAttributes:attributesDic];
        _rootVC = (HDWHDebugViewController *)rootVc;

        self.rootViewController = nav;
    } else {
        self.rootViewController = nil;
        _rootVC = nil;
    }
}
@end
