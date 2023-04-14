# BGmi All In One Docker

[![Build](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/actions/workflows/docker-image.yml)

**注意，Dockerhub仓库从`ddsderek/bgmi-docker-all-in-one`换为`ddsderek/bgmi-all-in-one`**

参考 https://github.com/codysk/bgmi-docker-all-in-one 大佬的镜像制作而成。

## 功能
1. 硬链接，硬链接通过内置硬链接脚本实现。
2. PUID和PGID设置。
3. Umask设置。
4. 内部aria2-pro，transmission下载器。
5. Transmission增强版UI。
6. Ariang管理界面。
7. 常用脚本 `bgmi_download` `bgmi_hardlink`。
8. 镜像体积小，层数少。

## BGmi介绍

[官方介绍和使用方法](https://github.com/BGmi/BGmi/blob/master/README.md)

## 部署
### docker-cli

**Transmission**

> 注意：镜像内置Transmission Web Control管理界面，访问```IP:PORT/tr```，此```PORT```与访问BGmi Web端口为同一端口

```bash
docker run -itd \
  --name=bgmi \
  --restart always \
  -v /bgmi:/bgmi \
  -v /media:/media \
  -p 80:80 \
  -p 51413:51413/tcp \
  -p 51413:51413/udp \
  -e TZ=Asia/Shanghai \
  -e PGID=1000 \
  -e PUID=1000 \
  -e UMASK=022 \
  -e MEDIA_DIR=/media/cartoon \
  -e DOWNLOAD_DIR=/media/downloads \
  -e BGMI_DATA_SOURCE=mikan_project \
  -e BGMI_HTTP_ADMIN_TOKEN=password \
  -e BGMI_HARDLINK_USE=true \
  -e TR_USER=bgmi \
  -e TR_PASS=password \
  -e TR_PEERPORT=51413 \
  ddsderek/bgmi-all-in-one:transmission
```

**Aria2**

> 注意：镜像内置Ariang管理界面，访问```IP:PORT/ariang```，此```PORT```与访问BGmi Web端口为同一端口

```bash
docker run -itd \
  --name=bgmi \
  --restart always \
  -v /bgmi:/bgmi \
  -v /media:/media \
  -p 80:80 \
  -p 6888:6888/tcp \
  -p 6888:6888/udp \
  -e TZ=Asia/Shanghai \
  -e PGID=1000 \
  -e PUID=1000 \
  -e UMASK=022 \
  -e MEDIA_DIR=/media/cartoon \
  -e DOWNLOAD_DIR=/media/downloads \
  -e BGMI_DATA_SOURCE=mikan_project \
  -e BGMI_HTTP_ADMIN_TOKEN=password \
  -e BGMI_HARDLINK_USE=true \
  -e ARIA2_UPDATE_TRACKERS=true \
  -e ARIA2_CUSTOM_TRACKER_URL= \
  -e ARIA2_LISTEN_PORT=6888 \
  -e ARIA2_RPC_PORT=6800 \
  -e ARIA2_RPC_SECRET= \
  -e ARIA2_DISK_CACHE= \
  -e ARIA2_IPV6_MODE= \
  -e ARIA2_SPECIAL_MODE= \
  ddsderek/bgmi-all-in-one:aria2
```

**不使用内置下载器**

```bash
docker run -itd \
  --name=bgmi \
  --restart always \
  -v /root/config/bgmi:/bgmi \
  -v /media:/media \
  -p 80:80 \
  -e TZ=Asia/Shanghai \
  -e PGID=1000 \
  -e PUID=1000 \
  -e UMASK=022 \
  -e MEDIA_DIR=/media/cartoon \
  -e DOWNLOAD_DIR=/media/downloads \
  -e BGMI_DATA_SOURCE=mikan_project \
  -e BGMI_HTTP_ADMIN_TOKEN=password \
  -e BGMI_HARDLINK_USE=false \
  ddsderek/bgmi-all-in-one:latest
```

### docker-compose

**transmission**

[docker-compose](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/example/transmission/docker-compose.yml)

**Aria2**

[docker-compose](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/example/aria2-pro/docker-compose.yml)

**不使用内置下载器**

[docker-compose](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/example/default/docker-compose.yml)

## 参数说明

### 镜像TAG

|     TAG      |             解释             |
| :----------: | :--------------------------: |
|    latest    |     只包含BGmi程序的镜像     |
| transmission | 包含BGmi和transmission的镜像 |
|    aria2     |    包含BGmi和aria2的镜像     |

### BGmi

|         参数          |                            作用                            |
| :-------------------: | :--------------------------------------------------------: |
|        `-e TZ`        |                          时区设置                          |
|       `-e PUID`       |                       启动程序用户ID                       |
|       `-e PGID`       |                      启动程序用户组ID                      |
|      `-e UMASK`       |                          权限掩码                          |
|    `-e MEDIA_DIR`     |         BGmi 硬链接目录（目录必须在 `/media` 下）          |
|   `-e DOWNLOAD_DIR`   |          BGmi 下载目录（目录必须在 `/media` 下）           |
|   `-e BGMI_DATA_SOURCE`    | 设置 BGMI 默认数据源（bangumi_moe、mikan_project 或 DMHY） |
| `-e BGMI_HTTP_ADMIN_TOKEN` |               设置 BGMI Web 界面身份验证令牌               |
| `-e BGMI_HARDLINK_USE` |               是否启用镜像内置的硬链接脚本（默认开启）               |
|        `-p 80`        |                       BGmi Web 端口                        |
|      `-v /bgmi`       |                          配置文件                          |
|      `-v /media`      |            媒体文件夹，包含下载文件和硬链接文件            |

### Transmission

|       参数       |           作用            |
| :--------------: | :-----------------------: |
|   `-e TR_USER`   | transmission Web 登入用户 |
|   `-e TR_PASS`   | transmission Web 登入密码 |
| `-e TR_PEERPORT` |       种子传输端口        |

### Aria2

此镜像内置使用Aria2-Pro，具体参数设置请看[Aria2-Pro-Docker官方说明](https://github.com/P3TERX/Aria2-Pro-Docker#parameters)

## PUID GUID 说明

当在主机操作系统和容器之间使用卷（`-v`标志）权限问题时，我们通过允许您指定用户`PUID`和组来避免这个问题`PGID`。

确保主机上的任何卷目录都归您指定的同一用户所有，并且任何权限问题都会像魔术一样消失。

在这种情况下`PUID=1000`，`PGID=1000`找到你的用途`id user`如下：

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## 硬链接说明

硬链接 BGmi 下载的新番资源，改善文件格式以便于自动化刮削，并且不会影响保种。

硬链接后的目录格式用于刮削器的自动识别，配置正确的话可以完全避免刮削。目前的配置适用于 Jellyfin 的刮削器，
理论上也可适用于绝大多数刮削器。

- 番剧存储于文件夹 `BANGUMI_FOLDER_FORMAT` 下。默认格式是 `{name}`，如“小林家的龙女仆”。
  也可以设置为嵌套，如 `{name}/Season {season}`，即“小林家的龙女仆/Season 2”。
- 番剧的命名格式为 `BANGUMI_FILE_FORMAT`，默认是 `S{season:0>2d}E{episode:0>2d}.{format}`。
  如“S01E01.mp4”。