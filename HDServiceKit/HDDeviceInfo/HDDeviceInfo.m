//
//  HDDeviceInfo.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/16.
//

#import "HDDeviceInfo.h"
#import "HDReachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

#import <arpa/inet.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/utsname.h>

#import <ifaddrs.h>
#import <sys/ioctl.h>
#import <sys/sockio.h>

#import <AdSupport/AdSupport.h>

#import "sys/utsname.h"
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/socket.h>
#include <sys/types.h>

#define IOS_CELLULAR @"pdp_ip0"
#define IOS_WIFI @"en0"
#define IP_ADDR_IPv4 @"ipv4"
#define IP_ADDR_IPv6 @"ipv6"

NSString *const kUUIDCacheKey = @"com.chaosource.key.uuid";
NSString *const kUUIDServiceName = @"com.chaosource.keychain";

@implementation HDDeviceInfo

+ (nonnull NSString *)getUniqueId {
    UICKeyChainStore *keyChainStore = [UICKeyChainStore keyChainStoreWithService:kUUIDServiceName];
    NSString *strUUID = [[NSString alloc] initWithData:[keyChainStore dataForKey:kUUIDCacheKey] encoding:NSUTF8StringEncoding];

    // 首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID) {

        // 生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));

        // 将该uuid保存到keychain
        [keyChainStore setData:[strUUID dataUsingEncoding:NSUTF8StringEncoding] forKey:kUUIDCacheKey];
    }
    return strUUID;
}

+ (nonnull NSString *)idfaString {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (nonnull NSString *)idfvString {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (nonnull NSString *)macAddress {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }

    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);

    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    free(buf);

    return [outstring uppercaseString];
}

+ (nonnull NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ? @[/*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6] : @[/*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4];

    NSDictionary *addresses = [self getIPAddresses];

    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        address = addresses[key];
        if (address) *stop = YES;
    }];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if (!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for (interface = interfaces; interface; interface = interface->ifa_next) {
            if (!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */) {
                continue;  // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in *)interface->ifa_addr;
            char addrBuf[MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN)];
            if (addr && (addr->sin_family == AF_INET || addr->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if (addr->sin_family == AF_INET) {
                    if (inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6 *)interface->ifa_addr;
                    if (inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (nonnull NSString *)modelName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return platform ? platform : @"unknow";
}

+ (nonnull NSString *)userAgent {
    NSString *ua = [[NSUserDefaults standardUserDefaults] objectForKey:@"navigator.userAgent"];
    if (!ua) {
        if ([NSThread isMainThread]) {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSString *useAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            [[NSUserDefaults standardUserDefaults] setObject:useAgent forKey:@"navigator.userAgent"];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                NSString *useAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
                [[NSUserDefaults standardUserDefaults] setObject:useAgent forKey:@"navigator.userAgent"];
            });
        }
    }
    if (ua) {
        return ua;
    }
    return @"";
}

+ (nonnull NSString *)screenSize {
    CGFloat width = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
    CGFloat height = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
    NSString *size = @"";
    if (width > height) {
        size = [NSString stringWithFormat:@"%.01f,%.01f", height, width];
    } else {
        size = [NSString stringWithFormat:@"%.01f,%.01f", width, height];
    }
    return size;
}

+ (nonnull NSString *)appName {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    if (!appName) {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    }
    if (!appName) {
        appName = @"";
    }
    return appName;
}

+ (nonnull NSString *)appPackageName {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];

    if (!appName) {
        appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    }
    if (!appName) {
        appName = @"";
    }
    return appName;
}

+ (nonnull NSString *)appBundleId {
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if (!bundleId) {
        bundleId = @"";
    }
    return bundleId;
}

+ (nonnull NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (nonnull NSString *)deviceVersion {
    return [UIDevice currentDevice].systemVersion;
}

+ (nonnull NSString *)diskUsage {
    return [NSString stringWithFormat:@"%.01lf/%.01lf", [self deviceStorageSpace:NO] / 1000.0 / 1000.0 / 1000.0, [self deviceStorageSpace:YES] / 1000.0 / 1000.0 / 1000.0];
}

+ (NSString *)getDeviceLanguage {
    // 具体如何根据返回的字符串判断 可以参考这篇博客 http://www.cnblogs.com/bingxue314159/p/5381947.html
    NSArray *languageArray = [NSLocale preferredLanguages];
    return [languageArray objectAtIndex:0];
}

+ (long long)deviceStorageSpace:(BOOL)totalSpace {
    // 剩余空间
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpaces = (NSNumber *)[fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpaces = (NSNumber *)[fileSysAttributes objectForKey:NSFileSystemSize];
    if (totalSpace) {
        return totalSpaces.longLongValue;
    }
    return freeSpaces.longLongValue;
}

+ (NSString *)getNetworkType {
    HDReachability *reachability = [HDReachability reachabilityForInternetConnection];
    NetworkStatus status = reachability.currentReachabilityStatus;
    NSString *type = @"unknown";
    switch (status) {
        case NotReachable:
            type = @"NotReachable";
            break;
        case ReachableViaWiFi:
            type = @"wifi";
            break;
        case ReachableViaWWAN:
            type = [self networkTypeForWWAN];
            break;

        default:
            break;
    }
    return type;
}

#pragma mark - private methods
+ (NSString *)networkTypeForWWAN {
    CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
    NSString *networkType = @"";
    if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
        NSString *currentStatus = info.currentRadioAccessTechnology;
        NSArray *network2G = @[CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x];
        NSArray *network3G = @[CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD];
        NSArray *network4G = @[CTRadioAccessTechnologyLTE];

        if ([network2G containsObject:currentStatus]) {
            networkType = @"2g";
        } else if ([network3G containsObject:currentStatus]) {
            networkType = @"3g";
        } else if ([network4G containsObject:currentStatus]) {
            networkType = @"4g";
        } else {
            networkType = @"unknown";
        }
    }
    return networkType;
}

+ (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    if (carrier) {
        return carrier.carrierName;
    }
    return @"";
}
@end
