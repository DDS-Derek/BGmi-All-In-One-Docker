FROM codysk/bgmi-all-in-one-base:1.2

LABEL maintainer="ddsrem@163.com"

ENV LANG=C.UTF-8 \
    DOWNLOAD_DIR=/media/downloads \
    RCLONE_CONFIG=/bgmi/conf/rclone/rclone.conf \
    UPDATE_TRACKERS=true \
    CUSTOM_TRACKER_URL= \
    LISTEN_PORT=6888 \
    RPC_PORT=6800 \
    RPC_SECRET= \
    DISK_CACHE= \
    IPV6_MODE= \
    UMASK_SET= \
    SPECIAL_MODE= \
    BGMI_PATH="/bgmi/conf/bgmi" \
    DOWNLOADER=transmission \
    BGMI_SOURCE=mikan_project \
    BGMI_ADMIN_TOKEN=password \
    PUID=1000 \
    PGID=1000

COPY --chmod=755 ./ /home/bgmi-docker

RUN \
    ## 安装软件包
    apk add --update --no-cache \
    wget \
    zip \
    shadow \
    jq \
    findutils \
    && \
    ## 创建用户
    addgroup -S bgmi && \
    adduser -S bgmi -G bgmi -h /home/bgmi && \
    usermod -s /bin/bash bgmi && \
    ## Bgmi程序主体下载安装
    mkdir -p /home/bgmi-docker && \
    cd /home/bgmi-docker && \
    wget https://github.com/BGmi/BGmi/archive/refs/heads/master.zip && \
    unzip /home/bgmi-docker/master.zip && \
    mv /home/bgmi-docker/BGmi-master /home/bgmi-docker/BGmi && \
    mv /home/bgmi-docker/config/crontab.sh /home/bgmi-docker/BGmi/bgmi/others/crontab.sh && \
    pip install /home/bgmi-docker/BGmi && \
    ## transmission-web-control安装
    cd /home/bgmi-docker/dl_tools/transmission && \
    echo 1 | bash install-tr-control-cn.sh && \
    ## Aria2-Pro安装
    curl -fsSL git.io/aria2c.sh | bash && \
    ## 清理
    rm -rf /home/bgmi-docker/master.zip && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    rm -rf /tmp/*


VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]
