#!/bin/bash

pid=0

first_lock="/bgmi_install.lock"

## 创建文件夹
function mkdir_dir {

    nginx_run="/var/run/nginx"
    bgmi_conf="/bgmi/conf/bgmi"
    bgmi_nginx="/bgmi/conf/nginx"
    bgmi_hardlink_helper_dir="/bgmi/bgmi_hardlink_helper"
    bgmi_log="/bgmi/log"
    supervisor_dir="/etc/supervisor.d"
    media_cartoon="/media/cartoon"
    meida_downloads="/media/downloads"

	if [ ! -d $nginx_run ]; then
		mkdir -p $nginx_run
	fi

	if [ ! -d $bgmi_conf ]; then
		mkdir -p $bgmi_conf
	fi

	if [ ! -d $bgmi_nginx ]; then
		mkdir -p $bgmi_nginx
	fi

	if [ ! -d $bgmi_hardlink_helper_dir ]; then
		mkdir -p $bgmi_hardlink_helper_dir
	fi

	if [ ! -d $bgmi_log ]; then
		mkdir -p $bgmi_log
	fi

	if [ ! -d $supervisor_dir ]; then
		mkdir -p $supervisor_dir
	fi

	if [ ! -d $media_cartoon ]; then
		mkdir -p $media_cartoon
	fi

	if [ ! -d $meida_downloads ]; then
		mkdir -p $meida_downloads
	fi

}

# 设置BGMI
function config_bgmi {

    bangumi_db="$BGMI_PATH/bangumi.db"

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

}

# 设置Nginx
function config_nginx {

    bgmi_nginx_conf="/bgmi/conf/nginx/bgmi.conf"
    nginx_conf_dir="/etc/nginx/conf.d"
    bgmi_nginx="/bgmi/conf/nginx"

	rm -rf $nginx_conf_dir
	ln -s $bgmi_nginx $nginx_conf_dir

	if [ ! -f $bgmi_nginx_conf ]; then
		cp /home/bgmi-docker/config/bgmi_nginx.conf $bgmi_nginx_conf
	fi
	sed -i "s/user nginx;/user bgmi;/g" /etc/nginx/nginx.conf

}

# 设置bgmi_hardlink_helper
function config_bgmi_hardlink_helper {

    bgmi_hardlink_helper="/bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py"
    bgmi_hardlink_helper_config="/bgmi/bgmi_hardlink_helper/config.py"

	if [ ! -f $bgmi_hardlink_helper ]; then
		cp /home/bgmi-docker/bgmi_hardlink_helper/bgmi_hardlink_helper.py $bgmi_hardlink_helper
	fi

	if [ ! -f $bgmi_hardlink_helper_config ]; then
		cp /home/bgmi-docker/bgmi_hardlink_helper/config.py $bgmi_hardlink_helper_config
	fi

	(crontab -l ; echo "0 */2 * * * su bgmi -c 'python3 /bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py run'") | crontab -

}

# 设置permission
function permission {

	groupmod -o -g "$PGID" bgmi
	usermod -o -u "$PUID" bgmi

}

# 设置downloader
function downloader {

    dl_tools_dir="/home/bgmi-docker/dl_tools"

	if [[ ${DOWNLOADER} = 'transmission' ]]; then
		bash $dl_tools_dir/transmission/start.sh
	fi

#	if [[ ${DOWNLOADER} = 'aria2' ]]; then
#		bash $dl_tools_dir/aria2.sh
#	fi

	if [[ ${DOWNLOADER} = 'false' ]]; then
		cp $dl_tools_dir/default/bgmi_supervisord.ini /etc/supervisor.d/bgmi_supervisord.ini
	fi

}

function init_proc {

	touch $first_lock

}

if [ ! -f $first_lock ]; then

	init_proc

    mkdir_dir

    config_bgmi

    config_nginx

    config_bgmi_hardlink_helper

    permission

    downloader

fi

chown -R bgmi:bgmi \
	/bgmi

chown bgmi:bgmi \
	/media \
	/media/cartoon \
	/media/downloads

exec /usr/bin/supervisord -n
