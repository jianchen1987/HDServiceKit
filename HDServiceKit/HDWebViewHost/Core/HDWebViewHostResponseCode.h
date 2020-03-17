//
//  HDWebViewHostResponseCode.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/17.
//

#ifndef HDWebViewHostResponseCode_h
#define HDWebViewHostResponseCode_h

#define kCode(code) [NSString stringWithFormat:@"%zd", code]

typedef NS_ENUM(NSInteger, HDWHRespCode) {
    HDWHRespCodeSuccess = 0,
    HDWHRespCodeCommonFailed = -1,
    HDWHRespCodeIllegalArg = -2,
};

#endif /* HDWebViewHostResponseCode_h */
