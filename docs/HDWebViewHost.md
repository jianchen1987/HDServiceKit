# HDWebViewHost 介绍

HDWebViewHost 是一套解决 H5 和 native 协作开发的整体框架和服务

# 原理
往 WKWebView 注入 JavaScript 脚本，使得 window 对象拥有了一些能力，与 web 端约定对应的触发以及接收出口、入口实现互通功能

# 职责介绍

## HDWebViewHost

```
├── Core					核心功能，可独立存在
├── Preloader				预渲染控制器
└── RemoteDebug             本地/远端 debug 
```

## Core
```
Core
├── Category   帮助方法
│   ├── NSBundle+HDWebViewHost.h    包含获取 framework bundle 方法
│   ├── NSBundle+HDWebViewHost.m
│   ├── NSObject+HDWebViewHost.h
│   └── NSObject+HDWebViewHost.m
├── HDWHJSCoreManager.h	暂无实现，将来可用于管理H5、小程序、Flutter 等容器
├── HDWHJSCoreManager.m
├── HDWHSchemeTaskDelegate.h
├── HDWHSchemeTaskDelegate.m
├── HDWebViewHost.h
├── HDWebViewHostEnum.h
├── HDWebViewHostProtocol.h
├── HDWebViewHostResponse.h
├── HDWebViewHostResponse.m
├── HDWebViewHostViewController+Dispatch.h	  h5调用native接口的分发器
├── HDWebViewHostViewController+Dispatch.m
├── HDWebViewHostViewController+Extend.h  对 webview 什么周期有特殊需要的时候，可以继承 HDWebViewHostViewController，并重载相应的方法实现自有逻辑
├── HDWebViewHostViewController+Extend.m
├── HDWebViewHostViewController+Progressor.h 处理顶部进度条
├── HDWebViewHostViewController+Progressor.m
├── HDWebViewHostViewController+Scripts.h   注入脚本相关
├── HDWebViewHostViewController+Scripts.m
├── HDWebViewHostViewController+Timing.h    性能测试相关，暂时只记录时间
├── HDWebViewHostViewController+Timing.m
├── HDWebViewHostViewController+Utils.h    其他扩展函数
├── HDWebViewHostViewController+Utils.m
├── HDWebViewHostViewController.h    核心渲染
├── HDWebViewHostViewController.m
├── HMTLParser    加载本地 html 解析器
│   ├── HTMLNode.h
│   ├── HTMLNode.m
│   ├── HTMLParser.h
│   ├── HTMLParser.m
│   └── README.md
├── Helper    一些与业务无关的工具函数，比如记录某页面的历史滚动位置
│   ├── HDWHScriptMessageDelegate.h
│   ├── HDWHScriptMessageDelegate.m
│   ├── HDWHUtil.h
│   ├── HDWHUtil.m
│   ├── HDWHWebViewScrollPositionManager.h
│   ├── HDWHWebViewScrollPositionManager.m
│   ├── HDWebViewHostCookie.h
│   └── HDWebViewHostCookie.m
├── Intermediate    处理网页内容的调度器
│   ├── HDWHRequestMediate.h
│   └── HDWHRequestMediate.m
├── Resources  资源文件家
│   ├── app-access.txt   白名单，包含 scheme 和 host 白名单，如果都为空则不过滤
│   ├── eval.js  为了替换 self.webView evaluateJavaScript:javaScriptString completionHandler:nil 解决一些历史 bug
│   └── webViewHost_version_1.0.0.js JSSDK
├── Response    为 h5 提供的业务相关的实现
│   ├── HDWHAppLoggerResponse.h
│   ├── HDWHAppLoggerResponse.m
│   ├── HDWHHudActionResponse.h
│   ├── HDWHHudActionResponse.m
│   ├── HDWHDebugResponse.h
│   ├── HDWHDebugResponse.m
│   ├── HDWHNavigationBarResponse.h
│   ├── HDWHNavigationBarResponse.m
│   ├── HDWHNavigationResponse.h
│   ├── HDWHNavigationResponse.m
│   ├── HDWHResponseManager.h
│   └── HDWHResponseManager.m
└── URLChecker    检查器，判断白名单或验证地址有效性
    ├── HDWHAppWhiteListParser.h
    ├── HDWHAppWhiteListParser.m
    ├── HDWHURLChecker.h
    └── HDWHURLChecker.m
```

## Preloader

```
Preloader   预渲染页面，需要时取出
├── ResourcePreloader
│   ├── HDWHSimpleWebViewController.h
│   ├── HDWHSimpleWebViewController.m
│   ├── HDWHWebViewPreLoader.h
│   └── HDWHWebViewPreLoader.m
├── ViewControllerPreRender
│   ├── HDWHViewControllerPreRender.h
│   └── HDWHViewControllerPreRender.m
└── html
    └── preload_resources.html
```

## RemoteDebug

