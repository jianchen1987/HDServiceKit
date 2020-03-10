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
#import "HDWebViewHostViewController+Dispatch.h"
#import "HDWebViewHostViewController.h"
#import "NSBundle+HDWebViewHost.h"

@interface HDWHDebugServerManager () <HDWHDebugViewDelegate>

@property (nonatomic, strong) dispatch_queue_t logQueue;

@property (nonatomic, strong) UIWindow *debugWindow;

@property (nonatomic, strong) HDWHDebugViewController *debugVC;
@property (nonatomic, strong) UIButton *toggleButton;
/**
 记录上次拖动的位移，两者做差值，来计算此次拖动的距离。
 */
@property (nonatomic, assign) CGPoint lastOffset;

@property (nonatomic, assign) BOOL isSyncing;

@end

static dispatch_io_t _logFile_io;
static off_t _log_offset = 0;

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
        [self->_eventLogs addObject:@{ @"type": @".invoke",
                                       @"value": notification.object }];
    });
}

- (void)responseEventOccur:(NSNotification *)notification {
    dispatch_async(_logQueue, ^{
        [self->_eventLogs addObject:@{ @"type": @".on",
                                       @"value": notification.object }];
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
            sam.url = @"debug.webViewHost";
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

// https://stackoverflow.com/questions/11637709/get-the-current-displaying-uiviewcontroller-on-the-screen-in-appdelegate-m/40760970#40760970
- (UIViewController *)visibleViewController {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootViewController = win.rootViewController;
    return [self getVisibleViewControllerFrom:rootViewController];
}

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *)vc)visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *)vc)selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

#pragma mark - public
CGFloat kDebugWinInitWidth = 55.f;
CGFloat kDebugWinInitHeight = 46.f;
#define kOldWindowPostion CGRectMake(HDWH_SCREEN_WIDTH - 60, 150, kDebugWinInitWidth, kDebugWinInitHeight)
- (void)showDebugWindow {
    if (self.debugWindow) {
        return;
    }

    UIWindow *window = [[UIWindow alloc] initWithFrame:kOldWindowPostion];
    window.backgroundColor = [UIColor clearColor];
    window.windowLevel = UIWindowLevelStatusBar + 14;
    window.hidden = NO;
    window.clipsToBounds = YES;
    self.debugWindow = window;
    // 增加显示隐藏按钮， 切换按钮，展开时，隐藏；收起时显示
    UIButton *toggle = [UIButton new];
    NSURL *imageURL = [[NSBundle hd_WebViewHostRemoteDebugResourcesBundle] URLForResource:@"src/logo" withExtension:@"png"];
    UIImage *ico = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
    [toggle setImage:ico forState:UIControlStateNormal];
    [toggle addTarget:self action:@selector(toggleWin:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:toggle];
    self.toggleButton = toggle;

    toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [toggle.topAnchor constraintEqualToAnchor:window.topAnchor constant:0].active = YES;
    [toggle.rightAnchor constraintEqualToAnchor:window.rightAnchor].active = YES;
    [toggle.widthAnchor constraintEqualToConstant:40].active = YES;
    [toggle.heightAnchor constraintEqualToConstant:40].active = YES;
    // 为 window 增加拖拽功能
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragFpsWin:)];  // 创建手势
    window.userInteractionEnabled = YES;
    [window addGestureRecognizer:pan];
}

- (void)handleDragFpsWin:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.lastOffset = CGPointZero;
    }
    // 注意：这里的 offset 是相对于在手势开始之前的位置作为基准，和当前手势做差值得出来的位移
    CGPoint offset = [pan translationInView:self.debugWindow];
    // HDWH_DEBUG(@"drag %@", NSStringFromCGPoint(offset));
    CGRect newFrame = CGRectOffset(self.debugWindow.frame, offset.x - self.lastOffset.x, offset.y - self.lastOffset.y);
    // HDWH_DEBUG(@"drag new %@", NSStringFromCGRect(newFrame));
    self.debugWindow.frame = newFrame;
    self.lastOffset = offset;

    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        self.lastOffset = CGPointZero;
    }
}

#pragma mark - event
- (void)toggleWin:(UIButton *)sender {
    [self expandWindow];
}

- (void)expandWindow {
    if (self.debugVC == nil) {
        HDWHDebugViewController *vc = [[HDWHDebugViewController alloc] init];
        self.debugVC = vc;
        vc.debugViewDelegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.debugWindow.rootViewController = nav;
    }
    self.debugWindow.frame = [[UIScreen mainScreen] bounds];
    [self.debugVC onWindowShow];
    self.toggleButton.hidden = YES;
}

- (void)collapseWindow {
    self.debugWindow.frame = kOldWindowPostion;
    [self.debugVC onWindowHide];
    self.toggleButton.hidden = NO;
    [self.debugWindow bringSubviewToFront:self.toggleButton];
}

