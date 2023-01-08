#!/bin/bash

pid=0

## 创建文件夹
function mkdir_dir {

    nginx_run="/var/run/nginx"
    bgmi_conf="/bgmi/conf/bgmi"
    bgmi_nginx="/bgmi/conf/nginx"
    bgmi_hardlink_helper_dir="/bgmi/bgmi_hardlink_helper"
    bgmi_log="/bgmi/log"
    media_cartoon=${MEDIA_DIR}
    meida_downloads=${DOWNLOAD_DIR}
    supervisor_logs="/bgmi/log/supervisor"

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

    if [ ! -d $media_cartoon ]; then
    	mkdir -p $media_cartoon
    fi

    if [ ! -d $meida_downloads ]; then
    	mkdir -p $meida_downloads
    fi

    if [ ! -d $supervisor_logs ]; then
    	mkdir -p $supervisor_logs
    fi

}

# 设置BGMI
function config_bgmi {

    bangumi_db="$BGMI_PATH/bangumi.db"

    cp ${BGMI_HOME}/config/crontab.sh ${BGMI_HOME}/BGmi/bgmi/others/crontab.sh

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
    	bash /home/bgmi-docker/BGmi/bgmi/others/crontab.sh
    else
    	bgmi upgrade
    	bgmi config ADMIN_TOKEN $admin_token
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
    	touch $bgmi_nginx_conf
    fi
    cat > $bgmi_nginx_conf << EOF
server {
    listen 80 default_server;
    server_name _;
    root /bgmi/;
    autoindex on;
    charset utf-8;

    location /bangumi {
        alias ${DOWNLOAD_DIR};
    }

    location /api {
        proxy_pass http://127.0.0.1:8888;
    }

    location /resource {
        proxy_pass http://127.0.0.1:8888;
    }

    location / {
        alias /bgmi/conf/bgmi/front_static/;
    }
}

EOF

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

    sed -i "/HARDLINK_DEST/c\HARDLINK_DEST = '${MEDIA_DIR}'" $bgmi_hardlink_helper_config

    echo "[+] bgmi_hardlink_helper install successfully"

    echo "[+] crontab bgmi_hardlink_helper added"

    (crontab -l ; echo "20 */2 * * * LC_ALL=en_US.UTF-8 su-exec bgmi python3 /bgmi/bgmi_hardlink_helper/bgmi_hardlink_helper.py run") | crontab -

}

# 设置permission
function permission {

    if [[ -z ${PUID} && -z ${PGID} ]] || [[ ${PUID} = 65534 && ${PGID} = 65534 ]]; then
    	echo -e "\033[31mIgnore permission settings.\033[0m"
    	exit 1
    else
    	groupmod -o -g "$PGID" bgmi
    	usermod -o -u "$PUID" bgmi
    fi

}

