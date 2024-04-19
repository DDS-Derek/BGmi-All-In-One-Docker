# syntax=docker/dockerfile:1

ARG RELEASE_VERSION

FROM ddsderek/bgmi-all-in-one:${RELEASE_VERSION}

ARG TRANSMISSION_WEB_HOME

ENV BGMI_VERSION=transmission

RUN set -ex && \
    # Transmission install
    mkdir /tmp/version && \
    curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.19/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp/version && \
    TRANSMISSION_VERSION=$(awk '/^P:transmission$/,/V:/' /tmp/version/APKINDEX | sed -n 2p | sed 's/^V://') && \
    apk add --update --no-cache \
        transmission-cli==${TRANSMISSION_VERSION} \
        transmission-daemon==${TRANSMISSION_VERSION} && \
    transmission-daemon --version && \
    # Transmission Web Control install
    mv ${TRANSMISSION_WEB_HOME}/index.html ${TRANSMISSION_WEB_HOME}/index.original.html && \
    mkdir /tmp/web && \
    TRANSMISSION_WEB_CONTROL_VERSION=$(curl -s "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" | jq -r .tag_name) && \
    curl -sL "https://github.com/ronggang/transmission-web-control/archive/${TRANSMISSION_WEB_CONTROL_VERSION}.tar.gz" | \
    tar xzvpf - --strip-components=1 -C /tmp/web && \
    cp -r /tmp/web/src/* ${TRANSMISSION_WEB_HOME} && \
    # Write version
    echo ${TRANSMISSION_VERSION} > /versions/TRANSMISSION_VERSION.txt && \
    echo ${TRANSMISSION_WEB_CONTROL_VERSION} > /versions/TRANSMISSION_WEB_CONTROL_VERSION.txt && \
    # Clear
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
