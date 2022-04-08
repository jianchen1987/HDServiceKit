//
//  WNHelloDownloadMsg.m
//  HDServiceKit
//
//  Created by seeu on 2022/3/25.
//

#import "WNHelloDownloadMsg.h"

@implementation WNHelloDownloadMsg

- (instancetype)initWithMessage:(NSString *)text {
    self = [super initWithMessage:text];
    if (self) {
        self.messageID = [self.data objectForKey:@"messageID"];
        self.messageContent = [self.data objectForKey:@"messageContent"];
    }
    return self;
}

- (NSString *)sqlForQuery {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE message_id = '%@'", [self nameOfTable], self.messageID];
    return sql;
}
- (NSString *)sqlForCreate {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (command TEXT, name_space TEXT, msg_type TEXT, data TEXT, send_time TEXT, message_id TEXT)", [self nameOfTable]];
    return sql;
}
- (NSString *)sqlForInsert {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(command, name_space, msg_type, data, send_time, message_id) VALUES('%@', '%@', '%@', '%@', '%@', '%@')",
                                               [self nameOfTable],
                                               self.command,
                                               self.nameSpace,
                                               self.msgType,
                                               [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.data options:0 error:nil]
                                                                     encoding:NSUTF8StringEncoding],
                                               self.sendTime,
                                               self.messageID];
    return sql;
}
- (NSString *)sqlForUpdate {
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ set command = '%@', name_space = '%@', msg_type = '%@', data = '%@', send_time = '%@' WHERE message_id = '%@'",
                                               [self nameOfTable],
                                               self.command,
                                               self.nameSpace,
                                               self.msgType,
                                               [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.data options:0 error:nil]
                                                                     encoding:NSUTF8StringEncoding],
                                               self.sendTime,
                                               self.messageID];
    return sql;
}

- (NSString *)sqlForDelete {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@  WHERE message_id = '%@'",
                                               [self nameOfTable],
                                               self.messageID];
    return sql;
}

- (NSString *)nameOfTable {
    return NSStringFromClass(self.class);
}

@end
