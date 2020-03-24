//
//  HDImageCompressTool.h
//  HDServiceKit
//
//  Created by VanJay on 2020/2/25.
//  Copyright © 2020 chaos network technology. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^HDCompressedImageBlock)(NSData *imageData);

@interface HDImageCompressTool : NSObject

/**
 内存处理，循环压缩处理，图片处理过程中内存不会爆增

 @param image 原始图片
 @param imageKB 限制最终的文件大小
 @param block 处理之后的数据返回，data类型
 */
+ (void)compressedImage:(UIImage *)image imageKB:(CGFloat)imageKB imageBlock:(HDCompressedImageBlock)block;

/**
 图片压缩（针对内存爆表出现的压缩失真分层问题的使用工具）

 @param orignalImage 原始图片
 @param imageKB 最终限制
 @param block 处理之后的数据返回，data类型
 */
+ (void)resetSizeOfImage:(UIImage *)orignalImage imageKB:(CGFloat)imageKB imageBlock:(HDCompressedImageBlock)block;
@end

NS_ASSUME_NONNULL_END
