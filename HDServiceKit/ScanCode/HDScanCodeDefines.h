//
//  HDScanCodeDefines.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/19.
//

#ifndef HDScanCodeDefines_h
#define HDScanCodeDefines_h

typedef NS_ENUM(NSInteger, HDCodeScannerType) {
    HDCodeScannerTypeAll = 0,
    HDCodeScannerTypeQRCode,
    HDCodeScannerTypeBarcode,
};

/**
 扫描完成的回调
 @param scanString 扫描出的字符串
 */
typedef void (^HDScanCodeResultBlock)(NSString *_Nullable scanString);

#endif /* HDScanCodeDefines_h */
