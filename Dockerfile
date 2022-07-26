FROM alpine:3.12

RUN { \
	apk add --update linux-headers gcc python3-dev libffi-dev openssl-dev cargo libxslt-dev zlib-dev libxml2-dev musl-dev nginx bash supervisor transmission-daemon python3 cargo curl tzdata; \
	curl https://bootstrap.pypa.io/get-pip.py | python3; \
	pip install cryptography; \
	pip install 'transmissionrpc'; \
}

VOLUME ["/bgmi"]

ENV LANG=C.UTF-8 BGMI_PATH="/bgmi/conf/bgmi"
ADD ./ /home/bgmi-docker

RUN { \
	pip install /home/bgmi-docker/BGmi; \
	chmod +x /home/bgmi-docker/entrypoint.sh; \
}

EXPOSE 80 9091

ENTRYPOINT ["/home/bgmi-docker/entrypoint.sh"]