#!/bin/sh

cd ${WORKDIR}

echo -e "
PUID=${PUID}
PGID=${PGID}
Umask=${UMASK}
"

# 更改 nt userid 和 groupid
groupmod -o -g "$PGID" nt
usermod -o -u "$PUID" nt

# 掩码设置
umask "${UMASK}"

# 创建目录、权限设置
media_cartoon=${MEDIA_DIR}
meida_downloads=${DOWNLOAD_DIR}
if [ ! -d $media_cartoon ]; then
	mkdir -p $media_cartoon
fi
if [ ! -d $meida_downloads ]; then
	mkdir -p $meida_downloads
fi
chown -R nt:nt "${WORKDIR}" "${NT_HOME}" /config /etc/hosts
if [[ "$(stat -c '%U' /media)" != "nt" ]] || [[ "$(stat -c '%G' /media)" != "nt" ]]; then
    chown nt:nt \
        /media
fi
if [[ "$(stat -c '%U' ${MEDIA_DIR})" != "nt" ]] || [[ "$(stat -c '%G' ${MEDIA_DIR})" != "nt" ]]; then
    chown nt:nt \
        ${MEDIA_DIR}
fi
if [[ "$(stat -c '%U' ${DOWNLOAD_DIR})" != "nt" ]] || [[ "$(stat -c '%G' ${DOWNLOAD_DIR})" != "nt" ]]; then
    chown nt:nt \
        ${DOWNLOAD_DIR}
fi

# 启动主程序
exec su-exec nt:nt "$(which dumb-init)" "$(which pm2-runtime)" start run.py -n NAStool --interpreter python3