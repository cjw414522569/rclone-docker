# rclone-docker
Docker for Rclone FUSE 挂载到宿主机(通过rclone挂载网盘到宿主机)

1. git clone https://github.com/cjw414522569/rclone-docker.git
2. 修改/config/rclone.conf 或者 docker exec -it rclone-mount rclone --config="/config/rclone.conf" config
3. docker-compose up -d
   
目前只能在正常停止容器的状态下才能运行自动取消挂载脚本

如果强制停止或者强制删除容器会在宿主机残留一个挂载点需要手动删除，如果不删除会导致下一次挂载这个文件夹失败


如果强制停止或者强制删除容器可以用

mount | grep /opt/rclone/media        查看是否有残留挂载点

fusermount -u /opt/rclone1/media      删除残留挂载点

```
[alist]
type = webdav
url = https://alist.xxxx.cn/dav
vendor = other
user = 
pass = 

    environment: 
      - MOUNT_PATH=alist    #配置名称就是rclone.conf配置文件[]里的名称例如我上面[alist]，就填alist
      - REMOTE_NAME=onedirve   #路径，webdav里的文件夹路径，可留空，例如https://alist.xxxx.cn/dav/onedirve，就是我webdav里有个onedirve文件夹
    volumes:
      - ./media:/media:shared              #挂载到宿主机到./media
      - ./rclone:/root/.config/rclone/     #挂载rclone配置文件
```
