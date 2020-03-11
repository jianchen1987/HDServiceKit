//
//  HDWebViewHostAuxiliaryEntryWindow.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/10.
//

#import "HDWebViewHostAuxiliaryEntryWindow.h"
#import "HDWebViewHostEnum.h"
#import "NSBundle+HDWebViewHost.h"
#import "HDWebViewHostAuxiliaryMainWindow.h"

@implementation HDWebViewHostAuxillaryToolStatusBarVC

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end

@interface HDWebViewHostAuxiliaryEntryWindow ()

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) UIButton *entryBtn;
@end

@implementation HDWebViewHostAuxiliaryEntryWindow
static CGFloat _kEntryViewSize = 58;
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, HDWH_SCREEN_WIDTH / 4, _kEntryViewSize, _kEntryViewSize)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 100.f;
        self.layer.masksToBounds = YES;
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 10.0) {
            if (!self.rootViewController) {
                self.rootViewController = [[UIViewController alloc] init];
            }
        } else {
            // iOS9.0的系统中，新建的window设置的rootViewController默认没有显示状态栏
            if (!self.rootViewController) {
                self.rootViewController = [[HDWebViewHostAuxillaryToolStatusBarVC alloc] init];
            }
        }

        UIButton *entryBtn = [[UIButton alloc] initWithFrame:self.bounds];
        entryBtn.backgroundColor = [UIColor clearColor];
        [entryBtn setImage:self.logoImage forState:UIControlStateNormal];
        entryBtn.layer.cornerRadius = 20.;
        [entryBtn addTarget:self action:@selector(entryClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootViewController.view addSubview:entryBtn];
        _entryBtn = entryBtn;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)showClose:(NSNotification *)notification {
    [_entryBtn setImage:[UIImage imageNamed:@"ic-button-close"] forState:UIControlStateNormal];
    [_entryBtn removeTarget:self action:@selector(showClose:) forControlEvents:UIControlEventTouchUpInside];
    [_entryBtn addTarget:self action:@selector(closePluginClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closePluginClick:(UIButton *)btn {
    [_entryBtn setImage:[UIImage imageNamed:@"img_logo_vipay_2"] forState:UIControlStateNormal];
    [_entryBtn removeTarget:self action:@selector(closePluginClick:) forControlEvents:UIControlEventTouchUpInside];
    [_entryBtn addTarget:self action:@selector(entryClick:) forControlEvents:UIControlEventTouchUpInside];
}

// 不能让该View成为keyWindow，每一次它要成为keyWindow的时候，都要将appDelegate的window指为keyWindow
- (void)becomeKeyWindow {
    UIWindow *appWindow = [[UIApplication sharedApplication].delegate window];
    [appWindow makeKeyWindow];
}

/**
 进入主面板
 */
- (void)entryClick:(UIButton *)btn {

    if ([HDWebViewHostAuxiliaryMainWindow shared].isHidden) {
        [[HDWebViewHostAuxiliaryMainWindow shared] show];
    } else {
        [[HDWebViewHostAuxiliaryMainWindow shared] hide];
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender {
    //1、获得拖动位移
    CGPoint offsetPoint = [sender translationInView:sender.view];
    //2、清空拖动位移
    [sender setTranslation:CGPointZero inView:sender.view];
    //3、重新设置控件位置
    UIView *panView = sender.view;
    CGFloat newX = panView.center.x + offsetPoint.x;
    CGFloat newY = panView.center.y + offsetPoint.y;
    if (newX < _kEntryViewSize / 2) {
        newX = _kEntryViewSize / 2;
    }
    if (newX > HDWH_SCREEN_WIDTH - _kEntryViewSize / 2) {
        newX = HDWH_SCREEN_WIDTH - _kEntryViewSize / 2;
    }
    if (newY < _kEntryViewSize / 2) {
        newY = _kEntryViewSize / 2;
    }
    if (newY > HDWH_SCREEN_HEIGHT - _kEntryViewSize / 2) {
        newY = HDWH_SCREEN_HEIGHT - _kEntryViewSize / 2;
    }
    panView.center = CGPointMake(newX, newY);
}


#pragma mark - getters and setters
static UIImage *_logoImage = nil;
- (UIImage *)logoImage {
    if (!_logoImage) {
        NSURL *imageURL = [[NSBundle hd_WebViewHostRemoteDebugResourcesBundle] URLForResource:@"src/logo" withExtension:@"png"];
        _logoImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
    }
    return _logoImage;
}
@end
