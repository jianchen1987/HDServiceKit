//
//  HDWHDebugWindow.h
//  HDWebViewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *GCDWebServer_accessLogFileName = @"access_log.txt";

@class HDWHDebugViewController;

@protocol HDWHDebugViewDelegate <NSObject>
- (void)fetchData:(HDWHDebugViewController *)viewController completion:(void (^)(NSArray<NSString *> *))completion;
@end

@interface HDWHDebugViewController : UIViewController

@property (nonatomic, weak) id<HDWHDebugViewDelegate> debugViewDelegate;

- (void)showLogWithDataSource:(NSArray<NSString *> *)dataSource;

@end

NS_ASSUME_NONNULL_END
