FROM rclone/rclone:latest AS rclone
FROM debian:latest
# 从 rclone 镜像复制二进制文件
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# 安装必要的包
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fuse3 \
    ca-certificates \
    curl \
    fonts-noto-cjk-extra \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# 创建必要的目录和设置权限
RUN mkdir -p /media /cache /config /root/.config/rclone

# 设置工作目录
WORKDIR /

# 添加启动脚本
COPY ./start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
