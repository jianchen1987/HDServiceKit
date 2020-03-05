//
//  HDFileUtil.m
//  HDServiceKit
//
//  Created by VanJay on 2020/3/5.
//

#import "HDFileUtil.h"

@implementation HDFileUtil
+ (BOOL)isFileExistedFilePath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return NO;
    }
    return YES;
}

+ (NSString *)fileOrDirectorySizeDescWithFilePath:(NSString *)path {
    long long totleSize = [self fileOrDirectorySizeWithFilePath:path];

    NSString *totalStr;
    if (totleSize > 1000 * 1000) {
        totalStr = [NSString stringWithFormat:@"%.2fM", totleSize / 1000.00f / 1000.00f];
    } else if (totleSize > 1000) {
        totalStr = [NSString stringWithFormat:@"%.2fKB", totleSize / 1000.00f];
    } else {
        totalStr = [NSString stringWithFormat:@"%.2fB", totleSize / 1.00f];
    }
    return totalStr;
}

+ (long long)fileOrDirectorySizeWithFilePath:(NSString *)path {

    // 获取“path”文件夹下的所有文件
    NSArray *subPathArr = [[NSFileManager defaultManager] subpathsAtPath:path];

    NSString *filePath = nil;
    long long totleSize = 0;

    for (NSString *subPath in subPathArr) {

        // 1. 拼接每一个文件的全路径
        filePath = [path stringByAppendingPathComponent:subPath];
        // 2. 是否是文件夹，默认不是
        BOOL isDirectory = NO;
        // 3. 判断文件是否存在
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];

        // 4. 以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]) {
            // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
            continue;
        }

        // 5. 指定路径，获取这个路径的属性
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         attributesOfItemAtPath: 文件夹路径
         该方法只能获取文件的属性, 无法获取文件夹属性, 所以也是需要遍历文件夹的每一个文件的原因
         */

        // 6. 获取每一个文件的大小
        NSInteger size = [[dict objectForKey:NSFileSize] integerValue];

        // 7. 计算总大小
        totleSize += size;
    }
    return totleSize;
}

+ (BOOL)createDirectoryAtPath:(NSString *)path {
    if (!path || path.length <= 0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isSuccess = YES;
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (!isExist) {
        NSError *error;
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            isSuccess = NO;
            NSLog(@"creat Directory Failed:%@", [error localizedDescription]);
        }
    }
    return isSuccess;
}

+ (BOOL)createFileAtPath:(NSString *)filePath {
    if (!filePath || filePath.length <= 0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    NSError *error;
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    BOOL isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat File Failed:%@", [error localizedDescription]);
    }
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return isSuccess;
}

+ (BOOL)writeToFile:(NSString *)filePath contents:(NSData *)data {
    if (!filePath || filePath.length <= 0) {
        return NO;
    }
    BOOL result = [self createFileAtPath:filePath];
    if (result) {
        if ([data writeToFile:filePath atomically:YES]) {
            NSLog(@"write Success");
        } else {
            NSLog(@"write Failed");
        }
    } else {
        NSLog(@"write Failed");
    }
    return result;
}

+ (NSData *)readFileData:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *fileData = [handle readDataToEndOfFile];
    [handle closeFile];
    return fileData;
}

+ (NSArray *)getFileList:(NSString *)path includeDirectory:(BOOL)includeDirectory {
    if (!path || path.length <= 0) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"getFileList Failed:%@", [error localizedDescription]);
    }
    NSMutableArray<NSString *> *fullPathArrar = [NSMutableArray arrayWithCapacity:fileList.count];
    for (NSString *fileName in fileList) {
        if (![fileName hasSuffix:@".DS_Store"]) {
            NSString *fullPath = [path stringByAppendingPathComponent:fileName];
            if (includeDirectory) {
                [fullPathArrar addObject:fullPath];
            } else {
                BOOL isDir = NO;
                if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
                    if (!isDir) {
                        [fullPathArrar addObject:fullPath];
                    }
                }
            }
        }
    }
    return fullPathArrar;
}

