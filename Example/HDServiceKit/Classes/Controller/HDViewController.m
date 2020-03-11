//
//  HDViewController.m
//  HDServiceKit
//
//  Created by wangwanjie on 02/26/2020.
//  Copyright (c) 2020 wangwanjie. All rights reserved.
//

#import "HDViewController.h"
#import "ExampleItem.h"
#import <HDUIKit/HDUIKit.h>

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
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"Crash 保护" destVcName:@"HDViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"文件操作" destVcName:@"HDViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"键值存储（包括归档、内存、keychain、user defaults）" destVcName:@"HDViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"定位服务" destVcName:@"HDViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"H5 容器" destVcName:@"HDH5ViewController"]];
}

- (void)setupUI {

    self.hd_navigationItem.title = @"ViPay 组件";
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
    HDLog(@"打开：%@", item.destVcName);

    Class cls = NSClassFromString(item.destVcName);
    if (cls) {
        UIViewController *vc = [[cls alloc] init];
        [self.navigationController pushViewController:vc animated:true];
    } else {
        HDLog(@"类不存在");
    }
}

#pragma mark - lazy load
- (NSMutableArray<ExampleItem *> *)dataSource {
    return _dataSource ?: ({ _dataSource = [NSMutableArray array]; });
}
@end
