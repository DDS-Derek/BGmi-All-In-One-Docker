ARG BGMI_TAG

FROM ddsderek/bgmi-all-in-one:${BGMI_TAG}

ENV BGMI_VERSION=transmission

RUN set -ex && \
    # Transmission install
    apk add --no-cache transmission-daemon && \
    # Transmission Web Control install
    wget \
        https://raw.githubusercontent.com/ronggang/transmission-web-control/master/release/install-tr-control-cn.sh \
        -O /tmp/install-tr-control-cn.sh && \
    chmod +x /tmp/install-tr-control-cn.sh && \
    echo 1 | bash /tmp/install-tr-control-cn.sh && \
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
