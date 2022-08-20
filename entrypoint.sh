#!/bin/bash

first_lock="/bgmi_install.lock"
bangumi_db="$BGMI_PATH/bangumi.db"
bgmi_nginx_conf="/bgmi/conf/nginx/bgmi.conf"
bgmi_hardlink_helper="/bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py"
bgmi_hardlink_helper_config="/bgmi/bgmi_hardlink_helper/config.py"

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
	else
		bgmi upgrade
		bash /home/bgmi-docker/BGmi/bgmi/others/crontab.sh
	fi

	## 创建文件夹
	mkdir -p /var/run/nginx
	mkdir -p /bgmi/conf/bgmi
	mkdir -p /bgmi/conf/nginx
	mkdir -p /bgmi/bgmi_hardlink_helper
	mkdir -p /bgmi/log
	mkdir -p /etc/supervisor.d
	mkdir -p /media/cartoon
	mkdir -p /media/downloads

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

	## permission
	groupmod -o -g "$PGID" abc
	usermod -o -u "$PUID" abc

	## downloader
	if [[ ${DOWNLOADER} = 'transmission' ]]; then
		bash /home/bgmi-docker/utils/transmission.sh
	fi

	if [[ ${DOWNLOADER} = 'aria2' ]]; then
		bash /home/bgmi-docker/utils/aria2.sh
	fi

	if [[ ${DOWNLOADER} = 'false' ]]; then
		cp /home/bgmi-docker/config/bgmi_supervisord.ini /etc/supervisor.d/bgmi_supervisord.ini
	fi
}

if [ ! -f $first_lock ]; then
	init_proc
fi

bash /home/bgmi-docker/utils/permission.sh

exec /usr/bin/supervisord -n
