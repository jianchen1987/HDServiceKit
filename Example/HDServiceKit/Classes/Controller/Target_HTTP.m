//
//  Target_HTTP.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/22.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "Target_HTTP.h"
#import "HDWebViewHostViewController.h"
#import <HDKitCore/HDLog.h>

@implementation Target_HTTP
- (void)action_openURL:(NSDictionary *)params {
    NSURL *url = [params valueForKey:@"url"];
    HDLog(@"打开地址：%@", url.absoluteString);

    HDWebViewHostViewController *vc = HDWebViewHostViewController.new;
    vc.url = url.absoluteString;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}
@end
