#!/bin/bash

bgmi config DOWNLOAD_DELEGATE aria2-rpc

cp /home/bgmi-docker/dl_tools/aria2/bgmi_nginx_ariang.conf /bgmi/conf/nginx/bgmi_nginx_ariang.conf

cp /home/bgmi-docker/dl_tools/aria2/bgmi_supervisord-aria2.ini /etc/supervisor.d/bgmi_supervisord.ini

bash /home/bgmi-docker/dl_tools/aria2/aria2_pro/install.sh