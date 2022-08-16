#!/bin/bash

first_lock="/bgmi_install.lock"
bangumi_db="$BGMI_PATH/bangumi.db"
transmission_setting="/bgmi/conf/transmission/settings.json"
bgmi_nginx_conf="/bgmi/conf/nginx/bgmi.conf"
bgmi_hardlink_helper="/bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py"
bgmi_hardlink_helper_config="/bgmi/bgmi_hardlink_helper/config.py"
userid="/bgmi/bgmi_hardlink_helper/userid.sh"

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
		bgmi config SAVE_PATH /media/downloads
		bgmi config DOWNLOAD_DELEGATE transmission-rpc
	else
		bgmi upgrade
		bash /home/bgmi-docker/BGmi/bgmi/others/crontab.sh
	fi

	## 创建文件夹
	mkdir -p /var/run/nginx
	mkdir -p /bgmi/conf/bgmi
	mkdir -p /bgmi/conf/transmission
	mkdir -p /bgmi/conf/nginx
	mkdir -p /bgmi/bgmi_hardlink_helper
	mkdir -p /bgmi/log
	mkdir -p /etc/supervisor.d
    mkdir -p /media/cartoon
    mkdir -p /media/downloads

    ## transmission
    if [[ ${TRANSMISSION} = 'true' ]]; then
		cp /home/bgmi-docker/config/bgmi_supervisord.ini /etc/supervisor.d/bgmi_supervisord.ini
	else
		cp /home/bgmi-docker/config/bgmi_supervisord-notransmission.ini /etc/supervisor.d/bgmi_supervisord.ini
    fi

	cp /home/bgmi-docker/config/transmission-daemon /etc/conf.d/transmission-daemon

	if [ ! -f $transmission_setting ]; then
		cp /home/bgmi-docker/config/transmission_settings.json $transmission_setting
	fi

	if [[ ${TRANSMISSION_WEB_CONTROL} = 'false' ]]; then
		echo 3 | bash /home/bgmi-docker/transmission-web-control/install-tr-control-cn.sh > /dev/null
    fi

	## nginx
	rm -rf /etc/nginx/conf.d
	ln -s /bgmi/conf/nginx /etc/nginx/conf.d

	if [ ! -f $bgmi_nginx_conf ]; then
		cp /home/bgmi-docker/config/bgmi_nginx.conf $bgmi_nginx_conf
	fi
	sed -i "s/user nginx;/user abc;/g" /etc/nginx/nginx.conf

	## bgmi_hardlink_helper
	if [ ! -f $bgmi_hardlink_helper ]; then
		cp /home/bgmi-docker/bgmi_hardlink_helper/bgmi_hardlink_helper.py $bgmi_hardlink_helper
	fi

	if [ ! -f $bgmi_hardlink_helper_config ]; then
		cp /home/bgmi-docker/bgmi_hardlink_helper/config.py $bgmi_hardlink_helper_config
	fi

	(crontab -l ; echo "0 */2 * * * su abc -c 'python3 /bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py run'") | crontab -
}

if [ ! -f $first_lock ]; then
	init_proc
fi

bash /home/bgmi-docker/utils/permission.sh

exec /usr/bin/supervisord -n
