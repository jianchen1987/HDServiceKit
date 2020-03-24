//
//  RSACipher.h
//  HDServiceKit
//
//  Created by VanJay on 03/23/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSACipher : NSObject

/// RSA 字符串公钥加密
/// @param plaintext 明文，待加密的字符串
/// @param pubKey 公钥字符串
+ (NSString *)encrypt:(NSString *)plaintext publicKey:(NSString *)pubKey;

/// RSA 公钥文件加密
/// @param plaintext plaintext 明文，待加密的字符串
/// @param path 公钥文件路径，p12或pem格式
+ (NSString *)encrypt:(NSString *)plaintext keyFilePath:(NSString *)path;

/// RSA 私钥字符串解密
/// @param ciphertext 密文，需要解密的字符串
/// @param privKey 私钥字符串
+ (NSString *)decrypt:(NSString *)ciphertext privateKey:(NSString *)privKey;

/**
 * -------RSA 私钥文件解密-------
 @param ciphertext 密文，需要解密的字符串
 @param path 私钥文件路径，p12或pem格式(pem私钥需为pcks8格式)
 @param pwd 私钥文件的密码
 @return 明文，解密后的字符串
 */

/// RSA 私钥文件解密
/// @param ciphertext 密文，需要解密的字符串
/// @param path 私钥文件路径，p12或pem格式(pem私钥需为pcks8格式)
/// @param pwd 私钥文件的密码
+ (NSString *)decrypt:(NSString *)ciphertext keyFilePath:(NSString *)path filePwd:(NSString *)pwd;

@end