+ (NSArray *)getFileListRecursively:(NSString *)path {
    if (!path || path.length <= 0) {
        return nil;
    }
    NSArray *fileArray = [self getFileList:path includeDirectory:true];
    NSMutableArray *fileArrayNew = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *fullPath in fileArray) {
        BOOL isDir = NO;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            if (isDir) {
                [fileArrayNew addObjectsFromArray:[self getFileListRecursively:fullPath]];
            } else {
                [fileArrayNew addObject:fullPath];
            }
        }
    }
    return fileArrayNew;
}

+ (BOOL)moveFile:(NSString *)fromPath toPath:(NSString *)toPath toPathIsDir:(BOOL)dir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fromPath]) {
        NSLog(@"Error: fromPath Not Exist");
        return NO;
    }
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:toPath isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            if ([self createDirectoryAtPath:toPath]) {
                NSString *fileName = fromPath.lastPathComponent;
                toPath = [toPath stringByAppendingPathComponent:fileName];
                return [self moveItemAtPath:fromPath toPath:toPath];
            }
        } else {
            [self removeFileOrDirectory:toPath];
            return [self moveItemAtPath:fromPath toPath:toPath];
        }
    } else {
        if (dir) {
            if ([self createDirectoryAtPath:toPath]) {
                NSString *fileName = fromPath.lastPathComponent;
                toPath = [toPath stringByAppendingPathComponent:fileName];
                return [self moveItemAtPath:fromPath toPath:toPath];
            }
        } else {
            return [self moveItemAtPath:fromPath toPath:toPath];
        }
    }
    return NO;
}

+ (BOOL)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath {
    BOOL result = NO;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];
    if (error) {
        NSLog(@"moveFile Fileid：%@", [error localizedDescription]);
    }
    return result;
}

+ (BOOL)appendData:(NSData *)data withPath:(NSString *)filePath {
    if (filePath.length == 0) {
        return NO;
    }
    BOOL result = [self createFileAtPath:filePath];
    if (result) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [handle seekToEndOfFile];
        [handle writeData:data];
        [handle synchronizeFile];
        [handle closeFile];
    } else {
        NSLog(@"appendData Failed");
    }
    return result;
}

+ (BOOL)removeFileOrDirectory:(NSString *)filePath {
    BOOL isSuccess = NO;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    isSuccess = [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"removeFile Field：%@", [error localizedDescription]);
    } else {
        NSLog(@"removeFile Success");
    }
    return isSuccess;
}

+ (void)removeFileSuffixList:(NSArray<NSString *> *)suffixList filePath:(NSString *)path recursive:(BOOL)recursive {
    NSArray *fileArray = nil;
    if (recursive) {  // 是否深度遍历
        fileArray = [self getFileListRecursively:path];
    } else {
        fileArray = [self getFileList:path includeDirectory:true];
        NSMutableArray *fileArrayTmp = [NSMutableArray array];
        for (NSString *filePath in fileArray) {
            [fileArrayTmp addObject:filePath];
        }
        fileArray = fileArrayTmp;
    }
    for (NSString *filePath in fileArray) {
        for (NSString *suffix in suffixList) {
            if ([filePath hasSuffix:suffix]) {
                [self removeFileOrDirectory:filePath];
            }
        }
    }
}

+ (NSDictionary *)getFileInfo:(NSString *)path {
    NSError *error;
    NSDictionary *reslut = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (error) {
        NSLog(@"getFileInfo Failed:%@", [error localizedDescription]);
    }
    return reslut;
}

+ (BOOL)removeFileWithFilePath:(NSString *)path {
    return [self removeFileWithFilePath:path exceptFile:nil];
}

+ (BOOL)removeFileWithFilePath:(NSString *)path exceptFile:(NSString *__nullable)exceptFile {
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    NSError *error = nil;
    if (isDir) {
        // 拿到path路径的下一级目录的子文件夹
        NSArray<NSString *> *subPathArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        if (exceptFile && exceptFile.length > 0) {
            // 过滤
            subPathArr = [subPathArr filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *_Nullable name, NSDictionary<NSString *, id> *_Nullable bindings) {
                                         return ![name isEqualToString:exceptFile];
                                     }]];
        }

        NSString *filePath = nil;
        for (NSString *subPath in subPathArr) {
            filePath = [path stringByAppendingPathComponent:subPath];

            // 删除子文件夹
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                return NO;
            }
        }
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}
@end
