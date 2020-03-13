//
//  HDServiceKitViewController+Progressor.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHost.h"

@interface HDWebViewHostViewController (Progressor)

@property (nonatomic, strong) NSTimer *clearProgressorTimer;

@property (nonatomic, strong) UIProgressView *progressorView;

- (void)startProgressor;

- (void)stopProgressor;
#pragma mark - lifecycle
- (void)setupProgressor;
- (void)teardownProgressor;

@end
