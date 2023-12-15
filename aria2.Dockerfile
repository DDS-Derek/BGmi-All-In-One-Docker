# syntax=docker/dockerfile:1

ARG RELEASE_VERSION

FROM ddsderek/bgmi-all-in-one:${RELEASE_VERSION}

ENV BGMI_VERSION=aria2 \
    ARIA2_UPDATE_TRACKERS=true \
    ARIA2_CUSTOM_TRACKER_URL=https://raw.githubusercontent.com/DDS-Derek/Aria2-Pro-Docker/main/tracker/all.list \
    ARIA2_LISTEN_PORT=6888 \
    ARIA2_RPC_PORT=6800 \
    ARIA2_RPC_SECRET=password \
    ARIA2_DISK_CACHE= \
    ARIA2_IPV6_MODE=

RUN set -ex && \
    apk add --no-cache \
        iptables \
        ip6tables \
        ipset \
        libcap \
        nodejs \
        npm && \
    curl -fsSL git.io/aria2c.sh | bash && \
    npm i -g aria2b && \
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
    aria2c --version && \
    # Clear
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*