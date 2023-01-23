# BGmi All In One Docker

[![Build](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/actions/workflows/docker-image.yml)
[![Build-Base](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/actions/workflows/docker-base-image.yml/badge.svg)](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/actions/workflows/docker-base-image.yml)

> English | [中文](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/README.cn.md)

**Note that the Dockerhub repository was changed from `ddsderek/bgmi-docker-all-in-one` to `ddsderek/bgmi-all-in-one`**

Made from a image of https://github.com/codysk/bgmi-docker-all-in-one.

## New features
1. Hard linking, hard linking tool provided by [kaaass](https://github.com/kaaass/bgmi_hardlink_helper)
2. PUID and PGID settings.
3. Umask settings.
4. The internal aria2-pro, transmission downloader, can be set within the environment variables to enable or disable it.
5. Transmission Web Control.
6. Ariang management interface.
7. Common Scripts `bgmi_hardlink` `bgmi_download`。

## Introduction to BGmi

[Official introduction and usage](https://github.com/BGmi/BGmi/blob/master/README.md)

## Deployment
### docker-cli

**Transmission**

> Note: The image has a built-in Transmission Web Control management interface, access `IP:PORT/tr`, this `PORT` is the same port as the access to the BGmi Web port

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
  -e BGMI_DOWNLOADER=transmission \
  -e BGMI_SOURCE=mikan_project \
  -e BGMI_ADMIN_TOKEN=password \
  -e TR_USER=bgmi \
  -e TR_PASS=password \
  -e TR_PEERPORT=51413 \
  ddsderek/bgmi-all-in-one:latest
```

**Aria2**

> Note: The image has a built-in Ariang management interface, access `IP:PORT/ariang`, this `PORT` is the same port as the access to the BGmi web port

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
  -e BGMI_DOWNLOADER=aria2 \
  -e BGMI_SOURCE=mikan_project \
  -e BGMI_ADMIN_TOKEN=password \
  -e UPDATE_TRACKERS=true \
  -e CUSTOM_TRACKER_URL= \
  -e LISTEN_PORT=6888 \
  -e RPC_PORT=6800 \
  -e RPC_SECRET= \
  -e DISK_CACHE= \
  -e IPV6_MODE= \
  -e SPECIAL_MODE= \
  ddsderek/bgmi-all-in-one:latest
```

**Not using the built-in downloader**

```bash
docker run -itd \
  --name=bgmi \
  --restart always \
  -v /bgmi:/bgmi \
  -v /media:/media \
  -p 80:80 \
  -e TZ=Asia/Shanghai \
  -e PGID=1000 \
  -e PUID=1000 \
  -e UMASK=022 \
  -e MEDIA_DIR=/media/cartoon \
  -e DOWNLOAD_DIR=/media/downloads \
  -e BGMI_DOWNLOADER=false \
  -e BGMI_SOURCE=mikan_project \
  -e BGMI_ADMIN_TOKEN=password \
  ddsderek/bgmi-all-in-one:latest
```

### docker-compose

**transmission**

[docker-compose](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/example/transmission/docker-compose.yml)

**Aria2**

[docker-compose](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/example/aria2-pro/docker-compose.yml)

**Not using the built-in downloader**

[docker-compose](https://github.com/DDS-Derek/BGmi-All-In-One-Docker/blob/master/example/default/docker-compose.yml)

## Description of parameters

### BGmi

|         Parameter          |                            Function                            |
| :-------------------: | :--------------------------------------------------------: |
|        `-e TZ`        |                          Time zone settings                          |
|       `-e PUID`       |                       Launcher User ID                       |
|       `-e PGID`       |                      Launcher User Group ID                      |
|      `-e UMASK`       |                          Permission Mask                          |
|    `-e MEDIA_DIR`     |         BGmi hard link directory (directory must be under `/media`)          |
|   `-e DOWNLOAD_DIR`   |          BGmi download directory (directory must be under `/media`)           |
| `-e BGMI_DOWNLOADER`  |     BGmi downloader (optional `transmission` `aria2` `false`)     |
|   `-e BGMI_SOURCE`    | set bgmi default data source (bangumi_moe, mikan_project or dmhy) |
| `-e BGMI_ADMIN_TOKEN` |               Setting up the BGMI web interface authentication token               |
|        `-p 80`        |                       BGmi Web Port                        |
|      `-v /bgmi`       |                          Configuration files                          |
|      `-v /media`      |            Media folder containing download files and hard link files            |

### Transmission

|       参数       |           作用            |
| :--------------: | :-----------------------: |
|   `-e TR_USER`   | Transmission Web Login Users |
|   `-e TR_PASS`   | Transmission Web Login Password |
| `-e TR_PEERPORT` |      Seed transfer port       |

### Aria2

This image is built to use Aria2-Pro, see [Aria2-Pro-Docker Official Instructions](https://github.com/P3TERX/Aria2-Pro-Docker#parameters) for specific parameters.

## PUID GUID

When using the volume (`-v` flag) permission issue between the host OS and the container, we avoid this issue `PGID` by allowing you to specify the user `PUID` and group.

Ensure that any volume directories on the host are owned by the same user you specify and that any permissions issues disappear like magic.

In this case `PUID=1000` and `PGID=1000` find your usage `id user` as follows.

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## HardLink

Hard-linked BGmi downloads of new resources, with improved file formatting for automated scraping and no impact on seed preservation.

The hard-linked directory format is used for automatic recognition by the scraper and can be configured correctly to avoid scraping altogether. The current configuration works with Jellyfin's scrapers.
Theoretically it will also work with most scrapers.

- The default download directory is ``/meida/downloads`` and the download directory is in the official BGMI format.
- The cartoons are hard-linked and stored in the ``/media/cartoon`` folder. The default format is `{name}`, e.g. "The Dragon Maid of the Kobayashi Family".
  It can also be nested, e.g. `{name}/Season {season}`, i.e. "Kobayashi's Dragon Maid/Season 2".
- The format for naming episodes is `BANGUMI_FILE_FORMAT`, the default is `S{season:0>2d}E{episode:0>2d}. {format}`.
  For example, `S03E01.mp4`.

