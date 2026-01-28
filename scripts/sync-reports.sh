#!/bin/bash
# 同步 ~/reports/ 到项目目录
rsync -av --delete ~/reports/*.md /Users/farghost/GithubProjects/a-share-recap/src/content/reports/
echo "Reports synced successfully"
