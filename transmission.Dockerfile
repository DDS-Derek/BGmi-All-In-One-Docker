ARG BGMI_TAG

FROM ddsderek/bgmi-all-in-one:${BGMI_TAG}

RUN set -ex && \
    apk add --no-cache transmission-daemon
