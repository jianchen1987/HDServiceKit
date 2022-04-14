//
//  WNDisconnectMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/4/14.
//

#import "WNHelloUploadMsg.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNHelloDisconnectMsg : WNHelloUploadMsg

- (instancetype)initWithReason:(NSString *_Nullable)reason;

+ (instancetype)disconnectWithReason:(NSString *_Nullable)reason;

@end

NS_ASSUME_NONNULL_END
