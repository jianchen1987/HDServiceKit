//
//  HDWHSimpleWebViewController.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHSimpleWebViewController.h"
#import <WebKit/WebKit.h>

@interface HDWHSimpleWebViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation HDWHSimpleWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebView *webView = [WKWebView new];
    self.webView = webView;
    webView.frame = self.view.bounds;
    [self.view addSubview:webView];
    
    if (self.htmlString.length > 0) {
        [webView loadHTMLString:self.htmlString baseURL:[NSURL URLWithString:self.domain?:@"https://m.you.163.com"] ];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
