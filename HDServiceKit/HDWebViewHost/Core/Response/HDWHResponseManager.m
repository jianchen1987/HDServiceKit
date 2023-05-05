//
//  HDWHResponseManager.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHResponseManager.h"
#import "HDFileUtil.h"
#import "HDWHDebugResponse.h"
#import <pthread.h>

@interface HDWHResponseManager ()

// 以下是注册 response 使用的属性

/**
 自定义response类
 */
@property (nonatomic, strong, readwrite) NSMutableArray *customResponseClasses;
/**
 response类的 实例的缓存。
 */
@property (nonatomic, strong) NSMutableDictionary *responseClassObjs;

@end

@implementation HDWHResponseManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static HDWHResponseManager *kResponeManger = nil;
    dispatch_once(&onceToken, ^{
        kResponeManger = [HDWHResponseManager new];

        kResponeManger.responseClassObjs = [NSMutableDictionary dictionaryWithCapacity:10];
        kResponeManger.customResponseClasses = [NSMutableArray arrayWithCapacity:10];

        // 静态注册 可响应的类
        NSArray<NSString *> *responseClassNames = @[
            @"HDWHNavigationResponse",
            @"HDWHNavigationBarResponse",
            @"HDWHHudActionResponse",
            @"HDWHWebViewConfigResponse",
            @"HDWHSystemCapabilityResponse",
            @"HDWHCapacityResponse",
#ifdef HDWH_DEBUG
            @"HDWHDebugResponse",
#endif
            @"HDWHAppLoggerResponse"
        ];
        [responseClassNames enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [kResponeManger.customResponseClasses addObject:NSClassFromString(obj)];
        }];

        // 删除旧的测试用例文件
#ifdef HDWH_DEBUG
        NSString *file = [[DocumentsPath stringByAppendingPathComponent:kWebViewHostDBDir] stringByAppendingPathComponent:kWebViewHostTestCaseFileName];
        if ([HDFileUtil isFileExistedFilePath:file]) {
            [HDFileUtil removeFileOrDirectory:file];
        }
#endif
        //跟踪webViewHost销毁时，清除缓存记录
        [NSNotificationCenter.defaultCenter addObserver:kResponeManger selector:@selector(webViewHostDealloc:) name:@"kNotificationNameWebViewHostDealloc" object:nil];
        
    });

    return kResponeManger;
}

#pragma mark - public
- (NSString *)actionSignature:(NSString *)action withParam:(BOOL)hasParamDict withCallback:(BOOL)hasCallback {
    return [NSString stringWithFormat:@"%@%@%@", action, (hasParamDict ? @"_" : @""), (hasCallback ? @"$" : @"")];
}

- (void)addCustomResponse:(Class<HDWebViewHostProtocol>)cls {
    if (cls) {
        [self.customResponseClasses addObject:cls];
    }
}

- (id<HDWebViewHostProtocol>)responseForActionSignature:(NSString *)signature withWebViewHost:(HDWebViewHostViewController *_Nonnull)webViewHost {
    if (self.customResponseClasses.count == 0) {
        return nil;
    }

    id<HDWebViewHostProtocol> vc = nil;
    NSMutableDictionary *mDic = nil;
    
    // 逆序遍历，让后添加的 Response 能够覆盖内置的方法；
    for (NSInteger i = self.customResponseClasses.count - 1; i >= 0; i--) {
        Class responseClass = [self.customResponseClasses objectAtIndex:i];
        if ([responseClass isSupportedActionSignature:signature]) {
            
            NSString *key = NSStringFromClass(responseClass);
            // 先判断是否可以响应，再决定初始化。
            if (webViewHost) {
                //判断有没有当前vc的缓存
                NSString *mDicKey = [NSString stringWithFormat:@"%p",webViewHost];
                
                mDic = [self.responseClassObjs objectForKey:mDicKey];
                if(mDic) { //有缓存
                    if([mDic objectForKey:key]) { //缓存有这个responseClass;
                        vc = [mDic objectForKey:key];
                    }else{ //缓存没有这个responseClass;
                        vc = [[responseClass alloc] initWithWebViewHost:webViewHost];
                        [mDic setObject:vc forKey:key];
                        [self.responseClassObjs setObject:mDic forKey:mDicKey];
                    }
                }else{ //没缓存
                    mDic = NSMutableDictionary.new;
                    vc = [[responseClass alloc] initWithWebViewHost:webViewHost];
                    [mDic setObject:vc forKey:key];
                    [self.responseClassObjs setObject:mDic forKey:mDicKey];
                }
                
            } else {
                vc = [responseClass new];
            }

            break;
        }
    }

    return vc;
}

- (Class)responseForActionSignature:(NSString *)signature {
    // 逆序遍历，让后添加的 Response 能够覆盖内置的方法；
    Class r = nil;
    for (NSInteger i = self.customResponseClasses.count - 1; i >= 0; i--) {
        Class responseClass = [self.customResponseClasses objectAtIndex:i];
        if ([responseClass isSupportedActionSignature:signature]) {
            r = responseClass;
            break;
        }
    }

    return r;
}

#ifdef HDWH_DEBUG
static NSMutableDictionary *kAllResponseMethods = nil;
static pthread_mutex_t lock;
- (NSDictionary *)allResponseMethods {
    pthread_mutex_init(&lock, NULL);
    pthread_mutex_lock(&lock);
    if (kAllResponseMethods) {
        pthread_mutex_unlock(&lock);
        return kAllResponseMethods;
    }

    kAllResponseMethods = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSInteger i = 0; i < self.customResponseClasses.count; i++) {
        Class responseClass = [self.customResponseClasses objectAtIndex:i];
        NSMutableArray *methods = [NSMutableArray arrayWithCapacity:10];
        [[responseClass supportActionList] enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
            if ([obj integerValue] > 0) {
                [methods addObject:key];
            }
        }];

        if (methods.count > 0) {
            [kAllResponseMethods setValue:methods forKey:NSStringFromClass(responseClass)];
        }
    }

    pthread_mutex_unlock(&lock);
    return kAllResponseMethods;
}

#endif

#pragma mark - Notification
//处理webhost销毁后，清理缓存
- (void)webViewHostDealloc:(NSNotification *)noti {
    NSString *mDicKey = [NSString stringWithFormat:@"%p",noti.object];
    [self.responseClassObjs removeObjectForKey:mDicKey];
}

- (void)dealloc {
    // 清理 response
    [self.responseClassObjs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id _Nonnull obj, BOOL *_Nonnull stop) {
        obj = nil;
    }];
    [self.responseClassObjs removeAllObjects];
    self.responseClassObjs = nil;

#ifdef HDWH_DEBUG
    kAllResponseMethods = nil;
#endif
}
@end
