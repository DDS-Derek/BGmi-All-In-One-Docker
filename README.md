# bgmi-docker-all-in-one
由https://github.com/codysk/bgmi-docker-all-in-one 镜像改编

- [bgmi-docker-all-in-one](#bgmi-docker-all-in-one)
  - [新增功能](#新增功能)
  - [部署](#部署)
    - [docker-cli](#docker-cli)
    - [docker-compose](#docker-compose)
  - [参数说明](#参数说明)
  - [PUID GUID 说明](#puid-guid-说明)
  - [硬链接说明](#硬链接说明)

## 新增功能
1. 支持硬链接，硬链接工具由[kaaass](https://github.com/kaaass/bgmi_hardlink_helper)大佬提供 (具体说明请看下方[硬链接介绍](https://github.com/DDS-Derek/bgmi-docker-all-in-one#%E7%A1%AC%E9%93%BE%E6%8E%A5%E8%AF%B4%E6%98%8E))
2. 支持PUID和PGID设置
3. 支持内部aria2，transmission下载器，可以在环境变量内设置是否启用
4. 支持transmission增强版UI，可以在环境变量内设置是否启用
4. 添加ariang管理界面

## 部署
### docker-cli

```bash
docker run -itd \
  --name=bgmi \
  --restart always \
  -v /bgmi:/bgmi \
  -v /home/video2/NEW:/media \
  -p 80:80 \
  -p 9091:9091 \
  -p 6800:6800 \
  -p 6880:6880 \
  -p 51413:51413/tcp \
  -p 51413:51413/udp \
  -e TZ=Asia/Shanghai \
  -e PGID=1000 \
  -e PUID=1000 \
  -e DOWNLOADER=transmission \
  -e BGMI_SOURCE=mikan_project \
  -e BGMI_ADMIN_TOKEN=password \
  ddsderek/bgmi-docker-all-in-one:latest
```
### docker-compose

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
            - '6800:6800'
            - '6880:6880'
            - '51413:51413/tcp'
            - '51413:51413/udp'
        environment:
          - TZ=Asia/Shanghai
          - PGID=1000
          - PUID=1000
          - DOWNLOADER=transmission
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
```

## 参数说明

|                     Parameter                     | Function                                                     |
| :-----------------------------------------------: | ------------------------------------------------------------ |
|                     -p 80:80                      | BGMI Web端口                                                 |
|                   -p 9091:9091                    | transmission web端口 当下载器设置为```-e DOWNLOADER=transmission```时，需要映射```9091```端口，```6800```和```6880```端口无需映射 |
|                   -p 6800:6800                    | aria2 端口 当下载器设置为```-e DOWNLOADER=aria2```时，需要映射```6800```和```6880```端口，```9091```端口无需映射 |
|                   -p 6880:6880                    | ariang Web端口                                               |
|                -p 51413:51413/tcp                 | Torrent 端口 TCP                                             |
|                -p 51413:51413/udp                 | Torrent 端口 UDP                                             |
|                   -e PGID=1000                    | 对于 GroupID - 请参阅下面的[说明](https://github.com/DDS-Derek/bgmi-docker-all-in-one#puid-guid-%E8%AF%B4%E6%98%8E) |
|                   -e PUID=1000                    | 对于 UserID - 请参阅下面的说明[说明](https://github.com/DDS-Derek/bgmi-docker-all-in-one#puid-guid-%E8%AF%B4%E6%98%8E) |
|                -e TZ=Asia/Shanghai                | 时区                                                         |
| -e DOWNLOADER=transmission \| -e DOWNLOADER=aria2 | 内部下载器，内置aria2，transmission和false(关闭)，可以自行选择            |
|           -e BGMI_SOURCE=mikan_project            | BGMI 默认数据源（bangumi_moe、mikan_project 或 dmhy）        |
|           -e BGMI_ADMIN_TOKEN=password            | 设置 BGMI Web 界面身份验证令牌                               |
|                  -v /bgmi:/bgmi                   | BGMI 配置文件目录                                            |
|            -v /home/video2/NEW:/media             | 媒体文件目录，包含下载文件和硬链接后的文件                   |

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

- 番剧默认下载目录为```/meida/downloads```，下载目录的番剧格式为BGMI官方的原格式
- 番剧硬链接后存储于文件夹 `/media/cartoon` 下。默认格式是 `{name}`，如“小林家的龙女仆”。
  也可以设置为嵌套，如 `{name}/Season {season}`，即“小林家的龙女仆/Season 2”。
- 番剧的命名格式为 `BANGUMI_FILE_FORMAT`，默认是 `S{season:0>2d}E{episode:0>2d}.{format}`。
  如“S01E01.mp4”。

