//
//  HDViewController.m
//  HDServiceKit
//
//  Created by wangwanjie on 02/26/2020.
//  Copyright (c) 2020 wangwanjie. All rights reserved.
//

#import "HDViewController.h"
#import "ExampleItem.h"
#import "HDMediator+BussinessDemoType.h"
#import <HDKitCore/HDKitCore.h>

@interface HDViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray<ExampleItem *> *dataSource;  ///< 数据源
@end

@implementation HDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HDLog(@"HDServiceKit 版本：%@", HDServiceKit_VERSION);

    [self initDataSource];
    [self setupUI];
}

- (void)initDataSource {
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"Crash 保护" mediatorAction:@"crashProtectViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"文件操作" mediatorAction:@"fileOperViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"线程安全键值存储方案（包括归档、内存、keychain、user defaults）" mediatorAction:@"kvDBViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"定位服务" routeURL:@"chaos://DemoTarget/locationViewController?address=广州&source=superapp"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"H5 容器" mediatorAction:@"h5ViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"扫一扫" routeURL:@"chaos://DemoTarget/scanCodeViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"执行加法计算" routeURL:nil]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"打开网页" routeURL:@"https://www.baidu.com"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"RSA加解密" routeURL:@"chaos://DemoTarget/rsaCipherViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"网络请求" routeURL:@"chaos://DemoTarget/networkViewController"]];
}

- (void)setupUI {

    self.hd_navigationItem.title = @"混沌服务";
    self.view.backgroundColor = UIColor.whiteColor;

    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0, CGRectGetMaxY(self.hd_navigationBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.hd_navigationBar.frame)}];
    [self.view addSubview:tableView];

    tableView.dataSource = self;
    tableView.delegate = self;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 新建标识
    static NSString *ID = @"ReusableCellIdentifier";
    // 创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    ExampleItem *item = self.dataSource[indexPath.row];
    cell.textLabel.text = item.desc;
    cell.textLabel.numberOfLines = 0;

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    ExampleItem *item = self.dataSource[indexPath.row];

    UIViewController *vc;
    if (item.mediatorAction) {
        NSString *mediatorAction = item.mediatorAction;
        SEL sel = NSSelectorFromString(mediatorAction);
        if ([HDMediator.sharedInstance respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            vc = [HDMediator.sharedInstance performSelector:sel];
            HDLog(@"打开：%@", item.mediatorAction);
#pragma clang diagnostic pop
        } else {
            [HDMediator.sharedInstance showUnsupprtedEntryTipWithActionName:item.mediatorAction];
        }
    } else if (item.routeURL) {
        if ([HDMediator.sharedInstance canPerformActionWithURL:item.routeURL]) {
            vc = [HDMediator.sharedInstance performActionWithURL:item.routeURL params:@{@"source": @"home"}];
            HDLog(@"打开：%@", item.routeURL);
        } else {
            [HDMediator.sharedInstance showUnsupprtedEntryTipWithRouteURL:item.routeURL];
        }
    } else {
        typedef void (^ResultBlock)(NSUInteger);
        ResultBlock callback = ^(NSUInteger value) {
            HDLog(@"回调触发，和：%zd", value);
        };

        [HDMediator.sharedInstance performTarget:@"DemoTarget"
                                          action:@"plus"
                                          params:@{@"value1": @(10),
                                                   @"value2": @(11),
                                                   @"callback": callback}];
    }
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        vc.hd_navigationItem.title = item.desc;
        [self.navigationController pushViewController:vc animated:true];
    }
}

#pragma mark - lazy load
- (NSMutableArray<ExampleItem *> *)dataSource {
    return _dataSource ?: ({ _dataSource = [NSMutableArray array]; });
}
@end
