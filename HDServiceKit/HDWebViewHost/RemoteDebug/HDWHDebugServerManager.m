//
//  HDWHDebugServerManager.m
//  HDWebViewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHDebugServerManager.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerURLEncodedFormRequest.h"
#import "HDFileUtil.h"
#import "HDWHDebugResponse.h"
#import "HDWHDebugViewController.h"
#import "HDWebViewHostAuxiliaryEntryWindow.h"
#import "HDWebViewHostViewController+Dispatch.h"
#import "HDWebViewHostViewController.h"
#import "NSBundle+HDWebViewHost.h"

@interface HDWHDebugServerManager () <HDWHDebugViewDelegate>
@property (nonatomic, strong) HDWebViewHostAuxiliaryEntryWindow *toolWindow;  ///< 工具窗口
@property (nonatomic, strong) dispatch_queue_t logQueue;
@end

BOOL GCDWebServer_logging_enabled = NO;

@implementation HDWHDebugServerManager {
    GCDWebServer *_webServer;
    NSMutableArray *_eventLogs;  // 保存所有 native 向 h5 发送的数据；
}

+ (instancetype)sharedInstance {
    static HDWHDebugServerManager *_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [HDWHDebugServerManager new];
        _manager.logQueue = dispatch_queue_create("com.effetiveobjectivec.syncQueue", DISPATCH_QUEUE_SERIAL);
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _eventLogs = [NSMutableArray arrayWithCapacity:10];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestEventOccur:) name:kWebViewHostInvokeRequestEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseEventOccur:) name:kWebViewHostInvokeResponseEvent object:nil];

        [HDWHDebugResponse setupDebugger];
    }
    return self;
}

- (void)requestEventOccur:(NSNotification *)notification {
    dispatch_async(_logQueue, ^{
        [self->_eventLogs addObject:@{@"type": @".invoke",
                                      @"value": notification.object}];
    });
}

- (void)responseEventOccur:(NSNotification *)notification {
    dispatch_async(_logQueue, ^{
        [self->_eventLogs addObject:@{@"type": @".on",
                                      @"value": notification.object}];
    });
}

#pragma mark - debug
- (void)debugCommand:(NSString *)action param:(NSDictionary *)param callbackKey:(NSString *)callbackKey {
    if (action.length > 0) {
        // 检查当前是否有 HDWebViewHostViewController 正在展示，如果有则使用此界面，如果没有新开一个页面
        UIViewController *topViewController = [self visibleViewController];
        if (![topViewController isKindOfClass:HDWebViewHostViewController.class]) {
            HDWebViewHostViewController *sam = [HDWebViewHostViewController new];
            sam.title = @"HDWebViewHost 容器";
            sam.url = @"https://www.baidu.com";
            if (!topViewController.navigationController) {
                UIWindow *win = [UIApplication sharedApplication].keyWindow;
                win.rootViewController = sam;
                HDWHLog(@"Warning, 连 navigation 都没有？");
            } else {
                [topViewController.navigationController pushViewController:sam animated:YES];
            }
            topViewController = sam;
        }
        [(HDWebViewHostViewController *)topViewController callNative:action parameter:param callbackKey:callbackKey];
    } else {
        HDWHLog(@"irregular action %@", param);
    }
}

#pragma mark - HDWHDebugViewDelegate
- (void)fetchData:(HDWHDebugViewController *)viewController completion:(void (^)(NSArray<NSString *> *))completion {
    [self fetchData:completion];
}

#pragma mark - public
- (void)showDebugWindow {
    _toolWindow = [[HDWebViewHostAuxiliaryEntryWindow alloc] init];
    [_toolWindow makeKeyAndVisible];
}

- (void)hideDebugWindow {
    _toolWindow.hidden = true;
}

- (void)start {
    [self startWithPort:8081 bonjourName:@"chaos-mac.local"];
}

- (void)stop {
    [_webServer stop];
}

