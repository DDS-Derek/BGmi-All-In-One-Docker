#!/bin/bash

bgmi config DOWNLOAD_DELEGATE transmission-rpc

if [ ! -f /bgmi/conf/transmission ]; then
	mkdir -p /bgmi/conf/transmission
fi

cp /home/bgmi-docker/dl_tools/transmission/bgmi_supervisord-transmission.ini /etc/supervisor.d/bgmi_supervisord.ini

cp /home/bgmi-docker/dl_tools/transmission/transmission-daemon /etc/conf.d/transmission-daemon

if [ ! -f /bgmi/conf/transmission/settings.json ]; then
	cp /home/bgmi-docker/dl_tools/transmission/transmission_settings.json /bgmi/conf/transmission/settings.json
fi

exit