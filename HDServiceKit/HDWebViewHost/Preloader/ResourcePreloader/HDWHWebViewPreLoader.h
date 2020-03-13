//
//  HDWHWebViewPreLoader.h
//  HDServiceKit
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWebViewHostEnum.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 表示目前本地的 .json 文件的版本。如果服务器较旧则不返回新配置
static const int kWHPreloadResourceVersion = 1;
extern NSString *const kPreloadResourceConfCacheKey;

typedef NSDictionary *_Nonnull (^HDWHPreloadFetchConfigHandler)(int version);

@interface HDWHWebViewPreLoader : NSObject

+ (instancetype)defaultLoader;

/**
 从服务器下载最新的配置到 ud 里. 传入当前版本，返回新的配置，配置样式如下：
 {
     "domain": "https://www.chaosource.com",  // 是 html 加载时的地址，重要的是 host 部分

     // 下面的属性中，如 scripts 的地址为 相对地址，和 baseURL 拼接形成完成，如,
     // baseURL = "https://chaosource-static.cdn".
     // Scripts = ["/xm/a.js"],
     // 实际得到的地址是：https://chaosource-static.cdn/xm/a.js
     "styles": [
        "/hxm/yanxuan-wap/p/20161201/style/css/style-05d5040aba.css"
     ],
     "images": [
        "https://xxxxxxxx.png"
     ],
     "fonts" : [], // 预加载的字体，可以是数组
     "html" : "" // 预加载的 HTML，为了控制资源，只能加载一个
 }
 */
- (void)updateConfig:(HDWHPreloadFetchConfigHandler)fetchConfig;

/**
 在新开的 window 里去下载尝试下载关键资源。
 如果有以前旧配置，使用旧配置下载。
 */
- (void)loadResources;

@end

NS_ASSUME_NONNULL_END
