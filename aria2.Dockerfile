ARG BGMI_TAG

FROM ddsderek/bgmi-all-in-one:${BGMI_TAG}

ARG ARIANG_TAG=1.3.3
ENV BGMI_VERSION=aria2 \
    ARIA2_UPDATE_TRACKERS=true \
    ARIA2_CUSTOM_TRACKER_URL= \
    ARIA2_LISTEN_PORT=6888 \
    ARIA2_RPC_PORT=6800 \
    ARIA2_RPC_SECRET=password \
    ARIA2_DISK_CACHE= \
    ARIA2_IPV6_MODE= \
    ARIA2_SPECIAL_MODE=

RUN set -ex && \
    # Aria2-Pro install
    mkdir -p ${BGMI_HOME}/downloader/aria2 && \
    wget \
        https://raw.githubusercontent.com/P3TERX/aria2-builder/master/aria2-install.sh \
        -O ${BGMI_HOME}/downloader/aria2/aria2-install.sh && \
    chmod +x ${BGMI_HOME}/downloader/aria2/aria2-install.sh && \
    bash ${BGMI_HOME}/downloader/aria2/aria2-install.sh && \
    # AriaNg install
    mkdir -p ${BGMI_HOME}/downloader/aria2/ariang && \
    wget \
        https://github.com/mayswind/AriaNg/releases/download/${ARIANG_TAG}/AriaNg-${ARIANG_TAG}.zip \
        -O ${BGMI_HOME}/downloader/aria2/ariang/ariang.zip && \
    unzip \
        -d ${BGMI_HOME}/downloader/aria2/ariang \
        ${BGMI_HOME}/downloader/aria2/ariang/ariang.zip && \
    # Clear
    rm -rf \
        ${BGMI_HOME}/downloader/aria2/ariang/ariang.zip \
        ${BGMI_HOME}/downloader/aria2/aria2-install.sh \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
        