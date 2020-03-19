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
#import <objc/runtime.h>

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
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"Crash 保护" destVcName:@"HDCrashProtectViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"文件操作" destVcName:@"HDFileOperViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"线程安全键值存储方案（包括归档、内存、keychain、user defaults）" destVcName:@"HDKVDBViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"定位服务" destVcName:@"HDLocationViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"H5 容器" destVcName:@"HDH5ViewController"]];
    [self.dataSource addObject:[ExampleItem itemWithDesc:@"扫一扫" destVcName:@"HDScanCodeViewController"]];
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
    const char *className = [item.destVcName cStringUsingEncoding:NSASCIIStringEncoding];
    Class cls = objc_getClass(className);
    if (!cls) {
        // 创建一个类
        Class superClass = [HDBaseViewController class];
        cls = objc_allocateClassPair(superClass, className, 0);
        // 注册你创建的这个类
        objc_registerClassPair(cls);
        vc = [[cls alloc] init];
    } else {
        vc = [[cls alloc] init];
    }
    vc.hd_navigationItem.title = item.desc;

    [self.navigationController pushViewController:vc animated:true];
    HDLog(@"打开：%@", item.destVcName);
}

#pragma mark - lazy load
- (NSMutableArray<ExampleItem *> *)dataSource {
    return _dataSource ?: ({ _dataSource = [NSMutableArray array]; });
}
@end
