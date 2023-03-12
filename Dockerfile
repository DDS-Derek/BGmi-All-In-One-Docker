FROM alpine:3.17

LABEL maintainer="ddsrem@163.com"

# BGmi版本
ARG BGMI_TAG=v2.3.1
# Ariang版本
ARG ARIANG_TAG=1.3.3
# bgmi_archive_frontend版本
ARG bgmi_archive_frontend_TAG=0.0.4

ENV LANG=C.UTF-8 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    BGMI_PATH="/bgmi/conf/bgmi" \
    BGMI_HOME="/home/bgmi-docker" \
    RCLONE_CONFIG=/bgmi/conf/rclone/rclone.conf \
    # 权限设置
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    # BGmi 设置
    BGMI_SOURCE=mikan_project \
    BGMI_ADMIN_TOKEN=password \
    BGMI_DOWNLOADER=transmission \
    # DIR 设置
    # 注意：这两个目录必须在 /media 下
    DOWNLOAD_DIR=/media/downloads \
    MEDIA_DIR=/media/cartoon \
    # Aria2-Pro 设置
    UPDATE_TRACKERS=true \
    CUSTOM_TRACKER_URL= \
    LISTEN_PORT=6888 \
    RPC_PORT=6800 \
    RPC_SECRET=password \
    DISK_CACHE= \
    IPV6_MODE= \
    SPECIAL_MODE=

RUN \
    ## Base
    apk add --no-cache \
        linux-headers \
        python3-dev \
        py3-pip \
        python3 \
        nginx \
        bash \
        supervisor \
        transmission-daemon \
        curl \
        tzdata \
        shadow \
        jq \
        findutils \
        su-exec \
        dumb-init \
    && \
    apk add --no-cache --virtual=build-dependencies \
        zip \
        unzip \
        tar \
        git \
        build-base \
        gcc \
        musl-dev \
        libxslt-dev \
        zlib-dev \
        libxml2-dev \
        libffi-dev \
        openssl-dev \
        cargo \
    && \
    pip install --upgrade pip setuptools wheel && \
    pip install 'transmissionrpc' && \
    ## Master
    addgroup \
        -S bgmi \
        -g ${PGID} \
    && \
    adduser \
        -S bgmi \
        -G bgmi \
        -h ${BGMI_HOME} \
        -u ${PUID} \
    && \
    usermod \
        -s /bin/bash bgmi \
    && \
    ## Bgmi程序主体下载安装
    mkdir -p \
        ${BGMI_HOME}/BGmi \
    && \
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
    mkdir -p \
        /home/bgmi-docker/bgmi-archive-frontend \
    && \
    wget \
        https://github.com/codysk/BGmi-archive-frontend/releases/download/${bgmi_archive_frontend_TAG}/bgmi-archive-frontend.tgz \
        -O ${BGMI_HOME}/bgmi-archive-frontend.tgz \
    && \
    tar \
        -zxvf ${BGMI_HOME}/bgmi-archive-frontend.tgz \
        -C ${BGMI_HOME}/bgmi-archive-frontend \
        --strip-components 1 \
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
    mkdir -p \
        ${BGMI_HOME}/dl_tools/aria2 \
    && \
    wget \
        https://raw.githubusercontent.com/P3TERX/aria2-builder/master/aria2-install.sh \
        -O ${BGMI_HOME}/dl_tools/aria2/aria2-install.sh \
    && \
    chmod \
        +x ${BGMI_HOME}/dl_tools/aria2/aria2-install.sh \
    && \
    bash ${BGMI_HOME}/dl_tools/aria2/aria2-install.sh \
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
    ## Hardlink 安装
    ## kaaass/bgmi_hardlink_helper
    git clone \
        https://github.com/album-GitHub/bgmi_hardlink_helper.git \
        ${BGMI_HOME}/bgmi_hardlink_helper \
    && \
    apk del --purge \
        build-dependencies \
    && \
    ## 清理
    rm -rf \
        ${BGMI_HOME}/bgmi.tar.gz \
        ${BGMI_HOME}/bgmi-archive-frontend.tgz \
        ${BGMI_HOME}/dl_tools/aria2/ariang/ariang.zip \
        ${BGMI_HOME}/bgmi_hardlink_helper/.git \
        ${BGMI_HOME}/dl_tools/aria2/aria2-install.sh \
        ${BGMI_HOME}/dl_tools/transmission/install-tr-control-cn.sh \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*

COPY --chmod=755 . /home/bgmi-docker

VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]
