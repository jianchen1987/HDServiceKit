//
//  ExampleItem.m
//  ViPayComponents
//
//  Created by VanJay on 2020/2/11.
//  Copyright © 2020 VanJay. All rights reserved.
//

#import "ExampleItem.h"

@implementation ExampleItem
+ (instancetype)itemWithDesc:(NSString *)desc mediatorAction:(NSString *)mediatorAction {
    ExampleItem *item = [[self alloc] init];
    item.desc = desc;
    item.mediatorAction = mediatorAction;
    return item;
}

+ (instancetype)itemWithDesc:(NSString *)desc routeURL:(NSString *)routeURL {
    ExampleItem *item = [[self alloc] init];
    item.desc = desc;
    item.routeURL = routeURL;
    return item;
}
@end
