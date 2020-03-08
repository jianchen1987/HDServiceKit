//
//  HDWHUtil.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HDWHUtil

static char *base36enc(long long unsigned int value)
{
    char base36[37] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    /* log(2**64) / log(36) = 12.38 => max 13 char + '\0' */
    char buffer[14];
    unsigned int offset = sizeof(buffer);
    
    buffer[--offset] = '\0';
    do {
        buffer[--offset] = base36[value % 36];
    } while (value /= 36);
    
    return strdup(&buffer[offset]);
}

+ (NSString *)traceId
{
    long long hash = [[[[NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()] stringByReplacingOccurrencesOfString:@"." withString:@""] substringFromIndex:4] longLongValue];
    
    char *str = base36enc(hash);
    
    NSString *traceId = [NSString stringWithFormat:@"i%@", [NSString stringWithUTF8String:str]];
    
    return traceId;
}

+ (BOOL)isNetworkUrl:(NSString *)url
{
    return [url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"//"];
}
@end
