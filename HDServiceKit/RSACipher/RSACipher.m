//
//  RSACipher.m
//  HDServiceKit
//
//  Created by VanJay on 03/23/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "RSACipher.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation RSACipher

static NSString *base64_encode_data(NSData *data) {
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

static NSData *base64_decode(NSString *str) {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

#pragma mark - public methods
+ (NSString *)encrypt:(NSString *)plaintext publicKey:(NSString *)pubKey {
    if (plaintext.length == 0 || pubKey.length == 0) {
        return nil;
    }
    NSData *data = [self encryptData:[plaintext dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    NSString *ret = base64_encode_data(data);
    return ret;
}

+ (NSString *)encrypt:(NSString *)plaintext keyFilePath:(NSString *)path {
    if (plaintext.length == 0 || path.length == 0) {
        return nil;
    }
    NSString *result = nil;
    if ([path hasSuffix:@".pem"]) {
        NSString *pubKey = [self readPubKeyFromPem:path];
        NSData *data = [self encryptData:[plaintext dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
        result = base64_encode_data(data);
    } else {
        result = [self encryptString:plaintext publicKeyRef:[self getPublicKeyRefWithContentsOfFile:path]];
    }
    return result;
}

+ (NSString * _Nullable)decrypt:(NSString * _Nonnull)ciphertext privateKey:(NSString * _Nonnull)privKey tag:(NSString *_Nonnull)tag {
    if (ciphertext.length == 0 || privKey.length == 0) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:NSDataBase64DecodingIgnoreUnknownCharacters];
    data = [self decryptData:data privateKey:privKey tag:tag];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSString * _Nullable)decrypt:(NSString * _Nonnull)ciphertext keyFilePath:(NSString * _Nonnull)path filePwd:(NSString * _Nonnull)pwd tag:(NSString *_Nonnull)tag {
    if (ciphertext.length == 0 || path.length == 0) {
        return nil;
    }
    if (!pwd) pwd = @"";

    NSString *result = nil;
    if ([path hasSuffix:@".pem"]) {
        NSString *privKey = [self readPrivKeyFromPem:path];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:NSDataBase64DecodingIgnoreUnknownCharacters];
        data = [self decryptData:data privateKey:privKey tag:tag];
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        result = [self decryptString:ciphertext privateKeyRef:[self getPrivateKeyRefWithContentsOfFile:path password:pwd]];
    }
    return result;
}

+ (NSString * _Nullable)signText:(NSString * _Nonnull)plaintext privateKey:(NSString * _Nonnull)privKey tag:(NSString * _Nonnull)tag {
    if (plaintext.length == 0 || privKey.length == 0 || tag.length == 0) {
        return nil;
    }
    NSData *data = [self signData:[plaintext dataUsingEncoding:NSUTF8StringEncoding] privateKey:privKey tag:tag];
    NSString *ret = base64_encode_data(data);
    return ret;
}

#pragma mark - private methods
+ (NSString *)readPubKeyFromPem:(NSString *)filePath {
    NSString *pemStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (pemStr.length == 0) {
        return nil;
    }
    NSString *header = @"-----BEGIN PUBLIC KEY-----";
    NSString *footer = @"-----END PUBLIC KEY-----";
    pemStr = [pemStr stringByReplacingOccurrencesOfString:header withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:footer withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pemStr;
}

+ (NSString *)readPrivKeyFromPem:(NSString *)filePath {
    NSString *pemStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (pemStr.length == 0) {
        return nil;
    }
    NSString *header = @"-----BEGIN RSA PRIVATE KEY-----";
    NSString *footer = @"-----END RSA PRIVATE KEY-----";
    NSString *header_pkcs8 = @"-----BEGIN PRIVATE KEY-----";
    NSString *footer_pkcs8 = @"-----END PRIVATE KEY-----";
    pemStr = [pemStr stringByReplacingOccurrencesOfString:header withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:footer withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:header_pkcs8 withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:footer_pkcs8 withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    pemStr = [pemStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pemStr;
}

+ (SecKeyRef)getPublicKeyRefWithContentsOfFile:(NSString *)filePath {
    NSData *certData = [NSData dataWithContentsOfFile:filePath];
    if (!certData) {
        return nil;
    }
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (CFDataRef)certData);
    SecKeyRef key = NULL;
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;
    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                SecTrustResultType result;
                if (SecTrustEvaluate(trust, &result) == noErr) {
                    key = SecTrustCopyPublicKey(trust);
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    return key;
}

+ (NSString *)encryptString:(NSString *)str publicKeyRef:(SecKeyRef)publicKeyRef {
    if (![str dataUsingEncoding:NSUTF8StringEncoding]) {
        return nil;
    }
    if (!publicKeyRef) {
        return nil;
    }
    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] withKeyRef:publicKeyRef];
    NSString *ret = base64_encode_data(data);
    return ret;
}

+ (SecKeyRef)getPrivateKeyRefWithContentsOfFile:(NSString *)filePath password:(NSString *)password {
    NSData *p12Data = [NSData dataWithContentsOfFile:filePath];
    if (!p12Data) {
        return nil;
    }
    SecKeyRef privateKeyRef = NULL;
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)p12Data, (__bridge CFDictionaryRef)options, &items);
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr) {
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);

    return privateKeyRef;
}

+ (NSString *)decryptString:(NSString *)str privateKeyRef:(SecKeyRef)privKeyRef {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!privKeyRef) {
        return nil;
    }
    data = [self decryptData:data withKeyRef:privKeyRef];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey {
    if (!data || !pubKey) {
        return nil;
    }
    SecKeyRef keyRef = [self addPublicKey:pubKey];
    if (!keyRef) {
        return nil;
    }
    return [self encryptData:data withKeyRef:keyRef];
}

+ (SecKeyRef)addPublicKey:(NSString *)key {
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e - s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    data = [self stripPublicKeyHeader:data];
    if (!data) {
        return nil;
    }

    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);

    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic
                  forKey:(__bridge id)
                             kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES]
                  forKey:(__bridge id)
                             kSecReturnPersistentRef];

    [publicKey setObject:(__bridge id)kSecAttrAccessibleAlwaysThisDeviceOnly
                  forKey:(__bridge id)kSecAttrAccessible];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key {
    // Skip ASN.1 public key header
    if (d_key == nil) return (nil);

    unsigned long len = [d_key length];
    if (!len) return (nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 0;

    if (c_key[idx++] != 0x30) return (nil);

    if (c_key[idx] > 0x80)
        idx += c_key[idx] - 0x80 + 1;
    else
        idx++;

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
        {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
         0x01, 0x05, 0x00};
    if (memcmp(&c_key[idx], seqiod, 15)) return (nil);

    idx += 15;

    if (c_key[idx++] != 0x03) return (nil);

    if (c_key[idx] > 0x80)
        idx += c_key[idx] - 0x80 + 1;
    else
        idx++;

    if (c_key[idx++] != '\0') return (nil);

    return ([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;

    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }

        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef,
                               kSecPaddingPKCS1,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen);
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        } else {
            [ret appendBytes:outbuf length:outlen];
        }
    }

    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

