#!/usr/bin/with-contenv bash
# shellcheck shell=bash
#     _         _       ____    ____
#    / \   _ __(_) __ _|___ \  |  _ \ _ __ ___
#   / _ \ | '__| |/ _` | __) | | |_) | '__/ _ \
#  / ___ \| |  | | (_| |/ __/  |  __/| | | (_) |
# /_/   \_\_|  |_|\__,_|_____| |_|   |_|  \___/
#
# https://github.com/P3TERX/Docker-Aria2-Pro https://github.com/DDS-Derek/Aria2-Pro-Docker
#
# Copyright (c) 2020-2022 P3TERX <https://p3terx.com> DDSRem DDSDerek <https://blog.ddsrem.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"
INFO="[${Green_font_prefix}INFO${Font_color_suffix}]"
ERROR="[${Red_font_prefix}ERROR${Font_color_suffix}]"
WARN="[${Yellow_font_prefix}WARN${Font_color_suffix}]"
ARIA2_CONF_DIR="/bgmi/conf/aria2"
ARIA2_CONF="${ARIA2_CONF_DIR}/aria2.conf"
SCRIPT_CONF="${ARIA2_CONF_DIR}/script.conf"
SCRIPT_DIR="${ARIA2_CONF_DIR}/script"
CURL_OPTIONS="-fsSL --connect-timeout 3 --max-time 3"
PROFILE_URL1="https://p3terx.github.io/aria2.conf"
PROFILE_URL2="https://aria2c.now.sh"
PROFILE_URL3="https://cdn.jsdelivr.net/gh/P3TERX/aria2.conf"

FILE_ALLOCATION_SET() {
    TMP_FILE="${DOWNLOAD_DIR}/P3TERX.COM"
    if fallocate -l 5G ${TMP_FILE}; then
        FILE_ALLOCATION=falloc
    else
        FILE_ALLOCATION=none
    fi
    rm -f ${TMP_FILE}
    sed -i "s@^\(file-allocation=\).*@\1${FILE_ALLOCATION}@" "${ARIA2_CONF}"
}

CONVERSION_ARIA2_CONF() {
    sed -i "s@^\(rpc-listen-port=\).*@\1${ARIA2_RPC_PORT:-6800}@" "${ARIA2_CONF}"
    sed -i "s@^\(listen-port=\).*@\1${ARIA2_LISTEN_PORT:-6888}@" "${ARIA2_CONF}"
    sed -i "s@^\(dht-listen-port=\).*@\1${ARIA2_LISTEN_PORT:-6888}@" "${ARIA2_CONF}"
    sed -i "s@^\(dir=\).*@\1${DOWNLOAD_DIR}@" "${ARIA2_CONF}"
    sed -i "s@/root/.aria2@${ARIA2_CONF_DIR}@" "${ARIA2_CONF}"
    sed -i "s@^#\(retry-on-.*=\).*@\1true@" "${ARIA2_CONF}"
    sed -i "s@^\(max-connection-per-server=\).*@\132@" "${ARIA2_CONF}"
    sed -i "s@^\(on-download-stop=\).*@\1${SCRIPT_DIR}/delete.sh@" ${ARIA2_CONF}
    sed -i "s@^\(on-download-complete=\).*@\1${SCRIPT_DIR}/clean.sh@" "${ARIA2_CONF}"
    [[ $TZ != "Asia/Shanghai" ]] && sed -i '11,$s/#.*//;/^$/d' "${ARIA2_CONF}"
    FILE_ALLOCATION_SET
}

CONVERSION_SCRIPT_CONF() {
    sed -i "s@\(upload-log=\).*@\1${ARIA2_CONF_DIR}/upload.log@" "${SCRIPT_CONF}"
    sed -i "s@\(move-log=\).*@\1${ARIA2_CONF_DIR}/move.log@" "${SCRIPT_CONF}"
    sed -i "s@^\(dest-dir=\).*@\1${DOWNLOAD_DIR}/completed@" "${SCRIPT_CONF}"
}

CONVERSION_CORE() {
    sed -i "s@\(ARIA2_CONF_DIR=\"\).*@\1${ARIA2_CONF_DIR}\"@" "${SCRIPT_DIR}/core"
}

