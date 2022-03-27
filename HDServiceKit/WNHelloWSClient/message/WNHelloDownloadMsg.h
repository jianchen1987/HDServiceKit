//
//  WNHelloDownloadMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloBaseMsg.h"

NS_ASSUME_NONNULL_BEGIN

/// 下行消息
@interface WNHelloDownloadMsg : WNHelloBaseMsg
///< 消息id
@property (nonatomic, copy) NSString *messageID;
@end

NS_ASSUME_NONNULL_END
