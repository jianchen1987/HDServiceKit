//
//  NSJSONSerialization+HDCache.h
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (HDCache)

+ (NSString *)hdCache_stringWithJSONObject:(id)obj
                                   options:(NSJSONWritingOptions)opt
                                     error:(NSError **)error;

+ (id)hdCache_objectWithJSONString:(NSString *)string
                           options:(NSJSONReadingOptions)opt
                             error:(NSError **)error;

@end
