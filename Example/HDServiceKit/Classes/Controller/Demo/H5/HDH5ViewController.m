//
//  HDH5ViewController.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/11.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDH5ViewController.h"
#import <HDServiceKit/HDWebViewHost.h>
#import "HDCallBackExample.h"

@interface HDH5ViewController ()

@end

@implementation HDH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HDWHResponseManager.defaultManager addCustomResponse:HDCallBackExample.class];

    [HDWHDebugServerManager.sharedInstance showDebugWindow];
    [HDWHDebugServerManager.sharedInstance start];
    NSString *url = @"https://www.baidu.com";
    self.url = url;
}
@end
