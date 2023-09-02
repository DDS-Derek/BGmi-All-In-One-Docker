# syntax=docker/dockerfile:1

ARG RELEASE_VERSION

FROM ddsderek/bgmi-all-in-one:${RELEASE_VERSION}

ARG ALPINE_VERSION
ARG TRANSMISSION_WEB_HOME

ENV BGMI_VERSION=transmission

RUN set -ex && \
    # Transmission install
    mv /etc/apk/repositories /etc/apk/repositories_bak && \
    echo "https://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/main"         >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community"    >> /etc/apk/repositories && \
    mkdir /tmp/version && \
    curl -sL "http://dl-cdn.alpinelinux.org/alpine/${ALPINE_VERSION}/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp/version && \
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
    tar xzvpf - --strip-components=1 -C /tmp/web && \
    cp -r /tmp/web/dist/* ${TRANSMISSION_WEB_HOME} && \
    # Write version
    echo ${TRANSMISSION_VERSION} > /versions/TRANSMISSION_VERSION.txt && \
    echo ${TRANSMISSION_WEB_CONTROL_VERSION} > /versions/TRANSMISSION_WEB_CONTROL_VERSION.txt && \
    # Clear
    rm -rf /etc/apk/repositories && \
    mv /etc/apk/repositories_bak /etc/apk/repositories && \
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*
