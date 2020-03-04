//
//  NSData+HDCache.m
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDCacheManager.h"
#import "NSData+HDCache.h"
#import <CommonCrypto/CommonCryptor.h>

static const unsigned char HDCache_AES_IV[] = {
    0x54, 0x43, 0x4D, 0x6F, 0x62, 0x69, 0x6C, 0x65,
    0x5B, 0x41, 0x45, 0x53, 0x5F, 0x49, 0x56, 0x5D};
NSString *const HDCachePublicAESKey = @"HDCache.vipay";
NSString *const HDCachePrivateAESKey = @"HDCachePrivateAESKey";
NSString *const HDCachePrivateAESNameSpace = @"com.vipay.cache.document";

@implementation NSData (HDCache)

- (NSString *)hdCache_AESKey {
    HDCacheManager *cacheManager =
        [[HDCacheManager alloc] initWithNameSpace:HDCachePrivateAESNameSpace];
    NSString *key = [cacheManager objectForKey:HDCachePrivateAESKey];
    return key ?: HDCachePublicAESKey;
}

- (NSData *)hdCache_AESEncrypt {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [self.hdCache_AESKey getCString:keyPtr
                          maxLength:sizeof(keyPtr)
                           encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
        kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode,
        keyPtr, kCCBlockSizeAES128,
        [[NSData dataWithBytes:HDCache_AES_IV
                        length:sizeof(HDCache_AES_IV)] bytes],
        [self bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

- (NSData *)hdCache_AESDecrypt {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [self.hdCache_AESKey getCString:keyPtr
                          maxLength:sizeof(keyPtr)
                           encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(
        kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode,
        keyPtr, kCCBlockSizeAES128,
        [[NSData dataWithBytes:HDCache_AES_IV
                        length:sizeof(HDCache_AES_IV)] bytes],
        [self bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end
