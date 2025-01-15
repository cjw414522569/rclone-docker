#!/bin/bash

# 启用错误检查
set -e

# 如果传入了参数，直接执行命令
if [ $# -gt 0 ]; then
    exec "$@"
fi

# 检查必要的目录和权限
echo "检查目录和权限..."
for dir in "/media" "/cache" "/config" "/root/.config/rclone"; do
    if [ ! -d "$dir" ]; then
        echo "创建目录: $dir"
        mkdir -p "$dir"
    fi
done

# 检查并复制 rclone 配置
RCLONE_CONF="/root/.config/rclone/rclone.conf"
if [ ! -f "$RCLONE_CONF" ]; then
    echo "错误: rclone 配置文件不存在: $RCLONE_CONF"
    ls -la /root/.config/rclone/
    exit 1
fi

echo "rclone 配置文件内容:"
cat "$RCLONE_CONF"

# 确保 FUSE 设备可用
if [ ! -e "/dev/fuse" ]; then
    echo "错误: FUSE 设备不可用"
    exit 1
fi

# 检查 rclone 是否可执行
if ! command -v rclone &> /dev/null; then
    echo "错误: rclone 命令不可用"
    exit 1
fi

# 获取传入的环境变量
MOUNT_PATH=${MOUNT_PATH:-default_remote}  # 如果环境变量未定义，使用默认值
REMOTE_NAME=${REMOTE_NAME:-default_folder}

# 检查参数是否为空
if [ -z "$MOUNT_PATH" ] || [ -z "$REMOTE_NAME" ]; then
    echo "错误: 未提供足够的参数。需要两个环境变量：MOUNT_PATH 和 REMOTE_NAME。"
    echo "示例: MOUNT_PATH=my_remote REMOTE_NAME=my_folder"
    exit 1
fi

echo "MOUNT_PATH: $MOUNT_PATH"
echo "REMOTE_NAME: $REMOTE_NAME"

# 启动 rclone 挂载
echo "启动 rclone 挂载..."
rclone mount "$MOUNT_PATH":/"$REMOTE_NAME" /media \
    --daemon \
    --allow-other \
    --log-file=/config/rclone.log \
    --log-level INFO \
    --config "$RCLONE_CONF" \
	--header "Referer:" \
	--copy-links \
	--transfers=8 \
	--multi-thread-streams 8 \
	--no-gzip-encoding \
	--no-check-certificate \
	--allow-non-empty \
	--umask 000 \
	--dir-cache-time 24h \
	--cache-dir=/cache \
	--vfs-cache-mode full \
	--buffer-size 512M \
	--vfs-read-chunk-size 16M \
	--vfs-read-chunk-size-limit 128M \
	--vfs-cache-max-size 10G

# 等待 rclone 挂载完成
echo "等待 rclone 挂载就绪..."
max_attempts=30
attempt=1
while [ $attempt -le $max_attempts ]; do
    if mountpoint -q /media; then
        echo "Rclone 挂载成功"
        break
    fi
    echo "等待挂载... ($attempt/$max_attempts)"
    sleep 1
    attempt=$((attempt + 1))
done

if ! mountpoint -q /media; then
    echo "Rclone 挂载失败，查看日志:"
    cat /config/rclone.log
    exit 1
fi

# 防止脚本退出，保持容器运行
echo "Rclone 挂载完成，保持容器运行..."
tail -f /dev/null