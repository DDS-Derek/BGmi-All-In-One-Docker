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
        if [ -z ${BGMI_VERSION} ]; then
            export DOWNLOADER=transmission-rpc
            dockerize -no-overwrite -template ${BGMI_HOME}/config/bgmi_config.toml.tmpl:${bgmi_config}
        elif [ "${BGMI_VERSION}" == "transmission" ]; then
            export DOWNLOADER=transmission-rpc
            dockerize -no-overwrite -template ${BGMI_HOME}/config/bgmi_config.toml.tmpl:${bgmi_config}
        elif [ "${BGMI_VERSION}" == "aria2" ]; then
            export DOWNLOADER=aria2-rpc
            export ARIA2_RPC_TOKEN=${RPC_SECRET}
            dockerize -no-overwrite -template ${BGMI_HOME}/config/bgmi_config.toml.tmpl:${bgmi_config}
        fi
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
        if [ -z ${BGMI_VERSION} ]; then
            export NGINX_PARAMETER="
    location /api {
        proxy_pass http://127.0.0.1:8888;
    }

    location /resource {
        proxy_pass http://127.0.0.1:8888;
    }

    location / {
        alias /bgmi/conf/bgmi/front_static/;
    }
"
        elif [ "${BGMI_VERSION}" == "transmission" ]; then
            export NGINX_PARAMETER="
    location /api {
        proxy_pass http://127.0.0.1:8888;
    }
    location /resource {
        proxy_pass http://127.0.0.1:8888;
    }
    location /transmission {
        proxy_pass http://127.0.0.1:9091;
    }
    location / {
        alias /bgmi/conf/bgmi/front_static/;
    }
"
        elif [ "${BGMI_VERSION}" == "aria2" ]; then
            export NGINX_PARAMETER="
    location /api {
        proxy_pass http://127.0.0.1:8888;
    }
    location /resource {
        proxy_pass http://127.0.0.1:8888;
    }
    location /ariang {
        alias /home/bgmi-docker/downloader/aria2/ariang;
    }
    location / {
        alias /bgmi/conf/bgmi/front_static/;
    }
"
        fi
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

function __supervisord_downloader {

    if [ -z ${BGMI_VERSION} ]; then
    
        dockerize -no-overwrite -template ${BGMI_HOME}/downloader/none/supervisord.ini.tmpl:${BGMI_HOME}/bgmi_supervisord.ini

    elif [ "${BGMI_VERSION}" == "transmission" ]; then

        transmission_config_file="/bgmi/conf/transmission/settings.json"
        dockerize -no-overwrite -template ${BGMI_HOME}/downloader/transmission/supervisord.ini.tmpl:${BGMI_HOME}/bgmi_supervisord.ini
        if [ ! -f /bgmi/conf/transmission ]; then
            mkdir -p /bgmi/conf/transmission
        fi
        cp /home/bgmi-docker/downloader/transmission/transmission-daemon /etc/conf.d/transmission-daemon
        if [ ! -f ${transmission_config_file} ]; then
            cp /home/bgmi-docker/downloader/transmission/settings.json ${transmission_config_file}
        fi
        if [[ -n "$TR_USER" ]] && [[ -n "$TR_PASS" ]]; then
            sed -i '/rpc-authentication-required/c\    "rpc-authentication-required": true,' ${transmission_config_file}
            sed -i "/rpc-username/c\    \"rpc-username\": \"$TR_USER\"," ${transmission_config_file}
            sed -i "/rpc-password/c\    \"rpc-password\": \"$TR_PASS\"," ${transmission_config_file}
            bgmi config TRANSMISSION_RPC_USERNAME $TR_USER
            bgmi config TRANSMISSION_RPC_PASSWORD $TR_PASS
        else
            sed -i '/rpc-authentication-required/c\    "rpc-authentication-required": false,' ${transmission_config_file}
            sed -i "/rpc-username/c\    \"rpc-username\": \"$TR_USER\"," ${transmission_config_file}
            sed -i "/rpc-password/c\    \"rpc-password\": \"$TR_PASS\"," ${transmission_config_file}
        fi
        if [[ -n "${TR_PEERPORT}" ]]; then
            sed -i "/\"peer-port\"/c\    \"peer-port\": ${TR_PEERPORT}," ${transmission_config_file}
            sed -i '/peer-port-random-on-start/c\     "peer-port-random-on-start": false,' ${transmission_config_file}
        fi
        if [ ! -z "${DOWNLOAD_DIR}" ]; then
            sed -i "/\"download-dir\"/c\    \"download-dir\": \"$DOWNLOAD_DIR\"," ${transmission_config_file}
            sed -i "/\"incomplete-dir\"/c\    \"incomplete-dir\": \"$DOWNLOAD_DIR\"," ${transmission_config_file}
        fi

    elif [ "${BGMI_VERSION}" == "aria2" ]; then

        dockerize -no-overwrite -template ${BGMI_HOME}/downloader/aria2/supervisord.ini.tmpl:${BGMI_HOME}/bgmi_supervisord.ini

        bash ${BGMI_HOME}/downloader/aria2/settings.sh

    else
        echo -e "\033[31m[+] Wrong container version, start with default version\033[0m"
        dockerize -no-overwrite -template ${BGMI_HOME}/downloader/none/supervisord.ini.tmpl:${BGMI_HOME}/bgmi_supervisord.ini
    fi

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

    __supervisord_downloader

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
