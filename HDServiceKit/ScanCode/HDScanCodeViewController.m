//
//  HDScanCodeViewController.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/19.
//

#import "HDScanCodeViewController.h"
#import "WSLScanView.h"
#import "WSLNativeScanTool.h"
#import <HDUIKit/HDLog.h>
#import "NSBundle+HDScanCode.h"

@interface HDScanCodeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) WSLNativeScanTool *scanTool;
@property (nonatomic, strong) WSLScanView *scanView;
@end

@implementation HDScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_scanView startScanAnimation];
    [_scanTool sessionStartRunning];

    self.hd_navBarAlpha = 0;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [_scanView stopScanAnimation];
    [_scanView finishedHandle];
    [_scanView showFlashSwitch:NO];
    [_scanTool sessionStopRunning];
}

- (BOOL)hd_shouldHideNavigationBarBottomShadow {
    return true;
}

- (void)setup {
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setTitle:@"相册" forState:UIControlStateNormal];
    [photoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(photoButtonClickedHandler) forControlEvents:UIControlEventTouchUpInside];
    self.hd_navigationItem.title = @"扫一扫";
    [photoBtn sizeToFit];
    self.hd_navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:photoBtn];

    // 输出流视图
    UIView *preview = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preview];

    __weak typeof(self) weakSelf = self;

    // 构建扫描样式视图
    _scanView = [[WSLScanView alloc] initWithFrame:self.view.bounds];
    const CGFloat scanAreaWidth2ScreenWidth = 0.7;
    const CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    const CGFloat scanAreaWidth = scanAreaWidth2ScreenWidth * screenWidth;

    _scanView.scanRetangleRect = CGRectMake((screenWidth - scanAreaWidth) * 0.5, (CGRectGetHeight(self.view.frame) - scanAreaWidth) * 0.5, scanAreaWidth, scanAreaWidth);
    _scanView.colorAngle = [UIColor greenColor];
    _scanView.photoframeAngleW = 20;
    _scanView.photoframeAngleH = 20;
    _scanView.photoframeLineW = 2;
    _scanView.isNeedShowRetangle = YES;
    _scanView.colorRetangleLine = [UIColor whiteColor];
    _scanView.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _scanView.animationImage = [UIImage imageNamed:@"scanLine" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil];
    _scanView.myQRCodeBlock = ^{
        HDLog(@"点击了我的二维码");
    };
    _scanView.flashSwitchBlock = ^(BOOL open) {
        [weakSelf.scanTool openFlashSwitch:open];
    };
    [self.view addSubview:_scanView];

    // 初始化扫描工具
    _scanTool = [[WSLNativeScanTool alloc] initWithPreview:preview andScanFrame:_scanView.scanRetangleRect];
    _scanTool.scanFinishedBlock = ^(NSString *scanString) {
        HDLog(@"扫描结果 %@", scanString);
        [weakSelf.scanView handlingResultsOfScan];

        [weakSelf.scanTool sessionStopRunning];
        [weakSelf.scanTool openFlashSwitch:NO];
    };
    _scanTool.monitorLightBlock = ^(float brightness) {
        if (brightness < 0) {
            // 环境太暗，显示闪光灯开关按钮
            [weakSelf.scanView showFlashSwitch:YES];
        } else if (brightness > 0) {
            // 环境亮度可以,且闪光灯处于关闭状态时，隐藏闪光灯开关
            if (!weakSelf.scanTool.flashOpen) {
                [weakSelf.scanView showFlashSwitch:NO];
            }
        }
    };

    [_scanTool sessionStartRunning];
    [_scanView startScanAnimation];
}

#pragma mark - event response
- (void)photoButtonClickedHandler {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *_imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.allowsEditing = YES;
        _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    } else {
        NSLog(@"不支持访问相册");
    }
}

#pragma mark UIImagePickerControllerDelegate

/// 选择了媒体文件
/// @param picker 选择器
/// @param info 信息
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [_scanTool scanImageQRCode:image];
}
@end
