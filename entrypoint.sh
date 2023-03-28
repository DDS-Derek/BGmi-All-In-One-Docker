#!/bin/bash

umask "${UMASK}"

## 创建文件夹
function __mkdir_dir {

    nginx_run="/var/run/nginx"
    bgmi_conf="/bgmi/conf/bgmi"
    bgmi_nginx="/bgmi/conf/nginx"
    bgmi_log="/bgmi/log"
    media_cartoon=${MEDIA_DIR}
    meida_downloads=${DOWNLOAD_DIR}

    if [ ! -d $nginx_run ]; then
    	mkdir -p $nginx_run
    fi

    if [ ! -d $bgmi_conf ]; then
    	mkdir -p $bgmi_conf
    fi

    if [ ! -d $bgmi_nginx ]; then
    	mkdir -p $bgmi_nginx
    fi

    if [ ! -d $bgmi_log ]; then
    	mkdir -p $bgmi_log
    fi

    if [ ! -d $media_cartoon ]; then
    	mkdir -p $media_cartoon
    fi

    if [ ! -d $meida_downloads ]; then
    	mkdir -p $meida_downloads
    fi

}

# 设置BGMI
function __config_bgmi {

    bangumi_db="$BGMI_PATH/bangumi.db"
    bgmi_config="$BGMI_PATH/config.toml"

    cp ${BGMI_HOME}/config/crontab.sh ${BGMI_HOME}/BGmi/bgmi/others/crontab.sh

    if [ ! -f "${bgmi_config}" ]; then
    	dockerize -no-overwrite -template ${BGMI_HOME}/config/bgmi_config.toml.tmpl:${bgmi_config}
    fi

    if [ ! -f $bangumi_db ]; then
    	bgmi install
        touch /etc/crontabs/root
    	bash /home/bgmi-docker/BGmi/bgmi/others/crontab.sh
    else
    	bgmi upgrade
        touch /etc/crontabs/root
    	bash /home/bgmi-docker/BGmi/bgmi/others/crontab.sh
    fi

}

# 设置Nginx
function __config_nginx {

    bgmi_nginx="/bgmi/conf/nginx"
    bgmi_nginx_conf="$bgmi_nginx/bgmi.conf"
    nginx_conf_dir="/etc/nginx/http.d"

    rm -rf $nginx_conf_dir
    ln -s $bgmi_nginx $nginx_conf_dir

    if [ ! -f "${bgmi_nginx_conf}" ]; then
    	dockerize -no-overwrite -template ${BGMI_HOME}/config/bgmi_nginx.conf.tmpl:${bgmi_nginx_conf}
    fi

    sed -i "s/user nginx;/user bgmi;/g" /etc/nginx/nginx.conf

}

# 设置permission
function __adduser {

    if [[ -z ${PUID} && -z ${PGID} ]]; then
    	echo -e "\033[31m[+] Ignore permission settings. Start with root user\033[0m"
    	export PUID=0
        export PGID=0
    	groupmod -o -g "$PGID" bgmi 2>&1 | sed "s#^#[+] $0#g" | sed "s#/home/bgmi-docker/entrypoint.sh##g"
    	usermod -o -u "$PUID" bgmi 2>&1 | sed "s#^#[+] $0#g" | sed "s#/home/bgmi-docker/entrypoint.sh##g"
    else
    	groupmod -o -g "$PGID" bgmi 2>&1 | sed "s#^#[+] $0#g" | sed "s#/home/bgmi-docker/entrypoint.sh##g"
    	usermod -o -u "$PUID" bgmi 2>&1 | sed "s#^#[+] $0#g" | sed "s#/home/bgmi-docker/entrypoint.sh##g"
    fi

}

function __supervisord {

    dockerize -no-overwrite -template ${BGMI_HOME}/config/bgmi_supervisord.ini.tmpl:${BGMI_HOME}/bgmi_supervisord.ini

}

function __bgmi_scripts {

    cp -r ${BGMI_HOME}/scripts/* /usr/local/bin

}

first_lock="${BGMI_HOME}/bgmi_install.lock"

function __init_proc {

    touch "${first_lock}"

    crontab -r

}

if [ ! -f "${first_lock}" ]; then

    __init_proc

    __mkdir_dir

    __config_bgmi

    __config_nginx

    __adduser

    __bgmi_scripts

    __supervisord

fi

chown -R bgmi:bgmi \
    /home/bgmi-docker \
    /home/bgmi
chown -R bgmi:bgmi \
    /bgmi
if [[ "$(stat -c '%U' /media)" != "bgmi" ]] || [[ "$(stat -c '%G' /media)" != "bgmi" ]]; then
    chown bgmi:bgmi \
        /media
fi
if [[ "$(stat -c '%U' ${MEDIA_DIR})" != "bgmi" ]] || [[ "$(stat -c '%G' ${MEDIA_DIR})" != "bgmi" ]]; then
    chown bgmi:bgmi \
        ${MEDIA_DIR}
fi
if [[ "$(stat -c '%U' ${DOWNLOAD_DIR})" != "bgmi" ]] || [[ "$(stat -c '%G' ${DOWNLOAD_DIR})" != "bgmi" ]]; then
    chown bgmi:bgmi \
        ${DOWNLOAD_DIR}
fi

cat /home/bgmi-docker/BGmi-Docker.logo

exec dumb-init /usr/bin/supervisord -n -c "${BGMI_HOME}"/bgmi_supervisord.ini