- (void)startWithPort:(NSUInteger)port bonjourName:(NSString *)name {
    // Create server
    _webServer = [[GCDWebServer alloc] init];

    if (kGCDWebServer_logging_enabled) {
        [GCDWebServer setLogLevel:2];

        // 创建日志文件，如果有旧的则删掉旧日志文件
        NSString *logFile = [[DocumentsPath stringByAppendingPathComponent:kWebViewHostDBDir] stringByAppendingPathComponent:GCDWebServer_accessLogFileName];

        BOOL isSuccess = true;
        if ([HDFileUtil isFileExistedFilePath:logFile]) {
            isSuccess = [HDFileUtil removeFileOrDirectory:logFile];
        }
        if (isSuccess) {
            [HDFileUtil createFileAtPath:logFile];
        }

        [GCDWebServer setBuiltInLogger:^(int level, NSString *_Nonnull message) {
            HDWHLog(@"%@", message);

            if (level > 0) {
                static const char *levelNames[] = {"DEBUG", "VERBOSE", "INFO", "WARNING", "ERROR"};
                NSString *content = [NSString stringWithFormat:@"[%s] %s\n", levelNames[level], [message UTF8String]];
                NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
                [HDFileUtil appendData:data withPath:logFile];
            }
        }];
        GCDWebServerProcessBlock getProcessBlock = ^GCDWebServerResponse *(GCDWebServerRequest *request) {
            NSBundle *bundle = [NSBundle hd_WebViewHostRemoteDebugResourcesBundle];
            NSString *filePath = request.URL.path;

            if ([filePath isEqualToString:@"/"]) {
                filePath = @"server.html";
            }

            NSString *dataType = @"text";
            NSString *contentType = @"text/plain";
            if ([filePath hasSuffix:@".html"]) {
                contentType = @"text/html; charset=utf-8";
            } else if ([filePath hasSuffix:@".js"]) {
                contentType = @"application/javascript";
            } else if ([filePath hasSuffix:@".css"]) {
                contentType = @"text/css";
            } else if ([filePath hasSuffix:@".png"] || [filePath hasSuffix:@".ico"]) {
                contentType = @"image/png";
                dataType = @"data";
            } else if ([filePath hasSuffix:@".jpg"] || [filePath hasSuffix:@".jpeg"]) {
                contentType = @"image/jpeg";
                dataType = @"data";
            }

            NSString *path = [bundle pathForResource:filePath ofType:nil];
            NSData *contentData = [NSData dataWithContentsOfFile:path];
            if (contentData.length > 0) {
                return [GCDWebServerDataResponse responseWithData:contentData contentType:contentType];
            }
            return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Error </p></body></html>"];
        };

        // Add a handler to respond to GET requests on any URL
        typeof(self) __weak weakSelf = self;
        [_webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                                  processBlock:getProcessBlock];

        GCDWebServerProcessBlock postProcessBlock = ^GCDWebServerResponse *(GCDWebServerURLEncodedFormRequest *request) {
            NSURL *url = request.URL;
            NSDictionary __block *result = @{};
            typeof(weakSelf) __strong strongSelf = weakSelf;
            if ([url.path hasPrefix:@"/access_log.do"]) {
                dispatch_sync(strongSelf->_logQueue, ^{
                    NSMutableArray *logStrs = [NSMutableArray arrayWithCapacity:10];
                    [strongSelf->_eventLogs enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                        NSError *error;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];

                        if (!jsonData) {
                            HDWHLog(@"%s: error: %@", __func__, error.localizedDescription);
                        } else {
                            [logStrs addObject:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
                        }
                    }];
                    result = @{@"count": @(strongSelf->_eventLogs.count),
                               @"logs": logStrs};

                    [strongSelf->_eventLogs removeAllObjects];
                });
            } else if ([url.path hasPrefix:@"/command.do"]) {
                NSString *action = [request.arguments objectForKey:kWHActionKey];
                NSString *param = [request.arguments objectForKey:kWHParamKey];
                NSString *callbackKey = [request.arguments objectForKey:kWHCallbackKey];

                NSDictionary *contentJSON = nil;
                NSError *contentParseError;
                if (param) {
                    param = [self stringDecodeURIComponent:param];
                    contentJSON = [NSJSONSerialization JSONObjectWithData:[param dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&contentParseError];
                }
                if (action.length > 0) {
                    if ([NSThread isMainThread]) {
                        [strongSelf debugCommand:action param:contentJSON callbackKey:callbackKey];
                    } else {
                        HDWHLog(@"switch to main thread");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf debugCommand:action param:contentJSON callbackKey:callbackKey];
                        });
                    }
                } else {
                    HDWHLog(@"command.do arguments error");
                }
            }
            return [GCDWebServerDataResponse responseWithJSONObject:@{@"code": @"OK",
                                                                      @"data": result}];
        };

        [_webServer addDefaultHandlerForMethod:@"POST"
                                  requestClass:[GCDWebServerURLEncodedFormRequest class]
                                  processBlock:postProcessBlock];
        [_webServer startWithPort:port bonjourName:name];
        NSURL *_Nullable serverURL = _webServer.serverURL;
        HDWHLog(@"Visit %@ in your web browser", serverURL);
    }
}

- (void)fetchData:(void (^)(NSArray<NSString *> *))completion {

    NSString *logFile = [[DocumentsPath stringByAppendingPathComponent:kWebViewHostDBDir] stringByAppendingPathComponent:GCDWebServer_accessLogFileName];
    NSData *data = [HDFileUtil readFileData:logFile];

    NSString *line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (completion && line.length > 0) {
        NSArray<NSString *> *lines = [line componentsSeparatedByString:@"\n"];
        NSMutableArray *newLines = [NSMutableArray arrayWithCapacity:10];
        [lines enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.length > 0) {
                [newLines addObject:obj];
            }
        }];
        completion(newLines);
    }
}

#pragma mark - private methods
// https://stackoverflow.com/questions/11637709/get-the-current-displaying-uiviewcontroller-on-the-screen-in-appdelegate-m/40760970#40760970
- (UIViewController *)visibleViewController {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = win.rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *)vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *)vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

- (NSString *)stringDecodeURIComponent:(NSString *)encoded {
    NSString *decoded = [encoded stringByRemovingPercentEncoding];
    return decoded;
}
@end
