FROM alpine:3.17

RUN apk add --no-cache \
		zip \
		unzip \
		git \
		tini \
		linux-headers \
		gcc \
		python3-dev \
		libffi-dev \
		openssl-dev \
		cargo \
		libxslt-dev \
		zlib-dev \
		libxml2-dev \
		musl-dev \
		nginx \
		bash \
		supervisor \
		transmission-daemon \
		python3 \
		curl \
		tzdata \
		shadow \
		jq \
		findutils \
		su-exec \
	&& \
	curl https://bootstrap.pypa.io/get-pip.py | python3 && \
	pip install cryptography && \
	pip install 'transmissionrpc'