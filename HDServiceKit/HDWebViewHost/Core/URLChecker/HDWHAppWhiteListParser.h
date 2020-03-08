//
//  HDWHAppWhiteListParser.h
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDWHAppWhiteListParser : NSObject
+ (instancetype)sharedManager;
/**
 *  读取一个文件，解析为一个规则的对象，返回
 *
 *  @param fileContent   文件内容
 *  @return 包括key，value的对象，value是域名字符串的数组。
 */
- (NSDictionary *)parserFileContent:(NSString *)fileContent;

@end
