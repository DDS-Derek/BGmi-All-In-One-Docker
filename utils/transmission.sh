#!/bin/bash

bgmi config DOWNLOAD_DELEGATE transmission-rpc

mkdir -p /bgmi/conf/transmission

cp /home/bgmi-docker/config/bgmi_supervisord-transmission.ini /etc/supervisor.d/bgmi_supervisord.ini

cp /home/bgmi-docker/config/transmission-daemon /etc/conf.d/transmission-daemon

if [ ! -f /bgmi/conf/transmission/settings.json ]; then
	cp /home/bgmi-docker/config/transmission_settings.json /bgmi/conf/transmission/settings.json
fi