+ (NSData * _Nullable)decryptData:(NSData * _Nonnull)data privateKey:(NSString * _Nonnull)privKey tag:(NSString *_Nonnull)tag {
    if (!data || !privKey) {
        return nil;
    }
    SecKeyRef keyRef = [self matchRSAKeyWithTag:tag];
    if(!keyRef) {
        keyRef = [self addPrivateKey:privKey tag:tag];
    }
    if (!keyRef) {
        return nil;
    }
    CFAutorelease(keyRef);
    return [self decryptData:data withKeyRef:keyRef];
}

+ (SecKeyRef)matchRSAKeyWithTag:(NSString *_Nonnull)tag {
    //a tag to read/write keychain storage
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *rsaKey = [[NSMutableDictionary alloc] init];
    [rsaKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [rsaKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [rsaKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    [rsaKey setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [rsaKey setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly forKey:(__bridge id)kSecAttrAccessible];
    [rsaKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [rsaKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)rsaKey, (CFTypeRef *)&keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

+ (SecKeyRef)addPrivateKey:(NSString *_Nonnull)key tag:(NSString *_Nonnull)tag {
    NSRange spos = [key rangeOfString:@"-----BEGIN RSA PRIVATE KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END RSA PRIVATE KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e - s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];

    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    data = [self stripPrivateKeyHeader:data];
    if (!data) {
        return nil;
    }

    //a tag to read/write keychain storage
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];

    // Delete any old lingering key with the same tag
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);

    // Add persistent version of the key to system keychain
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id)kSecAttrKeyClassPrivate
                   forKey:(__bridge id)
                              kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES]
                   forKey:(__bridge id)
                              kSecReturnPersistentRef];
    
    [privateKey setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                   forKey:(__bridge id)kSecAttrAccessible];

    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }

    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

+ (NSData * _Nullable)signData:(NSData * _Nonnull)data privateKey:(NSString * _Nonnull)privKey tag:(NSString *_Nonnull)tag {
    if (!data || !privKey || !tag) {
        return nil;
    }
    SecKeyRef keyRef = [self matchRSAKeyWithTag:tag];
    if(!keyRef) {
        keyRef = [self addPrivateKey:privKey tag:tag];
    }
    
    if (!keyRef) {
        return nil;
    }
    CFAutorelease(keyRef);
    return [self signData:data withKeyRef:keyRef];
}

+ (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t *hashBytes = NULL;
    NSData *hash = nil;

    // Malloc a buffer to hold hash.
    hashBytes = malloc(CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t));
    memset((void *)hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);

    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)CC_SHA1_DIGEST_LENGTH];
    if (hashBytes) free(hashBytes);

    return hash;
}

