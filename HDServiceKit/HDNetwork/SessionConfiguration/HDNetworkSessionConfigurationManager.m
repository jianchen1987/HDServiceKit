//
//  HDNetworkSessionConfigurationManager.m
//  HDServiceKit
//
//  Created by Tia on 2022/7/5.
//

#import "HDNetworkSessionConfigurationManager.h"
#import <HDKitCore/HDLog.h>
#import <objc/runtime.h>

@interface HDNetworkSessionConfigurationManager ()

@property (nonatomic, strong) NSURLSessionConfiguration *defaultSessionConfiguration;

@property (nonatomic, strong) NSMutableArray *protocols;

@end

@implementation HDNetworkSessionConfigurationManager

+ (instancetype)sharedManager {
    static HDNetworkSessionConfigurationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSURLSessionConfiguration *)defaultSessionConfiguration {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (self.protocols.count) {
        configuration.protocolClasses = [self.protocols mutableCopy];
    }
    return configuration;
}

- (void)addCustomURLProtocolClass:(Class)protocolClass {
    if (!protocolClass) return;
    //是否存在该类
    if (![NSStringFromClass(protocolClass) length]) return;
    //是否为NSURLProtocol子类
    if (![protocolClass isKindOfClass:object_getClass(NSURLProtocol.class)]) return;
    
    [self.protocols addObject:protocolClass];
}

#pragma mark - lazy load
- (NSMutableArray *)protocols {
    if (!_protocols) {
        _protocols = NSMutableArray.new;
    }
    return _protocols;
}

@end
