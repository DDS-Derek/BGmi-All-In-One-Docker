FROM codysk/bgmi-all-in-one:1.2.5

COPY ./bgmi_hardlink_helper /home/bgmi-docker/bgmi_hardlink_helper
ADD entrypoint.sh /home/bgmi-docker/entrypoint.sh
ADD ./conf/bgmi_nginx.conf /home/bgmi-docker/config/bgmi_nginx.conf

VOLUME [ "/media" ]
VOLUME [ "/media/cartoon" ]
VOLUME [ "/media/downloads" ]