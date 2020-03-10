//
//  NSObject+HDWebViewHost.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HDWebViewHost)
- (id)hd_performSelector:(SEL)aSelector withObjects:(NSArray *)objects;
@end

NS_ASSUME_NONNULL_END
