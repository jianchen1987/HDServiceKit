//
//  HDNetworkResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkResponse.h"

@implementation HDNetworkResponse

#pragma mark - life cycle

+ (instancetype)responseWithSessionTask:(NSURLSessionTask *)sessionTask responseObject:(id)responseObject error:(NSError *)error {
    HDNetworkResponse *response = [HDNetworkResponse new];
    response->_sessionTask = sessionTask;
    response->_responseObject = responseObject;
    response->_error = error;
    return response;
}

#pragma mark - getter

- (NSHTTPURLResponse *)URLResponse {
    if (!self.sessionTask || ![self.sessionTask.response isKindOfClass:NSHTTPURLResponse.class]) {
        return nil;
    }
    return (NSHTTPURLResponse *)self.sessionTask.response;
}

@end
