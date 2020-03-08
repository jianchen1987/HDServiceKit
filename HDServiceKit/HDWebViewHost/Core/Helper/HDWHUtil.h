//
//  HDWHUtil.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWHUtil : NSObject

+ (BOOL)isNetworkUrl:(NSString *)url;

+ (NSString *)traceId;
@end

NS_ASSUME_NONNULL_END
