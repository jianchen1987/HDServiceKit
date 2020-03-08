//
//  HDWebviewHostViewController+Dispatch.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HDWebViewHostViewController (Dispatch)

/**
 * 核心的h5调用native接口的分发器；
 * @return 是否已经被处理，YES 表示可被处理；
 */
- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict;

#pragma mark - like private

- (void)dispatchParsingParameter:(NSDictionary *)contentJSON;

@end

NS_ASSUME_NONNULL_END
