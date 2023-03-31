FROM alpine

RUN apk add --no-cache --virtual=build-dependencies \
        libffi-dev \
        libxml2-dev \
        musl-dev \
        libxslt-dev \
        python3-dev \
        gcc \
    && apk add --no-cache \
        git \
        python3 \
        py3-pip \
        tzdata \
        su-exec \
        zip \
        curl \
        bash \
        fuse \
        inotify-tools \
        npm \
        dumb-init \
        wget \
        shadow \
        sudo \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && pip install --upgrade pip setuptools wheel \
    && pip install cython \
    && pip install -r https://raw.githubusercontent.com/NAStool/nas-tools/master/requirements.txt \
    && npm install pm2 -g \
    && apk del --purge build-dependencies \
    && rm -rf /tmp/* /root/.cache /var/cache/apk/*
ENV LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    NASTOOL_CONFIG="/config/config.yaml" \
    NASTOOL_VERSION=master \
    PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    REPO_URL="https://github.com/NAStool/nas-tools.git" \
    PUID=0 \
    PGID=0 \
    UMASK=000 \
    WORKDIR="/nas-tools" \
    NT_HOME="/nt" \
    DOWNLOAD_DIR=/media/downloads \
    MEDIA_DIR=/media/cartoon
WORKDIR ${WORKDIR}
RUN mkdir ${NT_HOME} \
    && addgroup -S nt -g 911 \
    && adduser -S nt -G nt -h ${NT_HOME} -s /bin/bash -u 911 \
    && python_ver=$(python3 -V | awk '{print $2}') \
    && echo "${WORKDIR}/" > /usr/lib/python${python_ver%.*}/site-packages/nas-tools.pth \
    && echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf \
    && echo "nt ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && git config --global pull.ff only \
    && git clone -b master ${REPO_URL} ${WORKDIR} --depth=1 --recurse-submodule \
    && git config --global --add safe.directory ${WORKDIR} \
    && rm -rf ${WORKDIR}/docker/entrypoint.sh
COPY --chmod=755 ./NAStool/entrypoint.sh ${WORKDIR}/docker/entrypoint.sh
EXPOSE 3000
VOLUME [ "/config", "/media" ]
ENTRYPOINT ["/nas-tools/docker/entrypoint.sh"]