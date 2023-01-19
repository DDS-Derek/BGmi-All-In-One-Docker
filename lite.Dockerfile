FROM alpine:3.17

LABEL maintainer="ddsrem@163.com"

# BGmi版本
ENV BGMI_TAG=v2.2.17
# Ariang版本
ENV ARIANG_TAG=1.3.2

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
    ## 安装软件
    apk add --no-cache \
        linux-headers \
        python3-dev \
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
    && \
    ## 安装编译软件
    apk add --no-cache \
        zip \
        unzip \
        git \
        tini \
        gcc \
        musl-dev \
        libxslt-dev \
        zlib-dev \
        libxml2-dev \
        libffi-dev \
        openssl-dev \
        cargo \
    && \
    ## 安装 pip
    curl https://bootstrap.pypa.io/get-pip.py | python3 \
    && \
    ## 安装 cryptography
    pip install cryptography \
    && \
    ## 安装 transmissionrpc
    pip install 'transmissionrpc' \
    && \
    ## 创建用户
    addgroup \
        -S bgmi \
        -g ${PGID} \
    && \
    adduser \
        -S bgmi \
        -G bgmi \
        -h /home/bgmi-docker \
        -u ${PUID} \
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
    git clone \
        https://github.com/album-GitHub/bgmi_hardlink_helper.git \
        ${BGMI_HOME}/bgmi_hardlink_helper \
    && \
    apk del --purge \
        zip \
        unzip \
        git \
        tini \
        gcc \
        musl-dev \
        libxslt-dev \
        zlib-dev \
        libxml2-dev \
        libffi-dev \
        openssl-dev \
        cargo \
    && \
    ## 清理
    rm -rf \
        ${BGMI_HOME}/bgmi.tar.gz \
        ${BGMI_HOME}/dl_tools/aria2/ariang/ariang.zip \
        ${BGMI_HOME}/bgmi_hardlink_helper/.git \
        ${BGMI_HOME}/dl_tools/aria2/aria2-install.sh \
        ${BGMI_HOME}/dl_tools/transmission/install-tr-control-cn.sh \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*

COPY --chmod=755 . /home/bgmi-docker
COPY --chmod=755 ./scripts /usr/local/bin

VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]