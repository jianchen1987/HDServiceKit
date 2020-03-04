//
//  NSString+HDCache.h
//  HDServiceKit
//
//  Created by VanJay on 2019/8/24.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HDCache)

- (NSString *)hdCache_md5;
- (NSString *)hdCache_AESEncryptAndBase64Encode;
- (NSString *)hdCache_AESDecryptAndBase64Decode;

@end
