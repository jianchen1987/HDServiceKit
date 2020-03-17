//
//  NSObject+HDWebViewHost.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HDWebViewHost)

/// 带多个参数执行某方法，这里注意，如果 NSArray 第一个对象为 nil，即使在其之后的对象不为空，该数组也为有效值
/// @param aSelector 方法名
/// @param objects 参数
- (id)hd_performSelector:(SEL)aSelector withObjects:(NSArray *)objects;
@end

NS_ASSUME_NONNULL_END
