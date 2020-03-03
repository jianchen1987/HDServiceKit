#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import argparse
import xml.etree.cElementTree as ET

HeaderFileName = 'HDServiceKit'
KitDirName = 'HDServiceKit'
HeaderFileFullName = HeaderFileName + '.h'
version = ''

# 自动获取版本号
def autoFetchVersionNumber():
    internal_version = ''
    # 从 Info.plist 中读取 HDServiceKit 的版本号，将其定义为一个 static const 常量以便代码里获取
    infoFilePath = str(os.getenv('SRCROOT')) + \
        '/%s/%s-Info.plist' % (HeaderFileName, HeaderFileName)
    infoTree = ET.parse(infoFilePath)
    infoDictList = list(infoTree.find('dict'))
    # 从 info.plist 获取版本号
    for index in range(len(infoDictList)):
        element = infoDictList[index]
        if element.text == 'CFBundleShortVersionString':
            internal_version = infoDictList[index + 1].text
            break

    # Xcode 11
    if internal_version.startswith('$'):
        internal_version = str(os.getenv('MARKETING_VERSION'))
    return internal_version

# 判断是否存在 podspec 文件
def isExistPodspec():
    allFiles = os.listdir(os.getcwd())
    isExist = False
    for fileName in allFiles:
        if '.podspec' in fileName:
            isExist = True
        else:
            isExist = False
    return isExist


if isExistPodspec():
    # 这种情况是手动触发
    ROOT_DIR_PATH = os.getcwd() + '/' + KitDirName
else:
    # 这种情况是在 Example 内 Xcode build phases 自动触发
    ROOT_DIR_PATH = os.getcwd() + '/../' + KitDirName

# 切换工作目录
os.chdir(ROOT_DIR_PATH)
ROOT_DIR_PATH = os.getcwd()


# 递归收集所有文件
def fileListForDir(dir):
    fileList = []
    for dir_path, subdir_list, file_list in os.walk(dir):
        # 隐私头文件目录不导入
        if dir_path.find('Private') > -1:
            print('过滤隐私目录:'+dir_path)
            continue
        # 可以在这里设置过滤不相关目录
        if not(dir_path.find(".git") > -1 or dir_path.find(".gitee") > -1 or dir_path.find(".svn") > -1 or dir_path.endswith('lproj') or dir_path.endswith('xcassets')):
            for fname in file_list:
                # if fname != HeaderFileFullName and (fname.lower().endswith(".h") or fname.lower().endswith(".c")):
                if fname != HeaderFileFullName and (fname.lower().endswith(".h")):
                    full_path = os.path.join(dir_path, fname)
                    # 这是全路径
                    # fileList.append(full_path + fname)
                    fileList.append(fname)
    return fileList


def main(args=None):
    if args and args.version:
        version = args.version
    else:
        version = autoFetchVersionNumber()

    print('开始生成头文件')
    print('根目录：' + ROOT_DIR_PATH)
    print('版本号：' + version)

    fileContent = '''//
//  %s.h
//  %s
//
//  Created by VanJay on 2020/2/26.
//  Copyright © 2020 VanJay. All rights reserved.
//  This file is generated automatically.

#ifndef %s_h
#define %s_h

#import <UIKit/UIKit.h>

/// 版本号
static NSString * const %s_VERSION = @"%s";

''' % (HeaderFileName, HeaderFileName, HeaderFileName, HeaderFileName, HeaderFileName, version)

    # 文件名列表
    fileList = fileListForDir(ROOT_DIR_PATH)
    for filename in fileList:
        fileContent += '''#if __has_include("%s")
#import "%s"
#endif

''' % (filename, filename)

    # 拼接尾部
    fileContent += '#endif /* %s_h */' % (HeaderFileName)

    # 写入文件
    with open(ROOT_DIR_PATH + '/' + HeaderFileFullName, 'w') as file:
        print("生成头文件成功")
        file.write(fileContent)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='HDServiceKit 头文件生成脚本')
    parser.add_argument('-v', '--version', type=str,
                        help='当前版本号，如非 xcodebuild 触发必须传递', required=False)
    args = parser.parse_args()
    main(args)
