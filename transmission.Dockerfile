ARG BGMI_TAG

FROM ddsderek/bgmi-all-in-one:${BGMI_TAG}

ENV BGMI_VERSION=transmission

RUN set -ex && \
    # Transmission install
    apk add --no-cache transmission-daemon && \
    # Transmission Web Control install
    mkdir -p ${BGMI_HOME}/downloader/transmission && \
    wget \
        https://raw.githubusercontent.com/ronggang/transmission-web-control/master/release/install-tr-control-cn.sh \
        -O ${BGMI_HOME}/downloader/transmission/install-tr-control-cn.sh && \
    chmod +x ${BGMI_HOME}/downloader/transmission/install-tr-control-cn.sh && \
    echo 1 | bash ${BGMI_HOME}/downloader/transmission/install-tr-control-cn.sh && \
    rm -rf \
        ${BGMI_HOME}/downloader/transmission/install-tr-control-cn.sh \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
