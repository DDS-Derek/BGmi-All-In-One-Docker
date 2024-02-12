#!/bin/bash
# shellcheck shell=bash
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="${Green}INFO${Font}"
ERROR="${Red}ERROR${Font}"
WARN="${Yellow}WARN${Font}"
Time=$(date +"%Y-%m-%d %T")
INFO(){
echo -e "${Time} ${INFO}    | ${1}"
}
ERROR(){
echo -e "${Time} ${ERROR}    | ${1}"
}
WARN(){
echo -e "${Time} ${WARN}    | ${1}"
}

BGMI_PATH=$(which bgmi)
DOWNLOAD="--download"

usage(){
    echo -e "Usage: sh crontab.sh [options]\n"
    echo -e "Options:\n  --no-download\t\tNot download bangumi when updated"
    exit
}

if [ $# -ne 1 ] && [ $# -ne 0 ]; then
    usage
fi

if [ $# -eq 1 ] && [ "$1" != "--no-download" ]; then
    usage
fi

if [ $# -eq 1 ] && [ "$1" = "--no-download" ]; then
    DOWNLOAD=""
fi

if crontab -l | grep "bgmi update" > /dev/null; then
    INFO "crontab update already exist"
else
    (crontab -l ; echo "0 */2 * * * umask ${UMASK}; LC_ALL=zh_CN.UTF-8 s6-setuidgid bgmi $BGMI_PATH update $DOWNLOAD") | crontab -
    INFO "crontab update added"
fi


if crontab -l | grep "bgmi cal" > /dev/null; then
    INFO "crontab update cover already exist"
else
    (crontab -l ; echo "40 */10 * * * umask ${UMASK}; LC_ALL=zh_CN.UTF-8 TRAVIS_CI=1 s6-setuidgid bgmi $BGMI_PATH cal --force-update --download-cover") | crontab -
    INFO "crontab update cover added"
fi