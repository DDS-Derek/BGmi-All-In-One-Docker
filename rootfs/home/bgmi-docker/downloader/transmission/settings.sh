#!/usr/bin/with-contenv bash
# shellcheck shell=bash

transmission_config_file="/bgmi/conf/transmission/settings.json"

if [ ! -f /bgmi/conf/transmission ]; then
    mkdir -p /bgmi/conf/transmission
fi

if [ ! -f ${transmission_config_file} ]; then
    cp ${BGMI_HOME}/downloader/transmission/settings.json ${transmission_config_file}
fi

sed -i "/\"rpc-url\"/c\    \"rpc-url\": \"/tr/\"," ${transmission_config_file}

if [[ -n "${TR_USER}" ]] && [[ -n "${TR_PASS}" ]]; then
    sed -i '/rpc-authentication-required/c\    "rpc-authentication-required": true,' ${transmission_config_file}
    sed -i "/rpc-username/c\    \"rpc-username\": \"$TR_USER\"," ${transmission_config_file}
    sed -i "/rpc-password/c\    \"rpc-password\": \"$TR_PASS\"," ${transmission_config_file}
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
