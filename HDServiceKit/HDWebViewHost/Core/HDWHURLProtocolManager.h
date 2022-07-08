//
//  HDWHURLProtocolManager.h
//  HDServiceKit-HDWebViewHostCoreResources
//
//  Created by Tia on 2022/7/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDWHURLProtocolManager : NSObject
/// 当前注入的schemeList
@property (nonatomic, strong, readonly) NSArray *currentSchemeList;
/// 当前注入的ProtocolClass
@property (nonatomic, strong, readonly) Class currentProtocolClass;

+ (instancetype)sharedManager;
/// 注册自定义scheme和nsurlprotocol子类
/// @param schemeList 自定义的scheme数组
/// @param protocolClass nsurlprotocol子类
- (void)hd_addCustomSchemeList:(NSArray<NSString *>*)schemeList protocolClass:(Class)protocolClass;
/// 激活scheme和自定义nsurlprotocol子类
- (void)hd_registerSchemeAndProtocol;
/// 注销scheme和自定义nsurlprotocol子类
- (void)hd_unregisterSchemeAndProtocol;

@end

NS_ASSUME_NONNULL_END
