//
//  WNHelloDownloadMsg.h
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloBaseMsg.h"
#import <HDVendorKit/WNFMDBManager.h>

NS_ASSUME_NONNULL_BEGIN

/// 下行消息
@interface WNHelloDownloadMsg : WNHelloBaseMsg <WNDBManagerProtocol>
///< 消息id
@property (nonatomic, copy) NSString *messageID;
///< 消息内容
@property (nonatomic, strong) NSDictionary *messageContent;

- (NSString *)sqlForQuery;
- (NSString *)sqlForCreate;
- (NSString *)sqlForInsert;
- (NSString *)sqlForUpdate;
- (NSString *)sqlForDelete;
- (NSString *)nameOfTable;

@end

NS_ASSUME_NONNULL_END
