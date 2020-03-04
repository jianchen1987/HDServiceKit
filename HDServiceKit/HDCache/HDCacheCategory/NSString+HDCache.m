//
//  NSString+HDCache.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "CommonCrypto/CommonDigest.h"
#import "NSData+HDCache.h"
#import "NSString+HDCache.h"

@implementation NSString (HDCache)

- (NSString *)hdCache_md5 {

    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}

- (NSString *)hdCache_AESEncryptAndBase64Encode {

    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encrypt = [data hdCache_AESEncrypt];
    NSString *secret = [encrypt
        base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return [secret stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

- (NSString *)hdCache_AESDecryptAndBase64Decode {

    NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSData *decrypt = [data hdCache_AESDecrypt];
    NSString *secret = nil;
    if (decrypt)
        secret = [[NSString alloc] initWithData:decrypt
                                       encoding:NSUTF8StringEncoding];
    return secret;
}

@end
