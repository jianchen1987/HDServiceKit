//
//  HDScanCodeManager.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/19.
//

#import "HDScanCodeManager.h"

@interface HDScanCodeManager () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
/// 会话
@property (nonatomic, strong) AVCaptureSession *session;

/**
 扫描中心识别区域范围
 */
@property (nonatomic, assign) CGRect scanFrame;

/**
 展示输出流的视图——即照相机镜头下的内容
 */
@property (nonatomic, strong) UIView *preview;

@end

@implementation HDScanCodeManager

- (instancetype)initWithPreview:(UIView *)preview andScanFrame:(CGRect)scanFrame {
    if (self == [super init]) {
        self.preview = preview;
        self.scanFrame = scanFrame;
        [self configuredScanManager];
    }
    return self;
}

#pragma mark - private methods
// 初始化采集配置信息
- (void)configuredScanManager {
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.preview.layer.bounds;
    [self.preview.layer insertSublayer:layer atIndex:0];
}

#pragma mark - event response
- (void)openFlashSwitch:(BOOL)open {
    if (self.flashOpen == open) {
        return;
    }
    self.flashOpen = open;
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
}

#pragma mark - public methods
- (void)sessionStartRunning {
    [_session startRunning];
}

- (void)sessionStopRunning {
    [_session stopRunning];
}

- (void)scanImageQRCode:(UIImage *)imageCode {

    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:imageCode.CGImage]];
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features firstObject];
        !self.resultBlock ?: self.resultBlock(feature.messageString);
    } else {
        !self.resultBlock ?: self.resultBlock(nil);
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
// 扫描完成后执行
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        // 扫描完成后的字符
        !self.resultBlock ?: self.resultBlock(metadataObject.stringValue);
    }
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate的方法
// 扫描过程中执行，主要用来判断环境的黑暗程度
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    if (self.ambientLightChangedBlock == nil) {
        return;
    }

    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    !self.ambientLightChangedBlock ?: self.ambientLightChangedBlock(brightnessValue);
}

#pragma mark - lazy load
- (AVCaptureSession *)session {
    if (!_session) {
        // 获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input) {
            return nil;
        }

        // 创建二维码扫描输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        // 设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        // 设置采集扫描区域的比例 默认全屏是（0，0，1，1）
        // rectOfInterest 填写的是一个比例，输出流视图preview.frame为 x , y, w, h, 要设置的矩形快的scanFrame 为 x1, y1, w1, h1. 那么rectOfInterest 应该设置为 CGRectMake(y1/y, x1/x, h1/h, w1/w)。
        CGFloat x = CGRectGetMinX(self.scanFrame) / CGRectGetWidth(self.preview.frame);
        CGFloat y = CGRectGetMinY(self.scanFrame) / CGRectGetHeight(self.preview.frame);
        CGFloat width = CGRectGetWidth(self.scanFrame) / CGRectGetWidth(self.preview.frame);
        CGFloat height = CGRectGetHeight(self.scanFrame) / CGRectGetHeight(self.preview.frame);
        output.rectOfInterest = CGRectMake(y, x, height, width);

        // 创建环境光感输出流
        AVCaptureVideoDataOutput *lightOutput = [[AVCaptureVideoDataOutput alloc] init];
        [lightOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

        _session = [[AVCaptureSession alloc] init];
        // 高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        [_session addInput:input];
        [_session addOutput:output];
        [_session addOutput:lightOutput];

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
    }
    return _session;
}
@end
