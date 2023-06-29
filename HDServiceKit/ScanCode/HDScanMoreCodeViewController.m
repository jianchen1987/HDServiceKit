//
//  HDScanMoreCodeViewController.m
//  AFNetworking
//
//  Created by Tia on 2023/6/29.
//

#import "HDScanMoreCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <HDKitCore/HDLog.h>
#import "NSBundle+HDScanCode.h"
#import <HDKitCore/HDCommonDefines.h>
#import <HDUIKit/HDUIButton.h>
#import <HDKitCore/NSBundle+HDKitCore.h>

#define LocalizableString(key, value) \
HDLocalizedStringInBundleForLanguageFromTable([NSBundle hd_bundleInFramework:@"HDServiceKit" bundleName:@"HDScanCodeResources"], [self getCurrentLanguage], key, value, nil)

@interface HDScanMoreCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
// 输入输出中间桥梁(会话)
@property (strong, nonatomic) AVCaptureSession *session;
// 多个二维码 定位的数组
@property (strong, nonatomic) NSMutableArray *qrCodesArray;
//多个二维码位置点击按钮数组
@property (strong, nonatomic) NSMutableArray *qrCodesButtonArray;

@property (strong, nonatomic) UIView *cameraView;

@property (strong, nonatomic) UIView *coverView;

@property (copy, nonatomic) NSString *urlString;

@property (strong, nonatomic) dispatch_queue_t sessionQueue;

@property (strong, nonatomic) UILabel *tipsLabel;
// 重新扫码
@property (strong, nonatomic) UIButton *reScanButton;
/// 动画线条
@property (nonatomic, strong) UIImageView *scanLine;
/**
 是否正在动画
 */
@property (nonatomic, assign) BOOL isAnimating;

/// 新手电筒按钮
@property (nonatomic, strong) HDUIButton *flashButton;
/// 相册按钮
@property (nonatomic, strong) HDUIButton *photoButton;

/**
 闪光灯的状态,不需要设置，仅供外边判断状态使用
 */
@property (nonatomic, assign) BOOL flashOpen;

@end

@implementation HDScanMoreCodeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.shouldExitAfterResultBlock = YES;
        self.scanIntervalBetweenResult = 1;
        _isAnimating = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.cameraView];
    [self.cameraView addSubview:self.coverView];
    [self.cameraView addSubview:self.tipsLabel];
    [self.cameraView addSubview:self.scanLine];
    [self.cameraView addSubview:self.flashButton];
    [self.cameraView addSubview:self.photoButton];
    
    self.hd_interactivePopDisabled = YES;
    
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)updateViewConstraints {
    [self.cameraView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cameraView);
    }];
    
    [self.tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-kiPhoneXSeriesSafeBottomHeight-80);
    }];
    
    [self.flashButton sizeToFit];
    [self.flashButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.bottom.mas_equalTo(-kiPhoneXSeriesSafeBottomHeight-40);
        make.size.mas_equalTo(CGSizeMake(self.flashButton.frame.size.width + 5, self.flashButton.frame.size.height));
    }];
    
    [self.photoButton sizeToFit];
    [self.photoButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.bottom.equalTo(self.flashButton);
        make.size.mas_equalTo(CGSizeMake(self.photoButton.frame.size.width, self.photoButton.frame.size.height));
    }];
    
    [super updateViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startRunning];// 扫码
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //@"无法访问照相机，请在设置中打开相机权限"
            });
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopRunning];
}

- (HDViewControllerNavigationBarStyle)hd_preferredNavigationBarStyle {
    return HDViewControllerNavigationBarStyleTransparent;
}

- (BOOL)hd_shouldHideNavigationBarBottomShadow {
    return true;
}

- (void)startRunning {
    if(![self.session isRunning]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session startRunning];
        });

    }
    if(self.qrCodesButtonArray.count){//移除上一次的标记
        [self.qrCodesButtonArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            [button removeFromSuperview];
        }];
        [self.qrCodesButtonArray removeAllObjects];
    }
    self.coverView.hidden = YES;
    self.tipsLabel.hidden = YES;
    
    self.photoButton.hidden = NO;
    self.flashButton.hidden = NO;
    
    [self startScanAnimation];
}

