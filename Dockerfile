FROM ddsderek/bgmi-docker-all-in-one:base

LABEL maintainer="ddsrem@163.com"

# BGmi版本
ENV BGMI_TAG=v2.2.17
# Ariang版本
ENV ARIANG_TAG=1.3.2

ENV LANG=C.UTF-8

# 程序默认变量，不能修改
ENV BGMI_PATH="/bgmi/conf/bgmi" \
    BGMI_HOME="/home/bgmi-docker" \
    RCLONE_CONFIG=/bgmi/conf/rclone/rclone.conf

# 权限设置
ENV PUID=1000 \
    PGID=1000 \
    UMASK=022

# BGmi 设置
ENV BGMI_SOURCE=mikan_project \
    BGMI_ADMIN_TOKEN=password \
    BGMI_DOWNLOADER=transmission

# DIR 设置
# 注意：这两个目录必须在 /media 下
ENV DOWNLOAD_DIR=/media/downloads \
    MEDIA_DIR=/media/cartoon

# Aria2-Pro 设置
ENV UPDATE_TRACKERS=true \
    CUSTOM_TRACKER_URL= \
    LISTEN_PORT=6888 \
    RPC_PORT=6800 \
    RPC_SECRET=password \
    DISK_CACHE= \
    IPV6_MODE= \
    SPECIAL_MODE=

# Transmission 设置
#ENV TR_USER=bgmi \
#    TR_PASS=password \
#    TR_PEERPORT=51413

RUN \
    ## 创建用户
    addgroup \
        -S bgmi \
        -g 1000 \
    && \
    adduser \
        -S bgmi \
        -G bgmi \
        -h /home/bgmi-docker \
        -u 1000 \
    && \
    usermod \
        -s /bin/bash bgmi \
    && \
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
    pip install \
        ${BGMI_HOME}/BGmi \
    && \
    ## Transmission Web Control 安装
    mkdir -p \
        ${BGMI_HOME}/dl_tools/transmission \
    && \
    wget \
        https://raw.githubusercontent.com/ronggang/transmission-web-control/master/release/install-tr-control-cn.sh \
        -O ${BGMI_HOME}/dl_tools/transmission/install-tr-control-cn.sh \
    && \
    chmod \
        +x ${BGMI_HOME}/dl_tools/transmission/install-tr-control-cn.sh \
    && \
    echo 1 | bash ${BGMI_HOME}/dl_tools/transmission/install-tr-control-cn.sh \
    && \
    ## Aria2-Pro 安装
    curl -fsSL git.io/aria2c.sh | bash \
    && \
    ## AriaNg 安装
    mkdir -p \
        ${BGMI_HOME}/dl_tools/aria2/ariang \
    && \
    wget \
        https://github.com/mayswind/AriaNg/releases/download/${ARIANG_TAG}/AriaNg-${ARIANG_TAG}.zip \
        -O ${BGMI_HOME}/dl_tools/aria2/ariang/ariang.zip \
    && \
    unzip \
        -d ${BGMI_HOME}/dl_tools/aria2/ariang \
        ${BGMI_HOME}/dl_tools/aria2/ariang/ariang.zip \
    && \
    ## rclone 安装
    curl -fsSL https://rclone.org/install.sh | bash \
    && \
    ## Hardlink 安装
    git clone \
        https://github.com/album-GitHub/bgmi_hardlink_helper.git \
        ${BGMI_HOME}/bgmi_hardlink_helper \
    && \
    git clone \
        https://github.com/kaaass/bgmi_hardlink_helper.git \
        ${BGMI_HOME}/bgmi_hardlink_helper_old_1 \
    && \
    ## 清理
    rm -rf \
        ${BGMI_HOME}/bgmi.tar.gz \
        ${BGMI_HOME}/dl_tools/aria2/ariang/ariang.zip \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*

COPY --chmod=755 . /home/bgmi-docker
COPY --chmod=755 ./scripts /usr/local/bin

VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]
