//
//  WNHelloAckMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloUploadMsg.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNHelloAckMsg : WNHelloUploadMsg

- (instancetype)initWithMessageID:(NSString *)messageId;

///< 消息Id
@property (nonatomic, copy, readonly) NSString *messageID;

@end

NS_ASSUME_NONNULL_END
