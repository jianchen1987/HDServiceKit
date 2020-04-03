//
//  HDNetworkRetryConfig.m
//  HDServiceKit
//
//  Created by VanJay on 2020/4/3.
//

#import "HDNetworkRetryConfig.h"

@implementation HDNetworkRetryConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxRetryCount = 0;
        self.retryInterval = 0;
        self.isRetryProgressive = false;
        self.logEnabled = true;
    }
    return self;
}

- (void)setMaxRetryCount:(NSInteger)maxRetryCount {
    _maxRetryCount = maxRetryCount;

    self.remainingRetryCount = maxRetryCount;
}
@end
