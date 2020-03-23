//
//  HDScanCodeView.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/19.
//

#import "HDScanCodeDefines.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HDScanCodeClickedFlashLightBlock)(BOOL isOpen);

@interface HDScanCodeView : UIView

/**
 点击我的二维码的回调
 */
@property (nonatomic, copy) HDScanCodeClickedMyQRCodeBlock clickedMyQRCodeBlock;

/**
 打开/关闭闪光灯的回调
 */
@property (nonatomic, copy) HDScanCodeClickedFlashLightBlock clickedFlashLightBlock;

#pragma mark - 扫码区域

/// 扫码区域 默认为正方形，边长为宽 0.7倍, 居中
@property (nonatomic, assign) CGRect scanRetangleRect;
/// 是否需要绘制扫码矩形框，默认YES
@property (nonatomic, assign) BOOL isNeedShowRetangle;
/// 矩形框线条颜色
@property (nonatomic, strong, nullable) UIColor *colorRetangleLine;

#pragma mark - 矩形框(扫码区域)周围 4 个角
/// 4个角的颜色
@property (nonatomic, strong, nullable) UIColor *colorAngle;
/// 扫码区域4个角的宽度 默认为 20
@property (nonatomic, assign) CGFloat photoframeAngleW;
/// 扫码区域4个角的高度 默认为 20
@property (nonatomic, assign) CGFloat photoframeAngleH;
/// 扫码区域4个角的线条宽度，默认 6
@property (nonatomic, assign) CGFloat photoframeLineW;

#pragma mark - 动画效果

/**
 *  动画效果的图像
 */
@property (nonatomic, strong, nullable) UIImage *animationImage;

/**
 非识别区域颜色,默认 RGBA (0,0,0,0.5)
 */
@property (nonatomic, strong, nullable) UIColor *notRecoginitonAreaColor;

/**
 *  开始扫描动画
 */
- (void)startScanAnimation;
/**
 *  结束扫描动画
 */
- (void)stopScanAnimation;

/**
 正在处理扫描到的结果
 */
- (void)handlingResultsOfScan;

/**
 完成扫描结果处理
 */
- (void)finishedHandle;

/**
 是否显示闪光灯开关
 @param show YES or NO
 */
- (void)showFlashSwitch:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
