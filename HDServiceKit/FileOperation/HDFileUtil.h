//
//  HDFileUtil.h
//  HDServiceKit
//
//  Created by VanJay on 2020/3/5.
//

#import <Foundation/Foundation.h>

// 获取Document目录
#define DocumentsPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

// 获取Library目录
#define LibraryPath [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]

// 获取Caches目录
#define CachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

// 获取Preferences目录 通常情况下，Preferences有系统维护，所以我们很少去操作它。
#define PreferencesPath [LibraryPath stringByAppendingPathComponent:@"Preferences"]

// 获取tmp目录
#define TmpPath NSTemporaryDirectory()

NS_ASSUME_NONNULL_BEGIN

@interface HDFileUtil : NSObject

/// 文件/文件夹是否存在
/// @param filePath 路径
+ (BOOL)isFileExistedFilePath:(NSString *)filePath;

/// 获取文件/文件夹大小描述，自动区分 MB、KB
/// @param path 路径
+ (NSString *)fileOrDirectorySizeDescWithFilePath:(NSString *)path;

/// 获取文件/文件夹大小（单位：B）
/// @param path 路径
+ (long long)fileOrDirectorySizeWithFilePath:(NSString *)path;

/// 创建文件夹，可传多级目录，上级目录不存在会自动创建
/// @param path 文件夹路径
+ (BOOL)createDirectoryAtPath:(NSString *)path;

/// 创建文件，文件夹若不存在将自动创建
/// @param filePath 文件路径
+ (BOOL)createFileAtPath:(NSString *)filePath;

/// 写入文件，文件不存在将自动创建
/// @param filePath 文件路径
/// @param data 写入数据
+ (BOOL)writeToFile:(NSString *)filePath contents:(NSData *)data;

/// 追加数据到文件，文件不存在将自动创建
/// @param data 数据
/// @param filePath 文件路径
+ (BOOL)appendData:(NSData *)data withPath:(NSString *)filePath;

/// 读取文件
/// @param path 文件路径
+ (NSData *)readFileData:(NSString *)path;

/// 获取文件列表
/// @param path 路径
/// @param includeDirectory 是否包括文件夹
+ (NSArray *)getFileList:(NSString *)path includeDirectory:(BOOL)includeDirectory;

/// 递归获取文件列表
/// @param path 路径
+ (NSArray *)getFileListRecursively:(NSString *)path;

/// 移动文件/文件夹
/// @param fromPath 源路径
/// @param toPath 目标路径
/// @param dir 目标地址是否文件夹
+ (BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath toPathIsDir:(BOOL)dir;

/// 删除文件/文件夹
/// @param filePath 文件/文件夹路径
+ (BOOL)removeFileOrDirectory:(NSString *)filePath;

/// 删除特定后缀的文件
/// @param suffixList 后缀列表
/// @param path 路径
/// @param recursive 是否递归
+ (void)removeFileSuffixList:(NSArray<NSString *> *)suffixList filePath:(NSString *)path recursive:(BOOL)recursive;

/**
 *  清除path路径文件/文件夹
 *
 *  @param path 要清除缓存的文件夹 路径
 *
 *  @return 是否清除成功
 */
+ (BOOL)removeFileWithFilePath:(NSString *)path;

/**
*  清除path路径文件/文件夹，指定文件除外
*
*  @param path 要清除缓存的文件夹 路径
*  @param exceptFile 如果顶层是文件夹，要排除的文件/文件夹
*
*  @return 是否清除成功
*/
+ (BOOL)removeFileWithFilePath:(NSString *)path exceptFile:(NSString *__nullable)exceptFile;

/// 获取文件信息
/// @param path 路径
+ (NSDictionary *)getFileInfo:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
