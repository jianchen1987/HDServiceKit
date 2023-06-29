//
//  HDScanMoreCodeViewController.h
//  AFNetworking
//
//  Created by Tia on 2023/6/29.
//

#import "HDScanCodeDefines.h"
#import <HDUIKit/HDCommonViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDScanMoreCodeViewController : HDCommonViewController
/** 扫描类型 */
@property (nonatomic, assign) HDCodeScannerType scanType;

/// 扫描到结果后是否退出，默认 YES
@property (nonatomic, assign) BOOL shouldExitAfterResultBlock;

/// 扫描出结果后的回调 ，注意循环引用的问题
@property (nonatomic, copy) HDScanCodeResultBlock _Nullable resultBlock;

/// 扫描出结果后，session 会暂停，该时间后自动恢复（仅在 shouldExitAfterResultBlock 为 NO 时生效），默认 1 秒，单位：秒
@property (nonatomic, assign) NSTimeInterval scanIntervalBetweenResult;
/// 点击我的二维码的回调
@property (nonatomic, copy) HDScanCodeClickedMyQRCodeBlock clickedMyQRCodeBlock;

/// 用户点击了返回即取消的回调
@property (nonatomic, copy) void (^userCancelBlock)(void);

@property (nonatomic, copy) NSString *customerTitle;      ///< 自定义标题
@end

NS_ASSUME_NONNULL_END