# transmission设置
function transmission_install {

    bgmi config DOWNLOAD_DELEGATE transmission-rpc
    bgmi config SAVE_PATH $DOWNLOAD_DIR

    if [ ! -f /bgmi/conf/transmission ]; then
        mkdir -p /bgmi/conf/transmission
    fi

    cp /home/bgmi-docker/dl_tools/transmission/bgmi_supervisord-transmission.ini ${BGMI_HOME}/bgmi_supervisord.ini

    cp /home/bgmi-docker/dl_tools/transmission/transmission-daemon /etc/conf.d/transmission-daemon

    if [ ! -f /bgmi/conf/transmission/settings.json ]; then
    	cp /home/bgmi-docker/dl_tools/transmission/transmission_settings.json /bgmi/conf/transmission/settings.json
    fi

    if [[ -n "$TR_USER" ]] && [[ -n "$TR_PASS" ]]; then
        sed -i '/rpc-authentication-required/c\    "rpc-authentication-required": true,' /bgmi/conf/transmission/settings.json
        sed -i "/rpc-username/c\    \"rpc-username\": \"$TR_USER\"," /bgmi/conf/transmission/settings.json
        sed -i "/rpc-password/c\    \"rpc-password\": \"$TR_PASS\"," /bgmi/conf/transmission/settings.json
        bgmi config TRANSMISSION_RPC_USERNAME $TR_USER
        bgmi config TRANSMISSION_RPC_PASSWORD $TR_PASS
    else
        sed -i '/rpc-authentication-required/c\    "rpc-authentication-required": false,' /bgmi/conf/transmission/settings.json
        sed -i "/rpc-username/c\    \"rpc-username\": \"$TR_USER\"," /bgmi/conf/transmission/settings.json
        sed -i "/rpc-password/c\    \"rpc-password\": \"$TR_PASS\"," /bgmi/conf/transmission/settings.json
    fi

    if [[ -n "${TR_PEERPORT}" ]]; then
        sed -i "/\"peer-port\"/c\    \"peer-port\": ${TR_PEERPORT}," /bgmi/conf/transmission/settings.json
        sed -i '/peer-port-random-on-start/c\     "peer-port-random-on-start": false,' /bgmi/conf/transmission/settings.json
    fi

    if [ ! -z "${DOWNLOAD_DIR}" ]; then
    	sed -i "/\"download-dir\"/c\    \"download-dir\": \"$DOWNLOAD_DIR\"," /bgmi/conf/transmission/settings.json
    	sed -i "/\"incomplete-dir\"/c\    \"incomplete-dir\": \"$DOWNLOAD_DIR\"," /bgmi/conf/transmission/settings.json
    fi

}

# aria2设置
function aria2_install {

    aria2_settings_dir=/home/bgmi-docker/dl_tools/aria2
    bgmi_nginx_conf="/bgmi/conf/nginx/bgmi.conf"

    bgmi config DOWNLOAD_DELEGATE aria2-rpc
    bgmi config ARIA2_RPC_TOKEN $RPC_SECRET
    bgmi config SAVE_PATH $DOWNLOAD_DIR

    if [ -f $bgmi_nginx_conf ]; then
    	rm -rf $bgmi_nginx_conf
        touch $bgmi_nginx_conf
    else
        touch $bgmi_nginx_conf
    fi
    cat > $bgmi_nginx_conf << EOF
server {
    listen 80 default_server;
    server_name _;
    root /bgmi/;
    autoindex on;
    charset utf-8;

    location /bangumi {
        alias ${DOWNLOAD_DIR};
    }

    location /api {
        proxy_pass http://127.0.0.1:8888;
    }

    location /resource {
        proxy_pass http://127.0.0.1:8888;
    }

    location /ariang {
        alias /home/bgmi-docker/dl_tools/aria2/ariang;
    }

    location / {
        alias /bgmi/conf/bgmi/front_static/;
    }
}

EOF

    cp $aria2_settings_dir/bgmi_supervisord-aria2.ini ${BGMI_HOME}/bgmi_supervisord.ini

    bash $aria2_settings_dir/aria2_pro/settings.sh

}

function default_install {

    default_install_dir="/home/bgmi-docker/dl_tools"

    cp $default_install_dir/default/bgmi_supervisord.ini ${BGMI_HOME}/bgmi_supervisord.ini

}

# 设置downloader
function downloader {

    if [[ ${BGMI_DOWNLOADER} = 'transmission' || ${BGMI_DOWNLOADER} = 'TR' || ${BGMI_DOWNLOADER} = 'tr' ]]; then
    	transmission_install
    fi

    if [[ ${BGMI_DOWNLOADER} = 'aria2' || ${BGMI_DOWNLOADER} = 'Aria2' ]]; then
    	aria2_install
    fi

    if [[ ${BGMI_DOWNLOADER} = 'false' || ${BGMI_DOWNLOADER} = 'disable' || ${BGMI_DOWNLOADER} = 'no' ]]; then
    	default_install
    fi

}

first_lock="${BGMI_HOME}/bgmi_install.lock"

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
    /home/bgmi-docker
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
echo

umask ${UMASK}

exec /usr/bin/supervisord -n -c ${BGMI_HOME}/bgmi_supervisord.ini
