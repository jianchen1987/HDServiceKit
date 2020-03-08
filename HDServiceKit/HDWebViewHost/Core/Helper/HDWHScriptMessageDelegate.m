//
//  MKScriptMessageDelegate.m
//  HDWebviewHost
//
//  Created by VanJay on 03/06/2020.
//  Copyright © 2019 chaos network technology. All rights reserved.
//

#import "HDWHScriptMessageDelegate.h"

@interface HDWHScriptMessageDelegate()

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

@end

@implementation HDWHScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

- (void)dealloc
{
    NSLog(@"MKScriptMessageDelegate dealloc");
}

@end