DOWNLOAD_PROFILE() {
    for PROFILE in ${PROFILES}; do
        [[ ${PROFILE} = *.sh || ${PROFILE} = core ]] && cd "${SCRIPT_DIR}" || cd "${ARIA2_CONF_DIR}"
        while [[ ! -f ${PROFILE} ]]; do
            rm -rf ${PROFILE}
            echo
            echo -e "${INFO} Downloading '${PROFILE}' ..."
            curl -O ${CURL_OPTIONS} ${PROFILE_URL1}/${PROFILE} ||
                curl -O ${CURL_OPTIONS} ${PROFILE_URL2}/${PROFILE} ||
                curl -O ${CURL_OPTIONS} ${PROFILE_URL3}/${PROFILE}
            [[ -s ${PROFILE} ]] && {
                [[ "${PROFILE}" = "aria2.conf" ]] && CONVERSION_ARIA2_CONF
                [[ "${PROFILE}" = "script.conf" ]] && CONVERSION_SCRIPT_CONF
                [[ "${PROFILE}" = "core" ]] && CONVERSION_CORE
                echo
                echo -e "${INFO} '${PROFILE}' download completed !"
            } || {
                echo
                echo -e "${ERROR} '${PROFILE}' download error, retry ..."
                sleep 3
            }
        done
    done
}

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

if ! [[ "${ARIA2_UPDATE_TRACKERS}" = "false" || "${ARIA2_UPDATE_TRACKERS}" = "disable" ]]; then
    (crontab -l ; echo "0 7 * * * umask 022; export CUSTOM_TRACKER_URL=${ARIA2_CUSTOM_TRACKER_URL}; sleep $((RANDOM % 1800)); su-exec bgmi bash /bgmi/conf/aria2/script/tracker.sh /bgmi/conf/aria2/aria2.conf RPC 2>&1 | tee /bgmi/log/tracker.log") | crontab -
    touch /bgmi/log/tracker.log
    PROFILES="tracker.sh"
    DOWNLOAD_PROFILE
    export CUSTOM_TRACKER_URL=${ARIA2_CUSTOM_TRACKER_URL}; bash ${SCRIPT_DIR}/tracker.sh ${ARIA2_CONF}
fi

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

[[ ${ARIA2_RPC_PORT} ]] &&
    sed -i "s@^\(rpc-listen-port=\).*@\1${ARIA2_RPC_PORT}@" ${ARIA2_CONF}

[[ ${ARIA2_LISTEN_PORT} ]] && {
    sed -i "s@^\(listen-port=\).*@\1${ARIA2_LISTEN_PORT}@" ${ARIA2_CONF}
    sed -i "s@^\(dht-listen-port=\).*@\1${ARIA2_LISTEN_PORT}@" ${ARIA2_CONF}
}

[[ ${ARIA2_RPC_SECRET} ]] &&
    sed -i "s@^\(rpc-secret=\).*@\1${ARIA2_RPC_SECRET}@" ${ARIA2_CONF}

[[ ${ARIA2_DISK_CACHE} ]] &&
    sed -i "s@^\(disk-cache=\).*@\1${ARIA2_DISK_CACHE}@" ${ARIA2_CONF}

[[ "${ARIA2_IPV6_MODE}" = "false" || "${ARIA2_IPV6_MODE}" = "disable" ]] && {
    sed -i "s@^\(disable-ipv6=\).*@\1true@" ${ARIA2_CONF}
    sed -i "s@^\(enable-dht6=\).*@\1false@" ${ARIA2_CONF}
}

[[ "${ARIA2_SPECIAL_MODE}" = "rclone" ]] &&
    sed -i "s@^\(on-download-complete=\).*@\1${SCRIPT_DIR}/upload.sh@" ${ARIA2_CONF}

[[ "${ARIA2_SPECIAL_MODE}" = "move" ]] &&
    sed -i "s@^\(on-download-complete=\).*@\1${SCRIPT_DIR}/move.sh@" ${ARIA2_CONF}

# set ariang
sed -i 's|6800|${ARIA2_RPC_PORT}|g' /home/bgmi-docker/downloader/aria2/ariang/js/aria-ng*.min.js

cat /home/bgmi-docker/downloader/aria2/Aria2-Pro

exit 0