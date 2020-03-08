//
//  HDWHSimpleWebViewController.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWHSimpleWebViewController : UIViewController

@property (nonatomic, strong) NSString *htmlString;

@property (nonatomic, strong) NSString *domain;

@end

NS_ASSUME_NONNULL_END
