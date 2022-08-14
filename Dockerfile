FROM codysk/bgmi-all-in-one:1.2.5

ENV PUID=1000
ENV PGID=1000
## true 和 false
ENV TRANSMISSION=true
## true 和 false
ENV TRANSMISSION_WEB_CONTROL=true

COPY ./bgmi_hardlink_helper /home/bgmi-docker/bgmi_hardlink_helper
ADD entrypoint.sh /home/bgmi-docker/entrypoint.sh
ADD ./conf/bgmi_nginx.conf /home/bgmi-docker/config/bgmi_nginx.conf
ADD ./conf/bgmi_supervisord-notransmission.ini /opt/config/bgmi_supervisord-notransmission.ini
ADD ./conf/bgmi_supervisord.ini /opt/config/bgmi_supervisord.ini

RUN cd /opt && \
    wget https://github.com/ronggang/transmission-web-control/raw/master/release/install-tr-control-cn.sh --no-check-certificate && \
    echo 1 | bash install-tr-control-cn.sh && \
    mkdir -p /media && \
    chmod 755 /home/bgmi-docker/entrypoint.sh

VOLUME [ "/media" ]
