//
//  HDMediator+BussinessDemoType.h
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/22.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import <HDKitCore/HDMediator.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDMediator (BussinessDemoType)
- (UIViewController *)h5ViewController;
- (void)showUnsupprtedEntryTipWithActionName:(NSString *)action;
- (void)showUnsupprtedEntryTipWithRouteURL:(NSString *)routeURL;
@end

NS_ASSUME_NONNULL_END
