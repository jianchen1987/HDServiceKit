

//
//  HDWHDebugResponse.m
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHDebugResponse.h"
#import "HDFileUtil.h"
#import "HDWHResponseManager.h"
#import "HDWebViewHostViewController+Scripts.h"
#import "HDWebViewHostViewController.h"
#import "NSBundle+HDWebViewHost.h"

// 保存 weinre 注入脚本的地址，方便在加载其它页面时也能自动注入。
static NSString *kLastWeinreScript = nil;
@implementation HDWHDebugResponse
+ (NSDictionary<NSString *, NSString *> *)supportActionList {
    return @{
        @"eval_": kHDWHResponseMethodOn,
        @"list": kHDWHResponseMethodOn,
        @"usage_": kHDWHResponseMethodOn,
        @"testcase": kHDWHResponseMethodOn,
        @"weinre_": kHDWHResponseMethodOn,
        @"timing": kHDWHResponseMethodOn,
        @"console.log_": kHDWHResponseMethodOn,
        @"clearCookie": kHDWHResponseMethodOn
    };
}

+ (BOOL)isDebugAction:(NSString *)action {
    NSArray *allKeys = [self supportActionList].allKeys;
    __block BOOL exist = false;
    [allKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
        key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"$" withString:@""];

        if ([key isEqualToString:action]) {
            exist = true;
            *stop = true;
        }
    }];
    return exist;
}

+ (void)setupDebugger {
#ifdef HDWH_DEBUG
    NSBundle *bundle = [NSBundle hd_WebViewHostRemoteDebugResourcesBundle];

    NSMutableArray<HDWebViewHostCustomJavscript *> *scripts = [NSMutableArray array];
    HDWebViewHostCustomJavscript *script;

    // 记录 window.DocumentEnd 的时间
    script = [HDWebViewHostCustomJavscript customJavscriptWithScript:@"window.DocumentEnd =(new Date()).getTime()" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd key:@"documentEndTime.js"];
    [scripts addObject:script];

    // 记录 DocumentStart 的时间
    script = [HDWebViewHostCustomJavscript customJavscriptWithScript:@"window.DocumentStart = (new Date()).getTime()" injectionTime:WKUserScriptInjectionTimeAtDocumentStart key:@"documentStartTime.js"];
    [scripts addObject:script];

    // 重写 console.log 方法
    script = [HDWebViewHostCustomJavscript customJavscriptWithScript:@"window.__wh_consolelog = console.log; console.log = function(_msg){window.__wh_consolelog(_msg);window.webViewHost.invoke('console.log', {'text': _msg});}" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd key:@"console.log.js"];
    [scripts addObject:script];

    // 记录 readystatechange 的时间
    script = [HDWebViewHostCustomJavscript customJavscriptWithScript:@"document.addEventListener('readystatechange', function (event) {window['readystate_' + document.readyState] = (new Date()).getTime();});" injectionTime:WKUserScriptInjectionTimeAtDocumentStart key:@"readystatechange.js"];
    [scripts addObject:script];

    // 性能测试
    NSURL *profile = [[bundle bundleURL] URLByAppendingPathComponent:@"profile/profiler.js"];
    NSString *profileTxt = [NSString stringWithContentsOfURL:profile encoding:NSUTF8StringEncoding error:nil];
    script = [HDWebViewHostCustomJavscript customJavscriptWithScript:profileTxt injectionTime:WKUserScriptInjectionTimeAtDocumentEnd key:@"profile.js"];
    [scripts addObject:script];

    NSURL *timing = [[bundle bundleURL] URLByAppendingPathComponent:@"profile/pageTiming.js"];
    NSString *timingTxt = [NSString stringWithContentsOfURL:timing encoding:NSUTF8StringEncoding error:nil];
    script = [HDWebViewHostCustomJavscript customJavscriptWithScript:timingTxt injectionTime:WKUserScriptInjectionTimeAtDocumentEnd key:@"timing.js"];
    [scripts addObject:script];
    // 取消注入 debug js
    /*
    [scripts enumerateObjectsUsingBlock:^(HDWebViewHostCustomJavscript *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [HDWebViewHostViewController prepareJavaScript:obj.script when:obj.injectionTime key:obj.key];
    }];
    */
#endif
}

