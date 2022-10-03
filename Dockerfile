FROM ddsderek/bgmi-docker-all-in-one:base

LABEL maintainer="ddsrem@163.com"

ENV BGMI_TAG=v2.2.13

ENV BGMI_PATH="/bgmi/conf/bgmi" \
    LANG=C.UTF-8 \
    DOWNLOAD_DIR=/media/downloads \
    RCLONE_CONFIG=/bgmi/conf/rclone/rclone.conf \
    UPDATE_TRACKERS=true \
    CUSTOM_TRACKER_URL= \
    LISTEN_PORT=6888 \
    RPC_PORT=6800 \
    RPC_SECRET= \
    DISK_CACHE= \
    IPV6_MODE= \
    UMASK=022 \
    SPECIAL_MODE= \
    DOWNLOADER=transmission \
    BGMI_SOURCE=mikan_project \
    BGMI_ADMIN_TOKEN=password \
    PUID=1000 \
    PGID=1000

COPY --chmod=755 ./ /home/bgmi-docker

RUN \
    ## 创建用户
    addgroup -S bgmi && \
    adduser -S bgmi -G bgmi -h /home/bgmi-docker && \
    usermod -s /bin/bash bgmi && \
    ## Bgmi程序主体下载安装
    mkdir -p \
        /home/bgmi-docker/BGmi && \
    wget \
        https://github.com/BGmi/BGmi/archive/refs/tags/${BGMI_TAG}.tar.gz \
        -O /home/bgmi-docker/bgmi.tar.gz \
    && \
    tar \
        -zxvf /home/bgmi-docker/bgmi.tar.gz \
        -C /home/bgmi-docker/BGmi \
        --strip-components 1 \
    && \
    mv \
        /home/bgmi-docker/config/crontab.sh \
        /home/bgmi-docker/BGmi/bgmi/others/crontab.sh \
    && \
    pip install \
        /home/bgmi-docker/BGmi \
    && \
    ## transmission-web-control安装
    echo 1 | bash /home/bgmi-docker/dl_tools/transmission/install-tr-control-cn.sh && \
    ## Aria2-Pro安装
    curl -fsSL git.io/aria2c.sh | bash && \
    ## 清理
    rm -rf \
        /home/bgmi-docker/bgmi.tar.gz \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*


VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]
