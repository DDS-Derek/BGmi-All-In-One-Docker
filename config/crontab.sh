#!/bin/sh

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
    echo "Usage: sh crontab.sh [options]\n"
    echo "Options:\n  --no-download\t\tNot download bangumi when updated"
    exit
}

if [ $# -ne 1 -a $# -ne 0 ]; then
    usage
fi

if [ $# -eq 1 -a "$1" != "--no-download" ]; then
    usage
fi

if [ $# -eq 1 -a "$1" = "--no-download" ]; then
    DOWNLOAD=""
fi

crontab -l | grep "bgmi update" > /dev/null
if [ $? -eq 0 ]; then
    INFO "crontab update already exist"
else
    (crontab -l ; echo "0 */2 * * * umask ${UMASK}; LC_ALL=en_US.UTF-8 su-exec bgmi $BGMI_PATH update $DOWNLOAD") | crontab -
    INFO "crontab update added"
fi


crontab -l | grep "bgmi cal" > /dev/null
if [ $? -eq 0 ]; then
    INFO "crontab update cover already exist"
else
    (crontab -l ; echo "40 */10 * * * umask ${UMASK}; LC_ALL=en_US.UTF-8 TRAVIS_CI=1 su-exec bgmi $BGMI_PATH cal --force-update --download-cover") | crontab -
    INFO "crontab update cover added"
fi