//
//  SANetworkViewController.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "SANetworkViewController.h"
#import "SANetworkRequest.h"

@interface SANetworkViewController () <HDResponseDelegate>
/// SANetworkRequest
@property (nonatomic, strong) SANetworkRequest *request;
/// SANetworkRequest
@property (nonatomic, strong) SANetworkRequest *request2;
/// 显示用
@property (nonatomic, strong) UITextView *textView;
/// 显示用
@property (nonatomic, strong) UITextView *textView2;
@end

@implementation SANetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.textView.topAnchor constraintEqualToAnchor:self.hd_navigationBar.bottomAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.textView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];

    [self.view addSubview:self.textView2];
    self.textView2.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.textView2.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.textView2.topAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.textView2.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.textView2.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
    ]];

    [self showloading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestData];

        [self requestData2];
    });
}

- (void)dealloc {
    HDLog(@"SANetworkViewController - dealloc");

    if (_request) {
        [_request cancel];
    }
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
            HDLog(@"request 1: cache - %@", response.responseObject);
        }
        success:^(HDNetworkResponse *_Nonnull response) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self) {
                [self dismissLoading];

                self.textView.text = [NSString hd_convertWithJSONData:response.responseObject];
            }
            HDLog(@"request 1: success - %@", response.responseObject);
        }
        failure:^(HDNetworkResponse *_Nonnull response) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self) {
                [self dismissLoading];

                self.textView.text = [NSString hd_convertWithJSONData:response.responseObject];
            }
            HDLog(@"request 1: fail - %@", response.responseObject);
        }];
}

- (void)requestData2 {
    [self.request2 start];
}

#pragma mark - HDResponseDelegate
- (void)request:(__kindof HDNetworkRequest *)request cacheWithResponse:(HDNetworkResponse *)response {
    if (request == self.request2) {
        self.textView2.text = [NSString hd_convertWithJSONData:response.responseObject];
        HDLog(@"request 2: cache - %@", response.responseObject);
    }
}

- (void)request:(__kindof HDNetworkRequest *)request successWithResponse:(HDNetworkResponse *)response {
    if (request == self.request2) {
        self.textView2.text = [NSString hd_convertWithJSONData:response.responseObject];
        HDLog(@"request 2: success - %@", response.responseObject);
    }
}

- (void)request:(__kindof HDNetworkRequest *)request failureWithResponse:(HDNetworkResponse *)response {
    if (request == self.request2) {
        self.textView2.text = [NSString hd_convertWithJSONData:response.responseObject];
        HDLog(@"request 2: fail - %@", response.responseObject);
    }
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

- (SANetworkRequest *)request2 {
    if (!_request2) {
        SANetworkRequest *request = [SANetworkRequest new];
        request.requestMethod = HDRequestMethodGET;
        request.cacheHandler.writeMode = HDNetworkCacheWriteModeMemoryAndDisk;
        request.cacheHandler.readMode = HDNetworkCacheReadModeAlsoNetwork;
        request.requestURI = @"charconvert/change.from";
        request.requestParameter = @{@"key": @"0e27c575047e83b407ff9e517cde9c76",
                                     @"type": @"2",
                                     @"text": @"输入字段，这里是入参2"};
        request.delegate = self;
        _request2 = request;
    }
    return _request2;
}

- (UITextView *)textView {
    return _textView ?: ({ _textView = UITextView.new; });
}

- (UITextView *)textView2 {
    return _textView2 ?: ({ _textView2 = UITextView.new; });
}
@end
