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
#import "H5DescTableViewCell.h"
#import "LoadJDWebViewViewController.h"

@interface HDH5ViewController () <UITableViewDataSource, UITableViewDelegate>
/// 列表
@property (nonatomic, strong) UITableView *tableView;
/// 数据源
@property (nonatomic, copy) NSArray *dataSource;
@end

@implementation HDH5ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];

    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    [tableView registerClass:H5DescTableViewCell.class forCellReuseIdentifier:@"CellReuseIdentifier"];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 100;

    [self initDataSource];

    kWebViewProgressTintColorRGB = 0xdcb000;
    kGCDWebServer_logging_enabled = YES;
    [[HDWHDebugServerManager sharedInstance] showDebugWindow];
    [[HDWHDebugServerManager sharedInstance] start];
    // 添加新的 Response，提供新的接口能力
    [[HDWHResponseManager defaultManager] addCustomResponse:HDCallBackExample.class];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if (![self.navigationController.viewControllers.lastObject isKindOfClass:HDWebViewHostViewController.class]) {
        [[HDWHDebugServerManager sharedInstance] hideDebugWindow];
        [[HDWHDebugServerManager sharedInstance] stop];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = (CGRect){0, CGRectGetMaxY(self.hd_navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.hd_navigationBar.frame)};
}

- (void)initDataSource {
    NSArray *dataSource = [NSArray arrayWithObjects:
                                       @{ @"name": @"加载京东页面，拦截京东 JSBridge 协议",
                                          @"url": @"https://item.m.jd.com/ware/view.action?wareId=5904827&sid=null",
                                          @"desc": @"本用例展示：WebViewHost 不仅提供了内置的 JSBridge 协议，还可以和原有的协议共存。\n 通过继承 HDWebViewHostViewController，重载了 decidePolicy 来实现这一点。保持内聚的同时，也具备一定的灵活性。\nWebViewHost 也可以让 native 主动调用自己实现的h5调用原生的能力。将前后端能力统一，满足特殊场景。\n 操作步骤:\n 点击顶部的立即下载，此时弹出一个 toast，内容是京东 JSBridge 接口传的参数。"
                                       },
                                       @{ @"name": @"加载淘宝移动端首页，观察其性能参数",
                                          @"url": @"https://m.taobao.com",
                                          @"desc": @"本用例展示：WebViewHost 的定制能力和查看简单的性能工具。 根据Xcode 控制台日志里的提示，用电脑浏览器打开调试页面，按照提示或者点击左侧快捷菜单、或直接输入 :timing 接口查看"
                                       },
                                       @{ @"name": @"加载本地文件夹，测试接口参数",
                                          @"fileName": @"/index.html",
                                          @"dir": @"LocalDir",
                                          @"domain": @"https://www.chaosource.com",
                                          @"desc": @"本用例展示：WebViewHost 加载本地文件夹资源的能力，可以自定义域名"
                                       },
                                       @{ @"name": @"加载本地页面，可向服务器发 ajax 请求",
                                          @"fileName": @"localFileSendXHR.html",
                                          @"desc": @"本地文件服务器发送请求",
                                          @"domain": @"https://github.com" },
                                       @{ @"name": @"加载内网H5测试页面",
                                          @"url": @"http://172.16.19.163:8080/test-page/index.html",
                                          @"desc": @"测试"
                                       },
                                       nil];
    self.dataSource = dataSource;
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    H5DescTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellReuseIdentifier" forIndexPath:indexPath];

    NSDictionary *object = self.dataSource[indexPath.row];

    [cell configureWithTitle:[NSString stringWithFormat:@"%ld - %@", (long)indexPath.row + 1, [object objectForKey:@"name"]] desc:[object objectForKey:@"desc"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *object = self.dataSource[indexPath.row];
    NSString *url = [object objectForKey:@"url"];
    NSString *fileName = [object objectForKey:@"fileName"];

    // 这里只是展示预渲染，大部分情况只需正常加载
    HDWHViewControllerPreRender *_Nonnull preRender = [HDWHViewControllerPreRender defaultRender];
    if (url.length > 0) {
        [preRender getWebViewController:LoadJDWebViewViewController.class
                             preloadURL:url
                             completion:^(HDWebViewHostViewController *_Nonnull vc) {
                                 if (![vc.url isEqualToString:url]) {
                                     vc.url = url;
                                 }
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    } else if (fileName.length > 0) {
        [preRender getRenderedViewController:LoadJDWebViewViewController.class
                                  completion:^(UIViewController *_Nonnull obj) {
                                      LoadJDWebViewViewController *vc = (LoadJDWebViewViewController *)obj;
                                      NSString *dir = [object objectForKey:@"dir"];
                                      NSURL *_Nonnull mainURL = [[NSBundle mainBundle] bundleURL];
                                      NSString *domain = [object objectForKey:@"domain"];
                                      if (dir.length > 0) {
                                          NSURL *url = [mainURL URLByAppendingPathComponent:dir];
                                          [vc loadIndexFile:fileName inDirectory:url domain:domain];
                                      } else {
                                          [vc loadLocalFile:[mainURL URLByAppendingPathComponent:fileName] domain:domain];
                                      }

                                      [self.navigationController pushViewController:vc animated:YES];
                                  }];
    }
}

@end
