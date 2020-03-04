//
//  NSJSONSerialization+HDCache.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "NSJSONSerialization+HDCache.h"

@implementation NSJSONSerialization (HDCache)

+ (NSString *)hdCache_stringWithJSONObject:(id)obj
                                   options:(NSJSONWritingOptions)opt
                                     error:(NSError **)error {
    NSData *JSONData = [self dataWithJSONObject:obj options:opt error:error];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData
                                                 encoding:NSUTF8StringEncoding];
    return JSONString;
}

+ (id)hdCache_objectWithJSONString:(NSString *)string
                           options:(NSJSONReadingOptions)opt
                             error:(NSError **)error {
    if (!string.length)
        return nil;
    NSData *JSONData = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:JSONData
                                           options:opt
                                             error:error];
}

@end
