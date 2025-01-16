FROM rclone/rclone:latest AS rclone
FROM alpine
# 从 rclone 镜像复制二进制文件
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# 安装必要的包
RUN apk update && \
    apk add --no-cache \
    fuse3 \
    bash \
    ca-certificates \
	gettext \
	fusermount

#修改 /etc/fuse.conf 文件，启用 user_allow_other 选项
RUN sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
# 创建必要的目录和设置权限
RUN mkdir -p /media /cache /config /root/.config/rclone

COPY root/ /
