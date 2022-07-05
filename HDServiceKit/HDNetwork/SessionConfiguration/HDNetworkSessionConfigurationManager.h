//
//  HDNetworkSessionConfigurationManager.h
//  HDServiceKit
//
//  Created by Tia on 2022/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HDNetworkSessionConfigurationManager : NSObject

@property (nonatomic, readonly, strong) NSURLSessionConfiguration *defaultSessionConfiguration;

+ (instancetype)sharedManager;

#pragma mark - 自定义 URLProtocol
/**
 注册自定义的 URLProtocol
 
 @param protocolClass 自定义的NSURLProtocol子类
 */
- (void)addCustomURLProtocolClass:(Class)protocolClass;

@end

NS_ASSUME_NONNULL_END
