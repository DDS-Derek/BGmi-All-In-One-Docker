#!/bin/bash

first_lock="/bgmi_install.lock"
bangumi_db="$BGMI_PATH/bangumi.db"
transmission_setting="/bgmi/conf/transmission/settings.json"
bgmi_nginx_conf="/bgmi/conf/nginx/bgmi.conf"
bgmi_hardlink_helper="/bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py"
bgmi_hardlink_helper_config="/bgmi/bgmi_hardlink_helper/config.py"

data_source="bangumi_moe"	#default data source set to bangumi.moe
admin_token="bgmi_token" #default admin token

pid=0

function init_proc {
	touch $first_lock

	if [ ! -z $BGMI_ADMIN_TOKEN ]; then
		admin_token=$BGMI_ADMIN_TOKEN
	fi

	if [ ! -z $BGMI_SOURCE ]; then
		data_source=$BGMI_SOURCE
	fi

	if [ ! -f $bangumi_db ]; then
		bgmi install
		bgmi source $data_source
		bgmi config ADMIN_TOKEN $admin_token
		bgmi config SAVE_PATH /bgmi/bangumi
		bgmi config DOWNLOAD_DELEGATE transmission-rpc
	else
		bgmi upgrade
		bash /home/bgmi-docker/BGmi/bgmi/others/crontab.sh
	fi

	mkdir -p /var/run/nginx
	mkdir -p /bgmi/conf/bgmi
	mkdir -p /bgmi/conf/transmission
	mkdir -p /bgmi/conf/nginx
	mkdir -p /bgmi/log
	mkdir -p /bgmi/bangumi
	mkdir -p /etc/supervisor.d

	rm -rf /etc/nginx/conf.d
	ln -s /bgmi/conf/nginx /etc/nginx/conf.d
	cp /home/bgmi-docker/config/bgmi_supervisord.ini /etc/supervisor.d/bgmi_supervisord.ini
	cp /home/bgmi-docker/config/transmission-daemon /etc/conf.d/transmission-daemon

	if [ ! -f $transmission_setting ]; then
		cp /home/bgmi-docker/config/transmission_settings.json $transmission_setting
	fi

	if [ ! -f $bgmi_nginx_conf ]; then
		cp /home/bgmi-docker/config/bgmi_nginx.conf $bgmi_nginx_conf
	fi

	if [ ! -z $NO_TRANSMISSION ]; then
		sed -i '/\[program:tran.*$/,/stderr=true/d' /etc/supervisor.d/bgmi_supervisord.ini
		sed -i '/^programs/s/transmission,//g' /etc/supervisor.d/bgmi_supervisord.ini
	fi

	if [ ! -f $bgmi_hardlink_helper ]; then
		cp /home/bgmi-docker/bgmi_hardlink_helper/bgmi_hardlink_helper.py $bgmi_hardlink_helper
	fi

	if [ ! -f $bgmi_hardlink_helper_config ]; then
		cp /home/bgmi-docker/bgmi_hardlink_helper/config.py $bgmi_hardlink_helper_config
	fi
}

if [ ! -f $first_lock ]; then
	init_proc
fi

cd /bgmi/bgmi_hardlink_helper
python3 bgmi_hardlink_helper.py install_cron
cd /

exec /usr/bin/supervisord -n