- (BOOL)handleAction:(NSString *)action withParam:(NSDictionary *)paramDict callbackKey:(NSString *)callbackKey {
#ifdef HDWH_DEBUG
    if ([@"eval" isEqualToString:action]) {
        [self.webViewHost evalExpression:[paramDict objectForKey:@"code"]
                              completion:^(id _Nonnull result, NSString *_Nonnull error) {
                                  HDWHLog(@"debug eval 执行结果：%@, error = %@", result, error);
                                  NSDictionary *r = nil;
                                  if (result) {
                                      r = @{
                                          @"result": [NSString stringWithFormat:@"%@", result]
                                      };
                                  } else {
                                      r = @{
                                          @"error": [NSString stringWithFormat:@"%@", error]
                                      };
                                  }
                                  [self fire:@"eval" param:r];
                              }];
    } else if ([@"list" isEqualToString:action]) {
        // 遍历所有的可用接口和注释和测试用例
        [self fire:@"list" param:[[HDWHResponseManager defaultManager] allResponseMethods]];
    } else if ([@"usage" isEqualToString:action]) {
        NSString *signature = [paramDict objectForKey:@"signature"];
        Class webViewHostCls = [[HDWHResponseManager defaultManager] responseForActionSignature:signature];
        SEL targetMethod = wh_doc_selector(signature);
        NSString *funcName = [@"usage." stringByAppendingString:signature];
        if (webViewHostCls && [webViewHostCls respondsToSelector:targetMethod]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSDictionary *doc = [webViewHostCls performSelector:targetMethod withObject:nil];
#pragma clang diagnostic pop

            [self fire:funcName
                 param:doc];
        } else {
            NSString *err = nil;
            if (webViewHostCls) {
                err = [NSString stringWithFormat:@"The doc of method (%@) is not found!", signature];
            } else {
                err = [NSString stringWithFormat:@"The method (%@) doesn't exsit!", signature];
            }
            [self fire:funcName param:@{@"error": err}];
        }
    } else if ([@"testcase" isEqualToString:action]) {
        // 检查是否有文件生成，如果没有则遍历
        NSString *file = [[DocumentsPath stringByAppendingPathComponent:kWebViewHostDBDir] stringByAppendingPathComponent:kWebViewHostTestCaseFileName];
        if (![HDFileUtil isFileExistedFilePath:file]) {
            [self generatorHtml];
        }
        [self.webViewHost loadLocalFile:[NSURL fileURLWithPath:file] domain:kHDWHTestcaseDomain];
        // 支持 或者关闭 weinre 远程调试
    } else if ([@"weinre" isEqualToString:action]) {
        // $ weinre --boundHost 10.242.24.59 --httpPort 9090
        BOOL disabled = [[paramDict objectForKey:@"disabled"] boolValue];
        if (disabled) {
            [self disableWeinreSupport];
        } else {
            kLastWeinreScript = [paramDict objectForKey:@"url"];
            [self enableWeinreSupport];
        }
    } else if ([@"timing" isEqualToString:action]) {
        BOOL mobile = [[paramDict objectForKey:@"mobile"] boolValue];
        if (mobile) {
            [self.webViewHost fire:@"requestToTiming" param:@{}];
        } else {
            [self.webViewHost.webView evaluateJavaScript:@"window.performance.timing.toJSON()"
                                       completionHandler:^(NSDictionary *_Nullable r, NSError *_Nullable error) {
                                           [self fire:@"requestToTiming_on_mac" param:r];
                                       }];
        }
    } else if ([@"clearCookie" isEqualToString:action]) {
        // 清理 WKWebview 的 Cookie，和 NSHTTPCookieStorage 是独立的
        if (@available(iOS 11.0, *)) {
            WKHTTPCookieStore *_Nonnull cookieStorage = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
            [cookieStorage getAllCookies:^(NSArray<NSHTTPCookie *> *_Nonnull cookies) {
                [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *_Nonnull cookie, NSUInteger idx, BOOL *_Nonnull stop) {
                    [cookieStorage deleteCookie:cookie
                              completionHandler:^{
                                  HDWHLog(@"Cookie %@ for %@ deleted successfully", cookie.name, cookie.domain);
                              }];
                }];
                [self.webViewHost fire:@"clearCookieDone" param:@{@"count": @(cookies.count)}];
            }];
        } else {
            WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
            [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                             completionHandler:^(NSArray<WKWebsiteDataRecord *> *__nonnull records) {
                                 for (WKWebsiteDataRecord *record in records) {
                                     [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                               forDataRecords:@[record]
                                                                            completionHandler:^{
                                                                                HDWHLog(@"Cookie for %@ deleted successfully", record.displayName);
                                                                            }];
                                 }
                                 [self.webViewHost fire:@"clearCookieDone" param:@{@"count": @(records.count)}];
                             }];
        }
    } else if ([@"console.log" isEqualToString:action]) {
        // 正常的日志输出时，不需要做特殊处理。
        HDWHLog(@"来自 console.log: %@", paramDict);
        // 因为在 invoke 的时候，已经向 debugger Server 发送过日志数据，已经打印过了
    } else {
        return NO;
    }
    return YES;
#else
    return NO;
#endif
}

// 注入 weinre 文件
- (void)enableWeinreSupport {
    if (kLastWeinreScript.length == 0) {
        return;
    }

    [HDWebViewHostViewController prepareJavaScript:[NSURL URLWithString:kLastWeinreScript] when:WKUserScriptInjectionTimeAtDocumentEnd key:@"weinre.js"];

    [self.webViewHost fire:@"weinre.enable" param:@{@"jsURL": kLastWeinreScript}];
}

- (void)disableWeinreSupport {
    kLastWeinreScript = nil;
    [HDWebViewHostViewController removeJavaScriptForKey:@"weinre.js"];
}