- (void)stopRunning {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if([self.session isRunning]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.session stopRunning];
            });
        }
        [self stopScanAnimation];
    });
}

- (void)startScan {
    
    if (_isAnimating == NO) {
        return;
    }
    
    self.scanLine.hidden = NO;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:3.0
                     animations:^{
        weakSelf.scanLine.frame = CGRectMake(100, SCREEN_HEIGHT - kiPhoneXSeriesSafeBottomHeight - 150, SCREEN_WIDTH - 200, 4);
    }
                     completion:^(BOOL finished) {
        if (finished == YES) {
            weakSelf.scanLine.frame = CGRectMake(100, kNavigationBarH + 40, SCREEN_WIDTH - 200, 2);
            [weakSelf performSelector:@selector(startScan) withObject:nil afterDelay:0.03];
        }
    }];
}

- (void)startScanAnimation {
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    [self startScan];
}

- (void)stopScanAnimation {
    self.scanLine.frame = CGRectMake(100, kNavigationBarH + 40, SCREEN_WIDTH - 200, 2);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startScan) object:nil];
    _isAnimating = NO;
    self.scanLine.hidden = YES;
    [self.scanLine.layer removeAllAnimations];
}

- (void)appWillEnterBackground {
    [self stopScanAnimation];
}

- (void)appWillEnterPlayGround {
    [self startScanAnimation];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if ([metadataObjects count] >0){
        HDLog(@"========扫描后的url是:==============");
        NSMutableArray *muchArray = [NSMutableArray new];
        [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.type isEqualToString:AVMetadataObjectTypeQRCode]) {   //判断是否有数据，是否是二维码数据
                [muchArray addObject:obj];
            }
        }];
        [self stopRunning];// 我这里是扫码到结果就暂停扫码、加个重新扫描btn会用户友好一点，后面是处理扫码结果
        
        if([muchArray count] == 1){//扫描到一个二维码信息
            AVMetadataMachineReadableCodeObject * metadataObject = [muchArray objectAtIndex:0];
            NSString *stringValue = metadataObject.stringValue;
            
            self.urlString = stringValue.length?stringValue:@"";
            
            HDLog(@" 1111扫描后的url是:%@",self.urlString);
            if(self.urlString.length){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self analyseResultAry:self.urlString];
                });
            }
        }else if([muchArray count] >1){// 多个二维码信息 显示二维码定位页面  选择跳转
            [self.qrCodesArray removeAllObjects];
            [muchArray enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject *result, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                NSString *code = result.stringValue;
                [dic setObject:code forKey:@"code"];
                
                HDLog(@"2222 扫描后的url是:%@",code);
                
                // 标注多个二维码
                CGRect frame = [self makeFrameWithCodeObject:result Index:self.qrCodesArray.count];
                NSString *frameStr = NSStringFromCGRect(frame);
                [dic setObject:frameStr forKey:@"frame"];
                [self.qrCodesArray addObject:dic];//记录下标注的数组，下次扫码移除前面的标注
            }];
            
            self.coverView.hidden = NO;
            self.tipsLabel.hidden = NO;
            
            self.photoButton.hidden = YES;
            self.flashButton.hidden = YES;
            
            }
    }
}
//选择多个二维码中的一个
- (void)handleBtnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 1000;
    if (index < self.qrCodesArray.count) {
        NSDictionary *dic = self.qrCodesArray[index];
        if([dic.allKeys containsObject:@"code"]){
            self.urlString = [dic objectForKey:@"code"]?[dic objectForKey:@"code"]:@"";
            //            NSLog(@"2222 扫描后的url是: 选中 %@",self.urlString);
            if(self.urlString.length){
                [self analyseResultAry:self.urlString];
            }
        }
    }
}

- (void)hd_backItemClick:(UIBarButtonItem *)sender {
    if(!self.qrCodesButtonArray.count) {
        !self.userCancelBlock ?: self.userCancelBlock();
        [super hd_backItemClick:sender];
    }else{
        [self startRunning];
    }
}

/*
 AVMetadataMachineReadableCodeObject，输出的点位坐标是其在原始数据流上的坐标，与屏幕视图坐标不一样，（坐标系，值都会有差别）
 将坐标值转为屏幕显示的图像视图（self.videoPreviewLayer）上的坐标值
 */
