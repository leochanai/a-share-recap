#!/bin/bash
# 创建 ~/reports 到 src/content/reports 的符号链接

SOURCE_DIR="$HOME/reports"
TARGET_DIR="src/content/reports"

# 已经是正确的符号链接，跳过
if [ -L "$TARGET_DIR" ] && [ "$(readlink "$TARGET_DIR")" = "$SOURCE_DIR" ]; then
    echo "Symlink already exists: $TARGET_DIR -> $SOURCE_DIR"
    exit 0
fi

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# 清理旧目录/链接
rm -rf "$TARGET_DIR"

# 创建符号链接
ln -s "$SOURCE_DIR" "$TARGET_DIR"
echo "Created symlink: $TARGET_DIR -> $SOURCE_DIR"