+ (NSData *)signData:(NSData *)data withKeyRef:(SecKeyRef)keyRef {

    NSData *signedHash = nil;

    size_t signedBytesSize = SecKeyGetBlockSize(keyRef);
    uint8_t *signedBytes = malloc(signedBytesSize * sizeof(uint8_t));  // Malloc a buffer to hold signature.
    memset((void *)signedBytes, 0x0, signedBytesSize);

    OSStatus status = SecKeyRawSign(keyRef,
                                kSecPaddingPKCS1SHA1,
                                (const uint8_t *)[[self getHashBytes:data] bytes],
                                CC_SHA1_DIGEST_LENGTH,
                                (uint8_t *)signedBytes,
                                &signedBytesSize);

    if (status != 0) {
        NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
        return nil;
    } else {
        signedHash = [NSData dataWithBytes:(const void *)signedBytes length:(NSUInteger)signedBytesSize];
    }

    if (signedBytes) {
        free(signedBytes);
    }
    
    return signedHash;
}

+ (NSData *)stripPrivateKeyHeader:(NSData *)d_key {
    // Skip ASN.1 private key header
    if (d_key == nil) return (nil);

    unsigned long len = [d_key length];
    if (!len) return (nil);

    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 22;  //magic byte at offset 22

    if (0x04 != c_key[idx++]) return nil;

    //calculate length of the key
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    } else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            //rsa length field longer than buffer
            return nil;
        }
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }

    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

+ (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef {
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;

    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;

    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        //NSLog(@"%d/%d block_size: %d", idx, (int)srclen, (int)block_size);
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }

        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen);
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        } else {
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for (int i = 0; i < outlen; i++) {
                if (outbuf[i] == 0) {
                    if (idxFirstZero < 0) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }

            [ret appendBytes:&outbuf[idxFirstZero + 1] length:idxNextZero - idxFirstZero - 1];
        }
    }

    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

@end