- (CGRect)makeFrameWithCodeObject:(AVMetadataMachineReadableCodeObject *)objc Index:(NSInteger)index {
    //将二维码坐标转化为扫码控件输出视图上的坐标
    //     CGSize isize = CGSizeMake(720.0, 1280.0); // 尺寸可以考虑不要写死,当前设置的是captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    CGSize isize = self.cameraView.frame.size; //扫码控件的输出尺寸，
    float Wout = 0.00;
    float Hout = 0.00;
    BOOL wMore = YES;
    /*取分辨率与输出的layer尺寸差，
     此处以AVLayerVideoGravityResizeAspectFill填充方式为例，判断扫描的范围更宽还是更长，并计算出超出部分的尺寸，后续计算减去这部分。
     如果是其它填充方式，计算方式不一样（比如AVLayerVideoGravityResizeAspect，则计算计算留白的尺寸，并后续补足这部分）
     */
    if (isize.width/isize.height > self.cameraView.bounds.size.width/self.cameraView.bounds.size.height) {
        //当更宽时，计算扫描的坐标x为0 的点比输出视图的0点差多少（输出视图为全屏时，即屏幕外有多少）
        wMore = YES;
        Wout = (isize.width/isize.height)* self.cameraView.bounds.size.height;
        Wout = Wout - self.cameraView.bounds.size.width;
        Wout = Wout/2;
    }else{
        // 当更长时，计算y轴超出多少。
        wMore = NO;
        Hout = (isize.height/isize.width)* self.cameraView.bounds.size.width;
        Hout = Hout  - self.cameraView.bounds.size.height;
        Hout = Hout/2;
    }
    
    CGPoint point1 = CGPointZero;
    CGPoint point2 = CGPointZero;
    CGPoint point3 = CGPointZero;
    CGPoint point4 = CGPointZero;
    /*
     源坐标系下frame和角点，都是比例值，即源视频流尺寸下的百分比值。
     例子：frame ：(x = 0.26720550656318665, y = 0.0014114481164142489), size = (width = 0.16406852006912231, height = 0.29584407806396484))
     objc.corners：{0.26823519751360592, 0.29203594744002659}
     {0.4312740177700658, 0.29725551905635411}
     {0.4294213439632073, 0.012761536345436197}
     {0.26720551457151021, 0.0014114481640513654}
     */
    CGRect frame = objc.bounds;//在源坐标系的frame，
    NSArray *array = objc.corners;//源坐标系下二维码的角点
    CGPoint P = frame.origin;
    CGSize S = frame.size;
    
    //获取点
    for (int n = 0; n< array.count; n++) {
        
        CGPoint point = CGPointZero;
        CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[n]);
        CGPointMakeWithDictionaryRepresentation(dict, &point);
        //        NSLog(@"二维码角点%@",NSStringFromCGPoint(point));
        //交换xy轴
        point.x = point.y +  point.x;
        point.y = point.x - point.y;
        point.x = point.x - point.y;
        //x轴反转
        point.x = (1-point.x);
        //point乘以比列。减去尺寸差，
        if (wMore) {
            point.x = (point.x * (isize.width/isize.height)* self.cameraView.bounds.size.height) - Wout;
            point.y = self.cameraView.bounds.size.height *(point.y);
        }else{
            point.x = self.cameraView.bounds.size.width *(point.x);
            point.y = (point.y) * (isize.height/isize.width)* self.cameraView.bounds.size.width - Hout;
        }
        if (n == 0) {
            point1 = point;
        }
        if (n == 1) {
            point2 = point;
        }
        if (n == 2) {
            point3 = point;
        }
        if (n == 3) {
            point4 = point;
        }
    }
    //通过获取最小和最大的X，Y值，二维码在视图上的frame（前面得到的点不一定是正方形的二维码，也可能是菱形的或者有一定旋转角度的）
    float minX = point1.x;
    minX = minX>point2.x?point2.x:minX;
    minX = minX>point3.x?point3.x:minX;
    minX = minX>point4.x?point4.x:minX;
    
    float minY = point1.y;
    minY = minY>point2.y?point2.y:minY;
    minY = minY>point3.y?point3.y:minY;
    minY = minY>point4.y?point4.y:minY;
    P.x = minX;
    P.y = minY;
    
    float maxX = point1.x;
    maxX = maxX<point2.x?point2.x:maxX;
    maxX = maxX<point3.x?point3.x:maxX;
    maxX = maxX<point4.x?point4.x:maxX;
    
    float maxY = point1.y;
    maxY = maxY<point2.y?point2.y:maxY;
    maxY = maxY<point3.y?point3.y:maxY;
    maxY = maxY<point4.y?point4.y:maxY;
    
    S.width = maxX - minX;
    S.height = maxY - minY;
    
    //y轴坐标方向调整
    CGRect QRFrame = CGRectMake(P.x , P.y  , S.width, S.height);
    
    UIButton *tempButton = [UIButton buttonWithType:UIButtonTypeCustom];//多个二维码添加选择btn
    //    tempButton.backgroundColor = [UIColor blueColor];
    [tempButton setImage:[UIImage imageNamed:@"icon_scan_result_button" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    tempButton.frame = QRFrame;
    [self.cameraView addSubview:tempButton];
    tempButton.tag = 1000 + index;
    [tempButton addTarget:self action:@selector(handleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.qrCodesButtonArray addObject:tempButton];
    
    return QRFrame;
}

- (void)analyseResultAry:(NSString *)resultAsString{
    // 防止连续扫描出结果
    
    if (self.shouldExitAfterResultBlock) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.scanIntervalBetweenResult * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startRunning];
        });
    }
    !self.resultBlock ?: self.resultBlock(resultAsString);
}


