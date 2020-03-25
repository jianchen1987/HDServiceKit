//
//  CMNetworkRequest.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/25.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "CMNetworkRequest.h"
#import "HDNetworkResponse+CM.h"
#import "HDRspModel.h"

@implementation CMNetworkRequest
#pragma mark - override
- (void)hd_redirection:(void (^)(HDRequestRedirection))redirection response:(HDNetworkResponse *)response {

    // 处理错误的状态码
    if (response.error) {
        CMResponseErrorType errorType;
        switch (response.error.code) {
            case NSURLErrorTimedOut:
                errorType = CMResponseErrorTypeTimedOut;
                break;
            case NSURLErrorCancelled:
                errorType = CMResponseErrorTypeCancelled;
                break;
            default:
                errorType = CMResponseErrorTypeNoNetwork;
                break;
        }
        response.errorType = errorType;
    }

    // 自定义重定向，根据实际业务修改逻辑
    NSDictionary *responseDic = response.responseObject;
    if (![[NSString stringWithFormat:@"%@", responseDic[@"rspCode"]] isEqualToString:@"00000"]) {
        redirection(HDRequestRedirectionFailure);
        response.errorType = CMResponseErrorTypeBussinessDataError;
        return;
    }
    redirection(HDRequestRedirectionSuccess);
}

- (void)hd_preprocessSuccessInChildThreadWithResponse:(HDNetworkResponse *)response {
    response.extraData = [HDRspModel yy_modelWithJSON:response.responseObject];
}

- (void)hd_preprocessFailureInChildThreadWithResponse:(HDNetworkResponse *)response {
    response.extraData = [HDRspModel yy_modelWithJSON:response.responseObject];
}
@end
