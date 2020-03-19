//
//  NSBundle+HDScanCode.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/19.
//

#import "NSBundle+HDScanCode.h"

@implementation NSBundle (HDScanCode)

+ (NSBundle *)hd_ScanCodeResources {
    static NSBundle *resourceBundle = nil;
    if (!resourceBundle) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *resourcePath = [mainBundle pathForResource:@"Frameworks/HDServiceKit.framework/HDScanCodeResources" ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [mainBundle pathForResource:@"HDScanCodeResources" ofType:@"bundle"];
        }
        resourceBundle = [NSBundle bundleWithPath:resourcePath] ?: mainBundle;
    }
    return resourceBundle;
}
@end
