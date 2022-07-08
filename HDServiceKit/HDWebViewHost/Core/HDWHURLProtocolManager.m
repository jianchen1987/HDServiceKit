//
//  HDWHURLProtocolManager.m
//  HDServiceKit-HDWebViewHostCoreResources
//
//  Created by Tia on 2022/7/8.
//

#import "HDWHURLProtocolManager.h"
#import "NSURLProtocol+HDWebViewHost.h"

@interface HDWHURLProtocolManager ()

@property (nonatomic, strong) NSMutableArray *schemeList;

@property (nonatomic, strong) Class protocolClass;

@end

@implementation HDWHURLProtocolManager

+ (instancetype)sharedManager {
    static HDWHURLProtocolManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark public methods
- (void)hd_addCustomSchemeList:(NSArray<NSString *> *)schemeList protocolClass:(Class)protocolClass {
    self.schemeList = [schemeList mutableCopy];
    self.protocolClass = protocolClass;
}

- (void)hd_registerSchemeAndProtocol {
    if (!self.protocolClass) return;
    [NSURLProtocol hd_registerSchemeList:self.schemeList protocolClass:self.protocolClass];
}

- (void)hd_unregisterSchemeAndProtocol {
    if (!self.protocolClass) return;
    [NSURLProtocol hd_unregisterSchemeList:self.schemeList protocolClass:self.protocolClass];
}

#pragma mark getter
- (Class)currentProtocolClass {
    NSString *str = [NSStringFromClass(self.protocolClass) mutableCopy];
    return NSClassFromString(str);
}

- (NSArray *)currentSchemeList {
    return [self.schemeList mutableCopy];
}

#pragma mark - lazy load
- (NSMutableArray *)schemeList {
    if (!_schemeList) {
        _schemeList = NSMutableArray.new;
    }
    return _schemeList;
}

@end