- (void)photoButtonClickedHandler {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *_imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
//        _imagePickerController.allowsEditing = YES;
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
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES
                             completion:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                                  context:nil
                                                  options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >= 1) {
            CIQRCodeFeature *feature = [features firstObject];
            [self analyseResultAry:feature.messageString];
        }else{
            HDLog(@"没有识别到二维码");
            [self stopRunning];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startRunning];
            });
        }
    }];
}

#pragma mark - lazy load
- (AVCaptureSession *)session {
    if (!_session) {
        //1.获取输入设备（摄像头）
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //2.根据输入设备创建输入对象
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
        if (input == nil) {
            return nil;
        }
        //3.创建元数据的输出对象
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
        //4.设置代理监听输出对象输出的数据,在主线程中刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        // 5.创建会话(桥梁)
        AVCaptureSession *session = [[AVCaptureSession alloc]init];
        //实现高质量的输出和摄像，默认值为AVCaptureSessionPresetHigh，可以不写
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        // 6.添加输入和输出到会话中（判断session是否已满）
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        
        // 7.告诉输出对象, 需要输出什么样的数据 (二维码还是条形码等) 要先创建会话才能设置
        // 设置扫码支持的编码格式
        switch (self.scanType) {
            case HDCodeScannerTypeAll:
                output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                               AVMetadataObjectTypeEAN13Code,
                                               AVMetadataObjectTypeEAN8Code,
                                               AVMetadataObjectTypeUPCECode,
                                               AVMetadataObjectTypeCode39Code,
                                               AVMetadataObjectTypeCode39Mod43Code,
                                               AVMetadataObjectTypeCode93Code,
                                               AVMetadataObjectTypeCode128Code,
                                               AVMetadataObjectTypePDF417Code];
                break;
                
            case HDCodeScannerTypeQRCode:
                output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
                break;
                
            case HDCodeScannerTypeBarcode:
                output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                               AVMetadataObjectTypeEAN8Code,
                                               AVMetadataObjectTypeUPCECode,
                                               AVMetadataObjectTypeCode39Code,
                                               AVMetadataObjectTypeCode39Mod43Code,
                                               AVMetadataObjectTypeCode93Code,
                                               AVMetadataObjectTypeCode128Code,
                                               AVMetadataObjectTypePDF417Code];
                break;
                
            default:
                break;
        }
        
        // 8.创建预览图层
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.frame = self.cameraView.bounds;
        [self.cameraView.layer insertSublayer:previewLayer atIndex:0];
        
        //9.设置有效扫描区域，默认整个图层(很特别，1、要除以屏幕宽高比例，2、其中x和y、width和height分别互换位置)
        //        CGRect rect = CGRectMake(kBgImgY/ScreenHeight, kBgImgX/ScreenWidth, kBgImgWidth/ScreenHeight, kBgImgWidth/ScreenWidth);
        
        _session = session;
    }
    return _session;
}

