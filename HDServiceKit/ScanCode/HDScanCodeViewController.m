//
//  HDScanCodeViewController.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/19.
//

#import "HDScanCodeViewController.h"
#import "HDScanCodeManager.h"
#import "HDScanCodeView.h"
#import "NSBundle+HDScanCode.h"
#import <HDKitCore/HDLog.h>

@interface HDScanCodeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) HDScanCodeManager *scanTool;
@property (nonatomic, strong) HDScanCodeView *scanView;
@end

@implementation HDScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.shouldExitAfterResultBlock = YES;
    self.scanIntervalBetweenResult = 1;

    [self setup];
}

- (void)dealloc {
    HDLog(@"HDScanCodeViewController - dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self stopSession];
}

- (HDViewControllerNavigationBarStyle)hd_preferredNavigationBarStyle {
    return HDViewControllerNavigationBarStyleTransparent;
}

- (BOOL)hd_shouldHideNavigationBarBottomShadow {
    return true;
}

- (void)setup {
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setImage:[UIImage imageNamed:@"photo_library" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
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
    _scanView = [[HDScanCodeView alloc] initWithFrame:self.view.bounds];
    _scanView.colorAngle = [UIColor redColor];
    _scanView.photoframeLineW = 3;
    _scanView.isNeedShowRetangle = YES;
    _scanView.colorRetangleLine = [UIColor whiteColor];
    _scanView.notRecoginitonAreaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _scanView.animationImage = [UIImage imageNamed:@"scanLine" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil];
    _scanView.clickedMyQRCodeBlock = ^{
        !weakSelf.clickedMyQRCodeBlock ?: weakSelf.clickedMyQRCodeBlock();
    };
    _scanView.clickedFlashLightBlock = ^(BOOL open) {
        [weakSelf.scanTool openFlashSwitch:open];
    };
    [self.view addSubview:_scanView];

    // 初始化扫描工具
    _scanTool = [[HDScanCodeManager alloc] initWithPreview:preview andScanFrame:_scanView.scanRetangleRect];
    _scanTool.scanType = self.scanType;
    _scanTool.resultBlock = ^(NSString *scanString) {
        HDLog(@"扫描结果：%@", scanString);

        // 防止连续扫描出结果
        [weakSelf stopSession];

        !weakSelf.resultBlock ?: weakSelf.resultBlock(scanString);
        if (weakSelf.shouldExitAfterResultBlock) {
            if (weakSelf.presentingViewController) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } else {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.scanIntervalBetweenResult * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf startSession];
            });
        }
    };
    _scanTool.ambientLightChangedBlock = ^(float brightness) {
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

#pragma mark - private methods
- (void)startSession {
    [_scanView startScanAnimation];
    [_scanTool sessionStartRunning];
}

- (void)stopSession {
    [_scanView stopScanAnimation];
    [_scanView finishedHandle];
    [_scanView showFlashSwitch:NO];
    [_scanTool sessionStopRunning];
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

- (void)hd_backItemClick:(id)sender {
    !self.userCancelBlock ?: self.userCancelBlock();
    [super hd_backItemClick:sender];
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
