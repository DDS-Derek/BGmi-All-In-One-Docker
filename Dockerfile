FROM alpine:3.12

ENV LANG=C.UTF-8 BGMI_PATH="/bgmi/conf/bgmi"
ENV PUID=1000
ENV PGID=1000
## true 和 false
ENV TRANSMISSION=true
## true 和 false
ENV TRANSMISSION_WEB_CONTROL=true

ADD ./ /home/bgmi-docker

RUN { \
	apk add --update linux-headers gcc python3-dev libffi-dev openssl-dev cargo libxslt-dev zlib-dev libxml2-dev musl-dev nginx bash supervisor transmission-daemon python3 cargo curl tzdata wget zip; \
	curl https://bootstrap.pypa.io/get-pip.py | python3; \
	pip install cryptography; \
	pip install 'transmissionrpc'; \
}

RUN mkdir -p /home/bgmi-docker && \
    cd /home/bgmi-docker && \
    wget https://github.com/BGmi/BGmi/archive/refs/heads/master.zip && \
    unzip /home/bgmi-docker/master.zip && \
    mv /home/bgmi-docker/BGmi-master /home/bgmi-docker/BGmi && \
    pip install /home/bgmi-docker/BGmi && \
    cd /opt && \
    wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh --no-check-certificate && \
    echo 1 | bash install-tr-control-cn.sh && \
    mkdir -p /media && \
    chmod 755 /home/bgmi-docker/entrypoint.sh && \
    rm -rf /home/bgmi-docker/master.zip && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache && \
    rm -rf /tmp/*

VOLUME ["/bgmi"]
VOLUME [ "/media" ]

EXPOSE 80 9091 51413/tcp 51413/udp

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]