//
//  HDWHResponseManager.h
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostResponse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWHResponseManager : NSObject

/**
 自定义response类
 */
@property (nonatomic, strong, readonly) NSMutableArray *customResponseClasses;

+ (instancetype)defaultManager;

#ifdef HDWH_DEBUG

/**
 获取所有注册的 Response 的接口
 
 @return 返回所有 class 支持的 methods，以 class 为 key。key 对应的数据包含所有这个 class 支持的方法
 */
- (NSDictionary *)allResponseMethods;

#endif
#pragma mark - 自定义 Response 区域
/**
 注册自定义的 Response
 
 @param cls 可以处理响应的子类 class，其符合 HDWebViewHostProtocol
 */
- (void)addCustomResponse:(Class<HDWebViewHostProtocol>)cls;

- (id<HDWebViewHostProtocol>)responseForActionSignature:(NSString *)action withWebViewHost:(HDWebViewHostViewController *_Nonnull)webViewHost;

- (Class)responseForActionSignature:(NSString *)signature;

- (NSString *)actionSignature:(NSString *)action withParam:(BOOL)hasParamDict withCallback:(BOOL)hasCallback;
@end

NS_ASSUME_NONNULL_END
