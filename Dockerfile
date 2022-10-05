FROM ddsderek/bgmi-docker-all-in-one:base

LABEL maintainer="ddsrem@163.com"

# BGmi版本
ENV BGMI_TAG=v2.2.13

ENV LANG=C.UTF-8

# 程序默认变量，不能修改
ENV BGMI_PATH="/bgmi/conf/bgmi" \
    BGMI_HOME="/home/bgmi-docker" \
    DOWNLOAD_DIR=/media/downloads \
    RCLONE_CONFIG=/bgmi/conf/rclone/rclone.conf

# BGmi 设置
ENV BGMI_SOURCE=mikan_project \
    BGMI_ADMIN_TOKEN=password \
    BGMI_DOWNLOADER=transmission

# Aria2-Pro 设置
ENV UPDATE_TRACKERS=true \
    CUSTOM_TRACKER_URL= \
    LISTEN_PORT=6888 \
    RPC_PORT=6800 \
    RPC_SECRET=password \
    DISK_CACHE= \
    IPV6_MODE= \
    SPECIAL_MODE=

# 权限设置
ENV PUID=1000 \
    PGID=1000 \
    UMASK=022


COPY --chmod=755 ./ /home/bgmi-docker

RUN \
    ## 创建用户
    addgroup -S bgmi && \
    adduser -S bgmi -G bgmi -h /home/bgmi-docker && \
    usermod -s /bin/bash bgmi && \
    ## Bgmi程序主体下载安装
    mkdir -p \
        ${BGMI_HOME}/BGmi && \
    wget \
        https://github.com/BGmi/BGmi/archive/refs/tags/${BGMI_TAG}.tar.gz \
        -O ${BGMI_HOME}/bgmi.tar.gz \
    && \
    tar \
        -zxvf ${BGMI_HOME}/bgmi.tar.gz \
        -C ${BGMI_HOME}/BGmi \
        --strip-components 1 \
    && \
    mv \
        ${BGMI_HOME}/config/crontab.sh \
        ${BGMI_HOME}/BGmi/bgmi/others/crontab.sh \
    && \
    pip install \
        ${BGMI_HOME}/BGmi \
    && \
    ## transmission-web-control安装
    echo 1 | bash ${BGMI_HOME}/dl_tools/transmission/install-tr-control-cn.sh && \
    ## Aria2-Pro安装
    curl -fsSL git.io/aria2c.sh | bash && \
    ## 清理
    rm -rf \
        ${BGMI_HOME}/bgmi.tar.gz \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*


VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]
