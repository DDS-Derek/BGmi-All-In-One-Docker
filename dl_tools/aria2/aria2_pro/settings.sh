#!/bin/bash

#     _         _       ____    ____
#    / \   _ __(_) __ _|___ \  |  _ \ _ __ ___
#   / _ \ | '__| |/ _` | __) | | |_) | '__/ _ \
#  / ___ \| |  | | (_| |/ __/  |  __/| | | (_) |
# /_/   \_\_|  |_|\__,_|_____| |_|   |_|  \___/
#
# https://github.com/P3TERX/Aria2-Pro-Docker https://github.com/DDS-Derek/Aria2-Pro-Docker
#
# Copyright (c) 2020-2022 P3TERX <https://p3terx.com> DDSRem DDSDerek <https://blog.ddsrem.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.

. /home/bgmi-docker/dl_tools/aria2/aria2_pro/init-base

mkdir -p ${ARIA2_CONF_DIR} ${SCRIPT_DIR} ${DOWNLOAD_DIR}

PROFILES="
aria2.conf
script.conf
core
delete.sh
dht.dat
dht6.dat
LICENSE
"

DOWNLOAD_PROFILE

[[ ! -f "${ARIA2_CONF_DIR}/aria2.session" ]] && {
    rm -rf "${ARIA2_CONF_DIR}/aria2.session"
    touch "${ARIA2_CONF_DIR}/aria2.session"
}

if ! [[ "${UPDATE_TRACKERS}" = "false" || "${UPDATE_TRACKERS}" = "disable" ]]; then
    (crontab -l ; echo "0 7 * * * su bgmi -c 'sleep $((RANDOM % 1800)); bash /config/aria2/script/tracker.sh /config/aria2/aria2.conf RPC 2>&1 | tee /config/logs/tracker.log'") | crontab -
    PROFILES="tracker.sh"
    DOWNLOAD_PROFILE
    bash ${SCRIPT_DIR}/tracker.sh ${ARIA2_CONF}
fi

if [[ "${SPECIAL_MODE}" = "rclone" ]]; then
    PROFILES="upload.sh rclone.env"
elif [[ "${SPECIAL_MODE}" = "move" ]]; then
    PROFILES="move.sh"
else
    PROFILES="clean.sh"
fi

DOWNLOAD_PROFILE

[[ -e ${ARIA2_CONF_DIR}/delete.sh ]] && {
    rm -f ${ARIA2_CONF_DIR}/*.sh
    sed -i "s@^\(on-download-stop=\).*@\1${SCRIPT_DIR}/delete.sh@" ${ARIA2_CONF}
    sed -i "s@^\(on-download-complete=\).*@\1${SCRIPT_DIR}/clean.sh@" ${ARIA2_CONF}
}

sed -i "s@^\(dir=\).*@\1${DOWNLOAD_DIR}@" ${ARIA2_CONF}
sed -i "s@^\(input-file=\).*@\1${ARIA2_CONF_DIR}/aria2.session@" ${ARIA2_CONF}
sed -i "s@^\(save-session=\).*@\1${ARIA2_CONF_DIR}/aria2.session@" ${ARIA2_CONF}
sed -i "s@^\(dht-file-path=\).*@\1${ARIA2_CONF_DIR}/dht.dat@" ${ARIA2_CONF}
sed -i "s@^\(dht-file-path6=\).*@\1${ARIA2_CONF_DIR}/dht6.dat@" ${ARIA2_CONF}

[[ -e ${ARIA2_CONF_DIR}/HelloWorld ]] && exit 0

[[ ${RPC_PORT} ]] &&
    sed -i "s@^\(rpc-listen-port=\).*@\1${RPC_PORT}@" ${ARIA2_CONF}

[[ ${LISTEN_PORT} ]] && {
    sed -i "s@^\(listen-port=\).*@\1${LISTEN_PORT}@" ${ARIA2_CONF}
    sed -i "s@^\(dht-listen-port=\).*@\1${LISTEN_PORT}@" ${ARIA2_CONF}
}

[[ ${RPC_SECRET} ]] &&
    sed -i "s@^\(rpc-secret=\).*@\1${RPC_SECRET}@" ${ARIA2_CONF}

[[ ${DISK_CACHE} ]] &&
    sed -i "s@^\(disk-cache=\).*@\1${DISK_CACHE}@" ${ARIA2_CONF}

[[ "${IPV6_MODE}" = "true" || "${IPV6_MODE}" = "enable" ]] && {
    sed -i "s@^\(disable-ipv6=\).*@\1false@" ${ARIA2_CONF}
    sed -i "s@^\(enable-dht6=\).*@\1true@" ${ARIA2_CONF}
}

[[ "${IPV6_MODE}" = "false" || "${IPV6_MODE}" = "disable" ]] && {
    sed -i "s@^\(disable-ipv6=\).*@\1true@" ${ARIA2_CONF}
    sed -i "s@^\(enable-dht6=\).*@\1false@" ${ARIA2_CONF}
}

[[ "${SPECIAL_MODE}" = "rclone" ]] &&
    sed -i "s@^\(on-download-complete=\).*@\1${SCRIPT_DIR}/upload.sh@" ${ARIA2_CONF}

[[ "${SPECIAL_MODE}" = "move" ]] &&
    sed -i "s@^\(on-download-complete=\).*@\1${SCRIPT_DIR}/move.sh@" ${ARIA2_CONF}

cat /home/bgmi-docker/dl_tools/aria2/aria2_pro/Aria2-Pro

exit 0
