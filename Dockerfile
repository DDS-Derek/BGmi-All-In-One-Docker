FROM alpine:3.17

LABEL maintainer="ddsrem@163.com"

ARG BGMI_TAG=v4.4.2

ENV LANG=C.UTF-8 \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
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

RUN set -ex && \
    apk add --no-cache \
        python3 \
        py3-pip \
        nginx \
        bash \
        supervisor \
        curl \
        tzdata \
        shadow \
        jq \
        findutils \
        su-exec \
        dumb-init && \
    pip install --upgrade pip setuptools wheel && \
    # Adduser
    mkdir /home/bgmi && \
    addgroup -S bgmi -g 911 && \
    adduser -S bgmi -G bgmi -h /home/bgmi -u 911 -s /bin/bash bgmi && \
    # BGmi install
    mkdir -p ${BGMI_HOME}/BGmi && \
    curl \
        -sL https://github.com/BGmi/BGmi/archive/refs/tags/${BGMI_TAG}.tar.gz | \
        tar -zxvf - --strip-components 1 -C ${BGMI_HOME}/BGmi && \
    pip install ${BGMI_HOME}/BGmi && \
    # Supervisor log dir
    mkdir -p ${BGMI_HOME}/log/supervisor && \
    # Clear
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*

COPY --from=powerman/dockerize:0.19.0 /usr/local/bin/dockerize /usr/local/bin
COPY --chmod=755 . /home/bgmi-docker

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]

VOLUME [ "/bgmi", "/media" ]

EXPOSE 80
