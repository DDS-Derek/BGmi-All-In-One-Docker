FROM alpine:3.17

ARG NAStool_TAG=v3.1.3

ENV LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    NASTOOL_CONFIG="/config/config.yaml" \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    PUID=1000 \
    PGID=1000 \
    UMASK=022 \
    NT_HOME="/nt" \
    DOWNLOAD_DIR=/media/downloads \
    MEDIA_DIR=/media/cartoon

RUN set -ex && \
    apk add --no-cache \
        tzdata \
        zip \
        curl \
        bash \
        inotify-tools \
        s6-overlay \
        wget \
        shadow \
        sudo && \
    # Install NAStool
    if [ "$(uname -m)" = "x86_64" ]; then ARCH=amd64; elif [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi && \
    wget \
        https://github.com/NAStool/nas-tools/releases/download/${NAStool_TAG}/nastool_linux_musl_${ARCH}_${NAStool_TAG} \
        -O /usr/bin/nas-tools && \
    chmod +x /usr/bin/nas-tools && \
    # Add user
    mkdir ${NT_HOME} && \
    addgroup -S nt -g 911 && \
    adduser -S nt -G nt -h ${NT_HOME} -s /bin/bash -u 911 && \
    # Set inotify
    echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf && \
    echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf && \
    # Set sudo
    echo "nt ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # Clear
    rm -rf \
        /tmp/* \
        /root/.cache \
        /var/cache/apk/*

COPY --chmod=755 ./NAStool /

ENTRYPOINT [ "/init" ]

VOLUME [ "/config", "/media" ]
EXPOSE 3000