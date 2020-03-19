#!/bin/bash

# 更新头文件
python3 ./HeaderFileGenerator.py

directory="$(pwd)"
# 文件后缀名，自动查找
file_extension="podspec"
podspec_path=`find $directory -name "*.$file_extension" -maxdepth 1 -print`

echo "podspec路径:$podspec_path"

podspec_name=$(basename $podspec_path)
echo "podspec名称:$podspec_name"

# 获取版本号
version=`grep -E "s.version |s.version=" $podspec_path | head -1 | sed 's/'s.version'//g' | sed 's/'='//g'| sed 's/'\"'//g'| sed 's/'\''//g' | sed 's/'[[:space:]]'//g'`
echo "podspec版本:$version"

echo "开始提交代码并打 tag：$version"
filename=$(echo $podspec_name | cut -d . -f1)
git rm -r --cached . -f
git add .
git commit -m "published $filename $version"

git push origin master

git tag -d $version
git push origin :refs/tags/$version

git tag -a $version -m "$version"
git push origin --tags
echo "提交及推送代码、tags 结束\n"

echo "开始发布 $filename 版本 $version 到 Chaos"
# 清除缓存
pod cache clean --all

pod repo push Chaos "${podspec_name}" --allow-warnings --verbose --sources=https://github.com/CocoaPods/Specs.git,ssh://git@code.kh-super.net:7999/mob/chaos-specs.git
echo "发布 $filename 版本 $version 到 Chaos 结束\n"

echo "开始打包 framework"
pod package ${podspec_name} --no-mangle --exclude-deps --force --spec-sources=https://github.com/CocoaPods/Specs.git,ssh://git@code.kh-super.net:7999/mob/chaos-specs.git
echo "打包 framework 结束\n"