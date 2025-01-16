# rclone-docker
Docker for Rclone FUSE 挂载到宿主机(通过rclone挂载网盘到宿主机)

1. git clone https://github.com/cjw414522569/rclone-docker.git
2. 修改/config/rclone.conf 或者 docker exec -it rclone-mount rclone --config="/config/rclone.conf" config
3. docker-compose up -d

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
