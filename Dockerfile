# syntax=docker/dockerfile:1

FROM python:3.11.7-alpine3.20

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
