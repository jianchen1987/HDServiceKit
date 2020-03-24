//
//  HDNetworkManager.h
//  HDServiceKit
//
//  Created by VanJay on 03/24/2020.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import "HDNetworkRequest.h"
#import "HDNetworkResponse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HDRequestCompletionBlock)(HDNetworkResponse *response);

@interface HDNetworkManager : NSObject

+ (instancetype)sharedManager;

- (nullable NSNumber *)startNetworkingWithRequest:(HDNetworkRequest *)request
                                   uploadProgress:(nullable HDRequestProgressBlock)uploadProgress
                                 downloadProgress:(nullable HDRequestProgressBlock)downloadProgress
                                       completion:(nullable HDRequestCompletionBlock)completion;

- (void)cancelNetworkingWithSet:(NSSet<NSNumber *> *)set;

- (instancetype)init OBJC_UNAVAILABLE("use '+sharedManager' instead");
+ (instancetype)new OBJC_UNAVAILABLE("use '+sharedManager' instead");

@end

NS_ASSUME_NONNULL_END
