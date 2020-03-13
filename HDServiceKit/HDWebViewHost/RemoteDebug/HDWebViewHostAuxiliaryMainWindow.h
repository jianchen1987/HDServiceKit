//
//  HDWebViewHostAuxiliaryMainWindow.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/10.
//

#import "HDWHDebugViewController.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewHostAuxiliaryMainWindow : UIWindow
@property (nonatomic, strong, readonly) HDWHDebugViewController *rootVC;
+ (instancetype)shared;
- (void)show;
- (void)hide;
@end

NS_ASSUME_NONNULL_END