#pragma mark - generate html file
/**
 <fieldset>
 <legend>杂项</legend>
 <ol>
 <li id="funcRow_f_1">
 <script type="text/javascript">
 function f_1(){
 var eleId = 'funcRow_f_1'
 NEJsbridge.call('LocalStorage.setItem', '{"key":"BIA_LS_act_bosslike_num","value":"123"}');
 window.report(true, 'funcRow_f_1')
 }
 </script>
 <a href="javascript:void(0);" onclick="f_1();return false;">LocalStorage.setItem, 将 BIA_LS_act_bosslike_num 的值保存为 123</a>
 <span>无</span><label class="passed">✅</label><label class="failed">❌</label>
 </li>
 </ol>
 </fieldset>

 */
- (BOOL)generatorHtml {

    NSBundle *bundle = [NSBundle hd_WebViewHostRemoteDebugResourcesBundle];
    NSURL *url = [bundle URLForResource:@"testcase" withExtension:@"tmpl"];
    // 获取模板
    NSError *err = nil;
    NSString *template = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    if (template.length > 0 && err == nil) {
        // 解析
        HDWHLog(@"正在解析");
        int funcAutoTestBaseIdx = 0;
        int funcNonAutoTestBaseIdx = 0;  // 不支持自动化测试的函数
        NSArray *allClazz = [HDWHResponseManager defaultManager].customResponseClasses;
        NSMutableArray *docsHtml = [NSMutableArray arrayWithCapacity:4];
        for (Class clazz in allClazz) {
            // debug 的 responseClass 跳过
            if ([NSStringFromClass(clazz) isEqualToString:@"HDWHDebugResponse"]) {
                continue;
            }
            NSDictionary *supportFunc = [clazz supportActionList];
            NSMutableString *html = [NSMutableString stringWithFormat:@"<fieldset><legend>%@</legend><ol>", NSStringFromClass(clazz)];

            for (NSString *func in supportFunc.allKeys) {
                NSInteger ver = [[supportFunc objectForKey:func] integerValue];
                if (ver > 0) {
                    SEL targetMethod = wh_doc_selector(func);
                    if ([clazz respondsToSelector:targetMethod]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        NSDictionary *doc = [clazz performSelector:targetMethod withObject:nil];
#pragma clang diagnostic pop
                        if (doc) {
                            // 这段代码来自 ruby 工程；
                            // js 函数的前缀，f_ 开通的为自动化测试函数， nf_ 开通的为手动验证函数
                            NSString *funcName = @"f_";
                            NSString *descPrefix = @"";
                            int funcBaseIdx = 0;
                            BOOL autoTest = [doc objectForKey:@"autoTest"];
                            if (autoTest) {
                                descPrefix = @"<label class=\"f-manual\">[手动]</label>";
                                funcName = @"nf_";
                                funcNonAutoTestBaseIdx += 1;
                                funcBaseIdx = funcNonAutoTestBaseIdx;
                            } else {
                                funcAutoTestBaseIdx += 1;
                                funcBaseIdx = funcAutoTestBaseIdx;
                            }
                            NSString *fullFunctionName = [funcName stringByAppendingFormat:@"%ld", (long)funcBaseIdx];
                            NSString *itemEleId = [@"funcRow_" stringByAppendingString:fullFunctionName];

                            NSString *alertOrNot = @"";
                            if (![doc objectForKey:@"expectFunc"]) {  // 如果没有 expectFunc 默认成功
                                alertOrNot = [NSString stringWithFormat:@"window.report(true, '%@')", itemEleId];
                            }
                            // 缺少插值运算的字符串拼接，让人头大
                            [html appendFormat:@"<li id=\"%@\">\
                             <script type=\"text/javascript\">\
                             function %@() {\
                                var eleId = '%@';%@; %@;\
                             }\
                             </script>\
                             <a href=\"javascript:void(0);\" onclick=\"%@();\">%@%@, 执行后，%@</a>\
                             <span>%@</span><label class=\"passed\">✅</label><label class=\"failed\">❌</label>\
                             </li>",
                                               itemEleId, fullFunctionName, itemEleId, [doc objectForKey:@"code"], alertOrNot, fullFunctionName, descPrefix, [doc objectForKey:@"name"], [doc objectForKey:@"expect"], [doc objectForKey:@"discuss"]];
                        }
                    }
                } else {
                    HDWHLog(@"The '%@' not activiated", func);
                }
            }
            [html appendString:@"</ol></fieldset>"];
            [docsHtml addObject:html];
        }
        HDWHLog(@"解析完毕");
        if (docsHtml.count > 0) {
            template = [template stringByReplacingOccurrencesOfString:@"{{ALL_DOCS}}" withString:[docsHtml componentsJoinedByString:@""]];
        }

        NSString *file = [[DocumentsPath stringByAppendingPathComponent:kWebViewHostDBDir] stringByAppendingPathComponent:kWebViewHostTestCaseFileName];
        [HDFileUtil writeToFile:file contents:[template dataUsingEncoding:NSUTF8StringEncoding]];

        if (err) {
            HDWHLog(@"解析文件有错误吗，%@", err);
        } else {
            HDWHLog(@"测试文件生成完毕，%@", file);
        }
        return YES;
    }
    return NO;
}
@end
