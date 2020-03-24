//
//  HDRSACipherViewController.m
//  HDServiceKit_Example
//
//  Created by VanJay on 2020/3/24.
//  Copyright © 2020 wangwanjie. All rights reserved.
//

#import "HDRSACipherViewController.h"
#import "RSACipher.h"

@interface HDRSACipherViewController ()
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, copy) NSString *publickey;     // 公钥
@property (nonatomic, copy) NSString *privateKey;    // 私钥
@property (nonatomic, strong) UITextView *textView;  // 显示
@end

@implementation HDRSACipherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView = [[UITextView alloc] init];

    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:self.textView];

    self.textView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:@[
        [self.textView.topAnchor constraintEqualToAnchor:self.hd_navigationBar.bottomAnchor],
        [self.textView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        [self.textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.textView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
    self.userPassword = @"qweASD!@#123456";  // 测试用密码
    [self initValues];                       // 初始化公私钥
    [self testRSAEncrypt];                   // 测试 RSA 加解密
}

- (void)testRSAEncrypt {
    // RSA 加密
    NSString *encryptStr = [RSACipher encrypt:self.userPassword publicKey:self.publickey];
    // RSA 解密
    NSString *decryptStr = [RSACipher decrypt:encryptStr privateKey:self.privateKey];

    NSMutableString *mStr = [NSMutableString stringWithString:self.textView.text];
    [mStr appendFormat:@"\nRSA公钥：\n%@\nRSA私钥：\n%@\nRSA加密密文：\n%@\nRSA解密结果：\n%@", self.publickey, self.privateKey, encryptStr, decryptStr];
    self.textView.text = mStr;

    // 测试 der p12 标准文件格式秘钥加解密
    NSString *derPubKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_1024_public_key.der" ofType:nil];
    NSString *p12PrivKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_1024_private_key.p12" ofType:nil];
    NSString *enWithDer = [RSACipher encrypt:self.userPassword keyFilePath:derPubKeyPath];
    HDLog(@"1024 位 Der 格式公钥加密结果：\n%@", enWithDer);
    NSString *deWithP12 = [RSACipher decrypt:enWithDer keyFilePath:p12PrivKeyPath filePwd:nil];
    HDLog(@"1024 位 p12 格式私钥解密结果：\n%@", deWithP12);
    /**
     * 测试 PEM 文本文件格式秘钥加解密，若 pem 私钥不是 pkcs8 格式，需要转为 pks8 格式
     * openssl pkcs8 -topk8 -inform PEM -in rsa_private_key.pem -outform PEM -nocrypt > rsa_private_key_pkcs8.pem
     */
    NSString *g1024PubKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_1024_public_key.pem" ofType:nil];
    NSString *g1024PrivKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_1024_private_key_pkcs8.pem" ofType:nil];
    NSString *g2048PubKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_2048_public_key.pem" ofType:nil];
    NSString *g2048PrivKeyPath = [[NSBundle mainBundle] pathForResource:@"rsa_2048_private_key_pkcs8.pem" ofType:nil];
    NSString *enWith1024Key = [RSACipher encrypt:self.userPassword keyFilePath:g1024PubKeyPath];
    HDLog(@"1024 位 PEM 格式公钥加密结果：\n%@", enWith1024Key);
    NSString *deWith1024Key = [RSACipher decrypt:enWith1024Key keyFilePath:g1024PrivKeyPath filePwd:nil];
    HDLog(@"1024 位 PEM 格式私钥解密结果：\n%@", deWith1024Key);
    NSString *enWith2048Key = [RSACipher encrypt:self.userPassword keyFilePath:g2048PubKeyPath];
    HDLog(@"2048 位 PEM 格式公钥加密结果：\n%@", enWith2048Key);
    NSString *deWith2048Key = [RSACipher decrypt:enWith2048Key keyFilePath:g2048PrivKeyPath filePwd:nil];
    HDLog(@"2048 位 PEM 格式私钥解密结果：\n%@", deWith2048Key);
}

- (void)initValues {
    /*
     * 在线获取任意的公钥私钥字符串http://www.bm8.com.cn/webtool/rsa/
     * 注意：由于公钥私钥里面含有`/+=\n`等特殊字符串
     * 网络传输过程中导致转义，进而导致加密解密不成功，
     * 解决办法是传输前进行 URL 特殊符号编码解码(URLEncode 百分号转义)
     */
    self.publickey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTbZ6cNH9PgdF60aQKveLz3FTalyzHQwbp601y77SzmGHX3F5NoVUZbdK7UMdoCLK4FBziTewYD9DWvAErXZo9BFuI96bAop8wfl1VkZyyHTcznxNJFGSQd/B70/ExMgMBpEwkAAdyUqIjIdVGh1FQK/4acwS39YXwbS+IlHsPSQIDAQAB";
    // 私钥
    self.privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBANNtnpw0f0+B0XrRpAq94vPcVNqXLMdDBunrTXLvtLOYYdfcXk2hVRlt0rtQx2gIsrgUHOJN7BgP0Na8AStdmj0EW4j3psCinzB+XVWRnLIdNzOfE0kUZJB38HvT8TEyAwGkTCQAB3JSoiMh1UaHUVAr/hpzBLf1hfBtL4iUew9JAgMBAAECgYA1tGeQmAkqofga8XtwuxEWDoaDS9k0+EKeUoXGxzqoT/GyiihuIafjILFhoUA1ndf/yCQaG973sbTDhtfpMwqFNQq13+JAownslTjWgr7Hwf7qplYW92R7CU0v7wFfjqm1t/2FKU9JkHfaHfb7qqESMIbO/VMjER9o4tEx58uXDQJBAO0O4lnWDVjr1gN02cqvxPOtTY6DgFbQDeaAZF8obb6XqvCqGW/AVms3Bh8nVlUwdQ2K/xte8tHxjW9FtBQTLd8CQQDkUncO35gAqUF9Bhsdzrs7nO1J3VjLrM0ITrepqjqtVEvdXZc+1/UrkWVaIigWAXjQCVfmQzScdbznhYXPz5fXAkEAgB3KMRkhL4yNpmKRjhw+ih+ASeRCCSj6Sjfbhx4XaakYZmbXxnChg+JB+bZNz06YBFC5nLZM7y/n61o1f5/56wJBALw+ZVzE6ly5L34114uG04W9x0HcFgau7MiJphFjgUdAtd/H9xfgE4odMRPUD3q9Me9LlMYK6MiKpfm4c2+3dzcCQQC8y37NPgpNEkd9smMwPpSEjPW41aMlfcKvP4Da3z7G5bGlmuICrva9YDAiaAyDGGCK8LxC8K6HpKrFgYrXkRtt";

    // ----------------URL编码解码，解决特殊符号问题----------------
    // 服务器传输过来的公钥字符串可能是这样的
    NSString *RSAPublickKeyFromServer = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDTbZ6cNH9PgdF60aQKveLz3FTalyzHQwbp601y77SzmGHX3F5NoVUZbdK7UMdoCLK4FBziTewYD9DWvAErXZo9BFuI96bAop8wfl1VkZyyHTcznxNJFGSQd%2FB70%2FExMgMBpEwkAAdyUqIjIdVGh1FQK%2F4acwS39YXwbS%2BIlHsPSQIDAQAB";
    // RSAPublickKeyFromServer URLDecode解码后应该和 publickey 相同
    NSString *urlDecodePublicKey = RSAPublickKeyFromServer.stringByRemovingPercentEncoding;
    if ([urlDecodePublicKey isEqualToString:self.publickey]) {
        HDLog(@"解码后和标准公钥一致");
    } else {
        HDLog(@"解码后和标准公钥不一致");
    }
    // URLEncode，除数字字母外的符号都进行 URLEncode
    NSString *urlEncodePublicKey = [self.publickey stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
    if ([urlEncodePublicKey isEqualToString:RSAPublickKeyFromServer]) {
        HDLog(@"编码后和服务器传过来的一致");
    } else {
        HDLog(@"编码后和服务器传过来的不一致");
    }
}

@end