```
RemoteDebug  调试、联调用 
├── GCDWebServer  修改的第三方的 webServer库，加入日志记录功能
│   ├── Core
│   │   ├── GCDWebServer.h
│   │   ├── GCDWebServer.m
│   │   ├── GCDWebServerConnection.h
│   │   ├── GCDWebServerConnection.m
│   │   ├── GCDWebServerFunctions.h
│   │   ├── GCDWebServerFunctions.m
│   │   ├── GCDWebServerHTTPStatusCodes.h
│   │   ├── GCDWebServerPrivate.h
│   │   ├── GCDWebServerRequest.h
│   │   ├── GCDWebServerRequest.m
│   │   ├── GCDWebServerResponse.h
│   │   └── GCDWebServerResponse.m
│   ├── Requests
│   │   ├── GCDWebServerDataRequest.h
│   │   ├── GCDWebServerDataRequest.m
│   │   ├── GCDWebServerFileRequest.h
│   │   ├── GCDWebServerFileRequest.m
│   │   ├── GCDWebServerMultiPartFormRequest.h
│   │   ├── GCDWebServerMultiPartFormRequest.m
│   │   ├── GCDWebServerURLEncodedFormRequest.h
│   │   └── GCDWebServerURLEncodedFormRequest.m
│   └── Responses
│       ├── GCDWebServerDataResponse.h
│       ├── GCDWebServerDataResponse.m
│       ├── GCDWebServerErrorResponse.h
│       ├── GCDWebServerErrorResponse.m
│       ├── GCDWebServerFileResponse.h
│       ├── GCDWebServerFileResponse.m
│       ├── GCDWebServerStreamedResponse.h
│       └── GCDWebServerStreamedResponse.m
├── HDWHDebugServerManager.h  下面几个文件是悬浮按钮和日志页的实现
├── HDWHDebugServerManager.m
├── HDWHDebugViewController.h
├── HDWHDebugViewController.m
├── HDWebViewHostAuxiliaryEntryWindow.h
├── HDWebViewHostAuxiliaryEntryWindow.m
├── HDWebViewHostAuxiliaryMainWindow.h
├── HDWebViewHostAuxiliaryMainWindow.m
└── src    启动本地 server 加载的本地网页目录，会被 webServer 拦截处理响应操作
    ├── components
    │   └── tool-panel.js
    ├── favicon.ico
    ├── images
    │   ├── mobile\ to\ pc.png
    │   └── pc\ to\ mobile.png
    ├── logo.png
    ├── profile
    │   ├── pageTiming.js
    │   ├── pageTiming_for_mac.js
    │   ├── profiler.js
    │   └── profiler_for_mac.js
    ├── renderjson.css
    ├── renderjson.js
    ├── server.css
    ├── server.html
    ├── server.js
    ├── testcase.tmpl
    ├── thirdParty
    │   └── weinreSupport.js
    └── vue.js
```

# 开发新业务

## 新建业务类
继承自 `HDWebViewHostResponse`，需要导入头文件 `#import <HDServiceKit/HDWebViewHostResponse.h>`，实现对应协议

```
+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"method1_$": kHDWHResponseMethodOn,
        @"method2": kHDWHResponseMethodOn,
        @"method3_": kHDWHResponseMethodOn,
    };
}
```

`kHDWHResponseMethodOn` 作用为开关该方法，也可后做他用，不设计为数组是此目的

## 实现对应函数

```
- (void) method2 {
    HDWHLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)method1:(NSDictionary *)dict callback:(NSString *)callback {
    
    NSString *text = [dict objectForKey:@"text"];
    HDWHLog(@"%@ --- %@", NSStringFromSelector(_cmd), text);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    	// 触发回调
        [self fireCallback:callback param:@{@"cbParam": @"你是什么品种的蛤蟆？"}];
    });
}

- (void)method3:(NSDictionary *)dict {
    NSString *text = [dict objectForKey:@"text"];
    HDWHLog(@"%@ -- %@", NSStringFromSelector(_cmd), text);
}
```
对应函数名和参数以及回调请查看 `HDWebViewHostResponse` 的 `handleAction:withParam:callbackKey:`方法

## 编写测试用例
比如为 `method1 ` 添加测试文档，具体使用方法查看 `HDWebViewHostEnum` 文件或者模仿内置的 response 写法

```
// clang-format off
wh_doc_begin(method1_$, "测试 h5 调用原生并且收到回调")
wh_doc_param(text, "字符串，亲之前你要说什么话？")
wh_doc_code(window.webViewHost.invoke('method1', { "text": "送你花花" }, function (p) { alert('收到原生给的回调' + JSON.stringify(p)); });)
wh_doc_code_expect("原生收到调用后2秒回调被触发，h5 收到消息")
wh_doc_end;
// clang-format on
```

启动 webServer 之后，浏览器打开调试页面点击"用例"或者执行命令 `:testcase` 可在客户端查看测试用例界面，一个 App 生命周期内只生成一次测试用例页面，调试界面的所有功能可在帮助下查看，不在文档赘述