#pragma mark - HDWHDebugViewDelegate
- (void)onCloseWindow:(HDWHDebugViewController *)viewController {
    [self collapseWindow];
}

- (void)fetchData:(HDWHDebugViewController *)viewController completion:(void (^)(NSArray<NSString *> *))completion {
    [self parHDWH_DEBUG:completion];
}

#pragma mark - public

- (void)start {
    [self startWithPort:12344 bonjourName:@"hite-mac.local"];
}

- (void)startWithPort:(NSUInteger)port bonjourName:(NSString *)name {
    // Create server
    _webServer = [[GCDWebServer alloc] initWithLogServer:kGCDWebServer_logging_enabled];
    // kGCDWebServerLoggingLevel_Info
    [GCDWebServer setLogLevel:2];

    HDWHLog(@"Document = %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);

    // Add a handler to respond to GET requests on any URL
    typeof(self) __weak weakSelf = self;
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request) {
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

                                  NSString *path = [bundle pathForResource:[NSString stringWithFormat:@"src/%@", filePath] ofType:nil];
                                  NSData *contentData = [NSData dataWithContentsOfFile:path];
                                  if (contentData.length > 0) {
                                      return [GCDWebServerDataResponse responseWithData:contentData contentType:contentType];
                                  }
                                  return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Error </p></body></html>"];
                              }];

    [_webServer addDefaultHandlerForMethod:@"POST"
                              requestClass:[GCDWebServerURLEncodedFormRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerURLEncodedFormRequest *request) {
                                  NSURL *url = request.URL;
                                  NSDictionary __block *result = @{};
                                  typeof(weakSelf) __strong strongSelf = weakSelf;
                                  if ([url.path hasPrefix:@"/react_log.do"]) {
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
                                          result = @{ @"count": @(strongSelf->_eventLogs.count),
                                                      @"logs": logStrs };

                                          [strongSelf->_eventLogs removeAllObjects];
                                      });
                                  } else if ([url.path hasPrefix:@"/command.do"]) {
                                      NSString *action = [request.arguments objectForKey:kWHActionKey];
                                      NSString *param = [request.arguments objectForKey:kWHParamKey] ?: @"";
                                      NSString *callbackKey = [request.arguments objectForKey:kWHCallbackKey] ?: @"";

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
                                  return [GCDWebServerDataResponse responseWithJSONObject:@{ @"code": @"OK",
                                                                                             @"data": result }];
                              }];
    [_webServer startWithPort:port bonjourName:name];
    NSURL *_Nullable serverURL = _webServer.serverURL;
    HDWHLog(@"Visit %@ in your web browser", serverURL);

    if (kGCDWebServer_logging_enabled) {
        if (_logFile_io == nil) {

            NSString *logFile = [[DocumentsPath stringByAppendingPathComponent:kWebViewHostDBDir] stringByAppendingPathComponent:GCDWebServer_accessLogFileName];
            if ([HDFileUtil isFileExistedFilePath:logFile]) {
                // 同时设置读取流对象
                dispatch_queue_t dq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

                _logFile_io = dispatch_io_create_with_path(DISPATCH_IO_RANDOM,
                                                           [logFile UTF8String],  // Convert to C-string
                                                           O_RDWR,                // Open for reading
                                                           0,                     // No extra flags
                                                           dq, ^(int error) {
                                                               // Cleanup code for normal channel operation.
                                                               // Assumes that dispatch_io_close was called elsewhere.
                                                               HDWHLog(@"I am ok ");
                                                           });
            } else {
                HDWHLog(@"日志文件不存在");
            }
        }
    }
}

- (void)parHDWH_DEBUG:(void (^)(NSArray<NSString *> *))completion {
    if (_logFile_io) {
        if (self.isSyncing) {
            return;
        }
        self.isSyncing = YES;

        dispatch_queue_t dq = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_io_read(_logFile_io, _log_offset, SIZE_T_MAX, dq, ^(bool done, dispatch_data_t _Nullable data, int error) {
            if (error == 0) {
                // convert
                const void *buffer = NULL;
                size_t size = 0;
                dispatch_data_t new_data_file = dispatch_data_create_map(data, &buffer, &size);
                if (new_data_file && size == 0) { /* to avoid warning really - since dispatch_data_create_map demands we care about the return arg */
                    self.isSyncing = NO;
                    return;
                }
                _log_offset += size;

                NSData *nsdata = [[NSData alloc] initWithBytes:buffer length:size];
                NSString *line = [[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];

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
                // clean up
                // free(buffer);
            } else if (error != 0) {
                HDWHLog(@"出错了");
            }

            self.isSyncing = NO;
        });
    }
}

- (NSString *)stringDecodeURIComponent:(NSString *)encoded {
    NSString *decoded = [encoded stringByRemovingPercentEncoding];
    // HDWHLog(@"decodedString %@", decoded);
    return decoded;
}

- (void)stop {
    [_webServer stop];
}
@end