- (UIView *)cameraView {
    if(!_cameraView) {
        _cameraView = UIView.new;
    }
    return _cameraView;
}

- (UIView *)coverView {
    if(!_coverView) {
        _coverView = UIView.new;
        _coverView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        _coverView.hidden = YES;
    }
    return _coverView;
}

- (NSMutableArray *)qrCodesButtonArray {
    if(!_qrCodesButtonArray) {
        _qrCodesButtonArray = NSMutableArray.new;
    }
    return _qrCodesButtonArray;
}

- (NSMutableArray *)qrCodesArray {
    if(!_qrCodesArray) {
        _qrCodesArray = NSMutableArray.new;
    }
    return _qrCodesArray;
}

- (UILabel *)tipsLabel {
    if(!_tipsLabel) {
        _tipsLabel = UILabel.new;
        _tipsLabel.textColor = UIColor.whiteColor;
        _tipsLabel.text = @"轻触小红点，打开页面";
        _tipsLabel.font = [UIFont systemFontOfSize:16];
        _tipsLabel.hidden = YES;
    }
    return _tipsLabel;
}

- (UIImageView *)scanLine {
    if (!_scanLine) {
        _scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(100, kNavigationBarH + 40, SCREEN_WIDTH - 200, 2)];
        _scanLine.image = [UIImage imageNamed:@"scanLine" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil];;
        _scanLine.contentMode = UIViewContentModeScaleToFill;
        _scanLine.hidden = YES;
    }
    return _scanLine;
}

- (HDUIButton *)flashButton {
    if(!_flashButton) {
        HDUIButton *btn = HDUIButton.new;
//        btn.imagePosition = HDUIButtonImagePositionTop;
//        btn.spacingBetweenImageAndTitle = 10;
//        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [btn setTitle:LocalizableString(@"Turn_on_flashlight", @"打开手电筒") forState:UIControlStateNormal];
//        [btn setTitle:LocalizableString(@"Turn_off_flashlight", @"关闭手电筒") forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"icon_scan_open" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"icon_scan_close" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        __weak __typeof(self) weakSelf = self;
        [btn addTouchUpInsideHandler:^(UIButton * _Nonnull btn) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            btn.selected = !btn.selected;
            if (self.flashOpen == btn.selected) return;
            
            self.flashOpen = btn.selected;
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

            if ([device hasTorch] && [device hasFlash]) {
                [device lockForConfiguration:nil];
                if (self.flashOpen) {
                    device.torchMode = AVCaptureTorchModeOn;
                    device.flashMode = AVCaptureFlashModeOn;
                } else {
                    device.torchMode = AVCaptureTorchModeOff;
                    device.flashMode = AVCaptureFlashModeOff;
                }
                [device unlockForConfiguration];
            }
        }];
        
        _flashButton = btn;
        [btn sizeToFit];
    }
    return _flashButton;
}

- (HDUIButton *)photoButton {
    if(!_photoButton) {
        HDUIButton *btn = HDUIButton.new;
//        btn.imagePosition = HDUIButtonImagePositionTop;
//        btn.spacingBetweenImageAndTitle = 10;
//        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:14];
//        [btn setTitle:LocalizableString(@"Choose_from_album", @"从相册选取") forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"icon_scan_photo" inBundle:[NSBundle hd_ScanCodeResources] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        @HDWeakify(self);
        [btn addTouchUpInsideHandler:^(UIButton * _Nonnull btn) {
            @HDStrongify(self);
            [self photoButtonClickedHandler];
        }];
        
        _photoButton = btn;
        [btn sizeToFit];
    }
    return _photoButton;
}

static NSString *const kCurrentLanguageCacheKey = @"kCurrentLanguageCache";

- (NSString *)getCurrentLanguage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentLanguage = [defaults valueForKey:kCurrentLanguageCacheKey];
    if (!currentLanguage) {
        currentLanguage = @"en-US";  /// 默认英文
    }
    return currentLanguage;
}

@end
