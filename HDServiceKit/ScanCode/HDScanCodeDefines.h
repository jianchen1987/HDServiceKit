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

typedef void (^HDScanCodeResultBlock)(NSString *_Nullable scanString);

typedef void (^HDScanCodeClickedMyQRCodeBlock)(void);

#endif /* HDScanCodeDefines_h */
