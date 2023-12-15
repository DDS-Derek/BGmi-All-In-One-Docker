FROM python:3.11.7-alpine3.19

ENV TZ=Asia/Shanghai \
    DATA_PATH=/data

WORKDIR /app
COPY ./tgbot /app
RUN set -ex && \
    apk add --no-cache \
        bash \
        tzdata \
        tini && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm -rf \
        /var/cache/apk/* \
        /root/.cache \
        /tmp/*

ENTRYPOINT ["tini", "-g", "python3", "run.py"]