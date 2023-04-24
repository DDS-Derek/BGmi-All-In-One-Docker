ARG BGMI_TAG

FROM ddsderek/bgmi-all-in-one:${BGMI_TAG}

ENV BGMI_VERSION=transmission

RUN set -ex && \
    # Transmission install
    apk add --no-cache transmission-daemon && \
    # Transmission Web Control install
    mv /usr/share/transmission/web/index.html /usr/share/transmission/web/index.original.html && \
    mkdir /tmp/web && \
    curl -sL https://github.com/transmission-web-control/transmission-web-control/releases/latest/download/dist.tar.gz | \
    tar xzvpf - --strip-components=1 -C /tmp/web && \
    cp -r /tmp/web/dist/* /usr/share/transmission/web && \
    # Clear
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
