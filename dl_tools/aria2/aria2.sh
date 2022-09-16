#!/bin/bash

bgmi config DOWNLOAD_DELEGATE aria2-rpc

mkdir -p /bgmi/conf/aria2

if [ ! -f /bgmi/conf/aria2/aria2.session ]; then
	touch /bgmi/conf/aria2/aria2.session
fi

cp /home/bgmi-docker/config/bgmi_nginx_ariang.conf /bgmi/conf/nginx/bgmi_nginx_ariang.conf

cp /home/bgmi-docker/config/bgmi_supervisord-aria2.ini /etc/supervisor.d/bgmi_supervisord.ini

if [ ! -f /bgmi/conf/aria2/aria2.conf ]; then
	cp /home/bgmi-docker/config/aria2.conf /bgmi/conf/aria2/aria2.conf
fi