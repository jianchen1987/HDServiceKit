//
//  HDNetworkViewController.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDNetworkViewController.h"
#import "SANetworkRequest.h"

@interface HDNetworkViewController ()
/// SANetworkRequest
@property (nonatomic, strong) SANetworkRequest *request;
/// 显示用
@property (nonatomic, strong) UITextView *textView;
@end

@implementation HDNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.textView.topAnchor constraintEqualToAnchor:self.hd_navigationBar.bottomAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.textView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];

    [self showloading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestData];
    });
}

- (void)dealloc {
    HDLog(@"HDNetworkViewController - dealloc");
}

- (void)requestData {

    __weak __typeof(self) weakSelf = self;
    [self.request
        startWithCache:^(HDNetworkResponse *_Nonnull response) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self) {
                [self dismissLoading];

                self.textView.text = [NSString hd_convertWithJSONData:response.responseObject];
            }
            HDLog(@"0 - %@", response);
        }
        success:^(HDNetworkResponse *_Nonnull response) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self) {
                [self dismissLoading];

                self.textView.text = [NSString hd_convertWithJSONData:response.responseObject];
            }
            HDLog(@"1 - %@", response);
        }
        failure:^(HDNetworkResponse *_Nonnull response) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self) {
                [self dismissLoading];

                self.textView.text = response.error.localizedDescription;
            }
            HDLog(@"2 - %@", response);
        }];
}

- (SANetworkRequest *)request {
    if (!_request) {
        SANetworkRequest *request = [SANetworkRequest new];
        request.requestMethod = HDRequestMethodGET;
        request.cacheHandler.writeMode = HDNetworkCacheWriteModeMemoryAndDisk;
        request.cacheHandler.readMode = HDNetworkCacheReadModeAlsoNetwork;
        request.requestURI = @"charconvert/change.from";
        request.requestParameter = @{@"key": @"0e27c575047e83b407ff9e517cde9c76",
                                     @"type": @"2",
                                     @"text": @"输入字段，这里是入参"};
        _request = request;
    }
    return _request;
}

- (UITextView *)textView {
    return _textView ?: ({ _textView = UITextView.new; });
}
@end
