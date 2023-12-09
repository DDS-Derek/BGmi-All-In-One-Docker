# syntax=docker/dockerfile:1

FROM python:3.11.7-alpine3.19

LABEL maintainer="ddstomo@gmail.com"

ARG BGMI_VERSION

ENV LANG=C.UTF-8 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    S6_SERVICES_GRACETIME=30000 \
    S6_KILL_GRACETIME=60000 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SYNC_DISKS=1 \
    BGMI_PATH="/bgmi/conf/bgmi" \
    BGMI_HARDLINK_PATH="/bgmi/conf/bgmi_hardlink" \
    BGMI_HOME="/home/bgmi-docker" \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    # 注意：这两个目录必须在 /media 下
    DOWNLOAD_DIR=/media/downloads \
    MEDIA_DIR=/media/cartoon \
    BGMI_HTTP_ADMIN_TOKEN=password \
    BGMI_DATA_SOURCE=mikan_project

COPY --from=powerman/dockerize:0.19.0 /usr/local/bin/dockerize /usr/local/bin

RUN set -ex && \
    dockerize --version && \
    apk add --no-cache \
        nginx \
        bash \
        curl \
        tzdata \
        shadow \
        jq \
        grep \
        ca-certificates \
        coreutils \
        netcat-openbsd \
        procps-ng \
        findutils \
        s6-overlay && \
    pip install --upgrade pip && \
    nginx -v && \
    crond --help && \
    # Adduser
    mkdir ${BGMI_HOME} /versions && \
    addgroup -S bgmi -g 911 && \
    adduser -S bgmi -G bgmi -h ${BGMI_HOME} -u 911 -s /bin/bash bgmi && \
    # BGmi install
    echo ${BGMI_VERSION} > /versions/BGMI_VERSION.txt && \
    mkdir -p ${BGMI_HOME}/BGmi && \
    curl \
        -sL https://github.com/BGmi/BGmi/archive/refs/tags/${BGMI_VERSION}.tar.gz | \
        tar -zxvf - --strip-components 1 -C ${BGMI_HOME}/BGmi && \
    pip install ${BGMI_HOME}/BGmi && \
    bgmi --help && \
    bgmi_http --help && \
    # Filebrowser install
    touch /tmp/filebrowser_install.sh && \
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh -o /tmp/filebrowser_install.sh && \
    echo 'echo ${filemanager_tag} > /versions/FILEBROWSER_VERSION.txt' >> /tmp/filebrowser_install.sh && \
    bash /tmp/filebrowser_install.sh && \
    filebrowser version && \
    # Clear
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*

COPY --chmod=755 ./rootfs /

ENTRYPOINT [ "/init" ]

VOLUME [ "/bgmi", "/media" ]

EXPOSE 80

# Test Aria2

ENV ARIA2_UPDATE_TRACKERS=true \
    ARIA2_CUSTOM_TRACKER_URL= \
    ARIA2_LISTEN_PORT=6888 \
    ARIA2_RPC_PORT=6800 \
    ARIA2_RPC_SECRET=password \
    ARIA2_DISK_CACHE= \
    ARIA2_IPV6_MODE= \
    ARIA2_SPECIAL_MODE=

RUN set -ex && \
    # Aria2-Pro install
    curl --insecure -fsSL https://raw.githubusercontent.com/P3TERX/aria2-builder/master/aria2-install.sh | bash && \
    echo $(aria2c --version) > /versions/ARIA2C_VERSION.txt && \
    # AriaNg install
    mkdir -p ${BGMI_HOME}/downloader/aria2/ariang && \
    ARIANG_TAG=$(curl -s "https://api.github.com/repos/mayswind/AriaNg/releases/latest" | jq -r .tag_name) && \
    echo ${ARIANG_TAG} > /versions/ARIANG_VERSION.txt && \
    curl \
        -sL https://github.com/mayswind/AriaNg/releases/download/${ARIANG_TAG}/AriaNg-${ARIANG_TAG}.zip | \
        busybox unzip -qd ${BGMI_HOME}/downloader/aria2/ariang - && \
    aria2c --version

# Test Transmission

ARG TRANSMISSION_WEB_HOME

ENV BGMI_VERSION=transmission

RUN set -ex && \
    # Transmission install
    mkdir /tmp/version && \
    curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.18/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp/version && \
    TRANSMISSION_VERSION=$(awk '/^P:transmission$/,/V:/' /tmp/version/APKINDEX | sed -n 2p | sed 's/^V://') && \
    apk add --update --no-cache \
        transmission-cli==${TRANSMISSION_VERSION} \
        transmission-daemon==${TRANSMISSION_VERSION} && \
    transmission-daemon --version && \
    # Transmission Web Control install
    mv ${TRANSMISSION_WEB_HOME}/index.html ${TRANSMISSION_WEB_HOME}/index.original.html && \
    mkdir /tmp/web && \
    TRANSMISSION_WEB_CONTROL_VERSION=$(curl -s https://api.github.com/repos/transmission-web-control/transmission-web-control/releases/latest | jq -r '.tag_name') && \
    curl -sL https://github.com/transmission-web-control/transmission-web-control/releases/download/${TRANSMISSION_WEB_CONTROL_VERSION}/dist.tar.gz | \
    tar xzpf - --strip-components=1 -C /tmp/web && \
    cp -r /tmp/web/dist/* ${TRANSMISSION_WEB_HOME} && \
    # Write version
    echo ${TRANSMISSION_VERSION} > /versions/TRANSMISSION_VERSION.txt && \
    echo ${TRANSMISSION_WEB_CONTROL_VERSION} > /versions/TRANSMISSION_WEB_CONTROL_VERSION.txt && \
    # Clear
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
