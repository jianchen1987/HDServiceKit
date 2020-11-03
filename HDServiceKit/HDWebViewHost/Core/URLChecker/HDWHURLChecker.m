//
//  HDWHURLChecker.m
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2016 smilly.co. All rights reserved.
//

#import "HDWHURLChecker.h"
#import "HDWHAppWhiteListParser.h"
#import "NSBundle+HDWebViewHost.h"

@implementation HDWHURLChecker

static HDWHURLChecker *_sharedManager = nil;
static NSDictionary *_authorizedTable = nil;
+ (instancetype)sharedManager {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        // 默认数据
        NSString *path = [[NSBundle hd_WebViewHostCoreResources] pathForResource:@"app-access" ofType:@"txt"];
        NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        _authorizedTable = [[HDWHAppWhiteListParser sharedManager] parserFileContent:fileContents];
    });

    return _sharedManager;
}

- (BOOL)checkURL:(NSURL *)url forAuthorizationType:(HDWHAuthorizationType)authType {
    if (url == nil) {
        return NO;
    }
    // 本地测试地址。
    NSString *directory = NSHomeDirectory();                                   // user文件根目录 /var/mobile/..
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];                 // /var/containers/
    NSString *bundleURL = [[[NSBundle mainBundle] bundleURL] absoluteString];  // file:///
    NSString *tempDir = NSTemporaryDirectory();                                //在真机上/private/..
    if ([url.absoluteString hasPrefix:directory] || [url.absoluteString hasPrefix:bundlePath] || [url.absoluteString hasPrefix:bundleURL] ||
        [url.absoluteString hasPrefix:tempDir]) {
        return YES;
    }

    NSString *key = nil;
    if (authType == HDWHAuthorizationTypeSchema) {
        key = @"schema-open-url";
    } else if (authType == HDWHAuthorizationTypeWebViewHost) {
        key = @"webviewhost";
    }
    if (key) {
        NSArray *rules = [_authorizedTable objectForKey:key];
        if ([rules count] == 0) {
            return YES;  // 白名单为空，放行
        }
        BOOL pass = NO;

        for (NSInteger i = 0, l = [rules count]; i < l; i++) {
            NSString *rule = [rules objectAtIndex:i];
            // 将.号处理为\.如www.chaosource.com => www\\.chaosource\\.com;
            rule = [rule stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
            // 将*号处理为 [a-z0-9]+,
            rule = [rule stringByReplacingOccurrencesOfString:@"*" withString:@"[\\w\\d-_]+"];
            // 精确匹配. 开始和结尾
            rule = [NSString stringWithFormat:@"^%@$", rule];

            NSError *regexError = nil;
            NSRegularExpression *regex = [NSRegularExpression
                regularExpressionWithPattern:rule
                                     options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                       error:&regexError];

            if (regexError) {
                NSLog(@"Regex creation failed with error: %@", [regexError description]);
                continue;
            }
            // 使用host
            NSString *host = [url host];
            if (!host || ![host isKindOfClass:NSString.class] || host.length <= 0) {
                pass = NO;
                break;
            } else {
                NSArray *matches = [regex matchesInString:host options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, host.length)];
                if ([matches count] > 0) {
                    pass = YES;
                    break;
                }
            }
        }
        return pass;
    } else {
        return YES;  // 不在授权类型里的，默认返回通过。
    }
}

- (BOOL)addWhiteList:(NSArray<NSString *> *)whiteList forAuthorizationType:(HDWHAuthorizationType)authType {
    if(whiteList.count == 0) {
        return YES;
    }
    NSString *key = nil;
    if (authType == HDWHAuthorizationTypeSchema) {
        key = @"schema-open-url";
    } else if (authType == HDWHAuthorizationTypeWebViewHost) {
        key = @"webviewhost";
    }
    if (key) {
        NSArray *rules = [_authorizedTable objectForKey:key];
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:rules];
        [tmp addObjectsFromArray:whiteList];
        [_authorizedTable setValue:tmp forKey:key];
        return YES;
    }
    
    return NO;
}

@end
