//
//  WNHelloDataMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/27.
//

#import "WNHelloDownloadMsg.h"

NS_ASSUME_NONNULL_BEGIN

//42/worker/send,["event-message",{"messageID":"MWOhLmcEju4wNaBsIuXysyzReYNJaQmJLpza","abfjksdf":"3223[2022-03-25 18:09:37.979]","messageContent":"哈哈哈哈哈哈","event":"test-send"}]
@interface WNHelloDataMsg : WNHelloDownloadMsg

///< 消息内容
@property (nonatomic, copy) NSString *messageContent;

@end

NS_ASSUME_NONNULL_END
