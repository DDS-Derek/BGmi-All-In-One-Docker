FROM codysk/bgmi-all-in-one-base:1.2

LABEL maintainer="ddsrem@163.com"

ENV LANG=C.UTF-8 BGMI_PATH="/bgmi/conf/bgmi" DOWNLOADER=transmission BGMI_SOURCE=mikan_project BGMI_ADMIN_TOKEN=password PUID=1000 PGID=1000

ADD ./ /home/bgmi-docker

RUN \
    ## 安装软件包
    apk add --update --no-cache \
    wget \
    zip \
    shadow \
    aria2 && \
    ## 创建用户
    addgroup -S abc && \
    adduser -S abc -G abc -h /home/abc && \
    usermod -s /bin/bash abc && \
    ## Bgmi程序主体下载安装
    mkdir -p /home/bgmi-docker && \
    cd /home/bgmi-docker && \
    wget https://github.com/BGmi/BGmi/archive/refs/heads/master.zip && \
    unzip /home/bgmi-docker/master.zip && \
    mv /home/bgmi-docker/BGmi-master /home/bgmi-docker/BGmi && \
    mv /home/bgmi-docker/utils/crontab.sh /home/bgmi-docker/BGmi/bgmi/others/crontab.sh && \
    pip install /home/bgmi-docker/BGmi && \
    ## transmission-web-control安装
    cd /home/bgmi-docker/web/transmission && \
    echo 1 | bash install-tr-control-cn.sh && \
    ## 给予启动脚本权限
    chmod 755 /home/bgmi-docker/entrypoint.sh && \
    ## 清理
    rm -rf /home/bgmi-docker/master.zip && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    rm -rf /tmp/*

VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80 9091 51413/tcp 51413/udp

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]
