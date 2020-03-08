//
//  HDWHAppWhiteListParser.m
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHAppWhiteListParser.h"

@implementation HDWHAppWhiteListParser

+ (instancetype)sharedManager {
    static HDWHAppWhiteListParser *_sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (NSDictionary *)parserFileContent:(NSString *)fileContents {
    NSCharacterSet *newlineCharSet = [NSCharacterSet newlineCharacterSet];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:newlineCharSet];
    // 开始解析
    NSMutableDictionary *tree = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSMutableArray __block *currentList = nil;
    [lines enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj hasPrefix:@"#"]) {
            // 注释
        } else if ([obj hasSuffix:@":"]) {
            // 分组
            NSString *key = [obj substringToIndex:obj.length - 1];
            if ([tree objectForKey:key] == nil) {
                [tree setObject:[[NSMutableArray alloc] initWithCapacity:9] forKey:key];
            }
            currentList = [tree objectForKey:key];
        } else if (obj.length > 0) {
            if (currentList) {
                // 将.号转化为\.
                [currentList addObject:obj];
            } else {
                // 没有分组的被丢弃
                NSLog(@" %@ was discard!", obj);
            }
        }
    }];

    return tree;
}

@end
