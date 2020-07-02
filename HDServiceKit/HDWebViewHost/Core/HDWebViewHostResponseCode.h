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
    HDWHRespCodeSuccess = 0,           ///< 成功
    HDWHRespCodeCommonFailed = -1,     ///< 通用失败
    HDWHRespCodeIllegalArg = -2,       ///< 参数不合法
    HDWHRespCodeUserCancel = -3,       ///< 用户取消操作
    HDWHRespCodeUserRejected = -4,     ///< 用户拒绝授权
    HDWHRespCodeUserNotSignedIn = -5,  ///< 用户未登录
};

#endif /* HDWebViewHostResponseCode_h */
