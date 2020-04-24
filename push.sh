#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
# set -e

ls_date=$(date +%F)

cp -Rf /Users/admin/Desktop/company/flutter/staffperformance/ /Users/admin/Desktop/myCode/test/draw_design 

echo '/ios/' >>.gitignore
echo '/android/' >>.gitignore

cd /Users/admin/Desktop/myCode/test/draw_design

# /usr/local/bin/node ./changeVersion.js
rm -rf .git

/usr/local/bin/git init

/usr/local/bin/git remote add origin git@github.com:xuzhongpeng/draw_design.git

/usr/local/bin/git add -A

/usr/local/bin/git commit -m ${ls_date}

/usr/local/bin/git push --force origin master
