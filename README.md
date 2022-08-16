# bgmi-docker-all-in-one
由https://github.com/codysk/bgmi-docker-all-in-one 镜像改编

## 新增功能
1. 支持硬链接，硬链接工具由[kaaass](https://github.com/kaaass/bgmi_hardlink_helper)大佬提供

2. 支持PUID和PGID设置

3. 支持是否开启内部transmission，可以在环境变量内设置是否启用

4. 支持transmission增强版UI，可以在环境变量内设置是否启用

## 部署
docker-cli
```bash
docker run -itd \
  --name=bgmi \
  --restart always \
  -v /bgmi:/bgmi \
  -v /home/video2/NEW:/media \
  -p 80:80 \
  -p 9091:9091 \
  -p 51413:51413/tcp \
  -p 51413:51413/udp \
  -e TZ=Asia/Shanghai \
  -e PGID=1000 \
  -e PUID=1000 \
  -e TRANSMISSION=true \
  -e TRANSMISSION_WEB_CONTROL=true \
  -e BGMI_SOURCE=mikan_project \
  -e BGMI_ADMIN_TOKEN=password
```
docker-compose
```bash
version: '3.3'
services:
    bgmi:
        image: ddsderek/bgmi-docker-all-in-one:latest
        container_name: "bgmi"
        restart: "always"
        volumes:
          - /bgmi:/bgmi
          - /home/video2/NEW:/media
        ports:
            - '80:80'
            - '9091:9091'
            - '51413:51413/tcp'
            - '51413:51413/udp'
        environment:
          - TZ=Asia/Shanghai
          - PGID=1000
          - PUID=1000
          - TRANSMISSION=true
          - TRANSMISSION_WEB_CONTROL=true
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
```

|            Parameter             | Function                                                     |
| :------------------------------: | ------------------------------------------------------------ |
|             -p 80:80             | BGMI Web端口                                                 |
|           -p 9091:9091           | transmission web端口                                         |
|        -p 51413:51413/tcp        | Torrent 端口 TCP                                             |
|        -p 51413:51413/udp        | Torrent 端口 UDP                                             |
|       -e TZ=Asia/Shanghai        | 时区                                                         |
|           -e PGID=1000           | 对于 GroupID - 请参阅下面的说明                              |
|           -e PUID=1000           | 对于用户 ID - 请参阅下面的说明                               |
|       -e TRANSMISSION=true       | 内部transmission，true为开启，false为关闭，如果使用外部transmission，可以选择false关闭内部transmission |
| -e TRANSMISSION_WEB_CONTROL=true | transmission增强版UI，true为启用，false为使用默认UI          |
|   -e BGMI_SOURCE=mikan_project   | BGMI 默认数据源（bangumi_moe、mikan_project 或 dmhy）        |
|   -e BGMI_ADMIN_TOKEN=password   | 设置 BGMI Web 界面身份验证令牌                               |
|          -v /bgmi:/bgmi          | BGMI 配置文件目录                                            |
|    -v /home/video2/NEW:/media    | 媒体文件目录，包含下载文件和硬链接后的文件                   |

## PUID GUID 说明

当在主机操作系统和容器之间使用卷（`-v`标志）权限问题时，我们通过允许您指定用户`PUID`和组来避免这个问题`PGID`。

确保主机上的任何卷目录都归您指定的同一用户所有，并且任何权限问题都会像魔术一样消失。

在这种情况下`PUID=1000`，`PGID=1000`找到你的用途`id user`如下：

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```
