from bgmi.lib.models import STATUS_DELETED, STATUS_UPDATING, Followed
from bgmi.front.index import get_player
from bgmi import config as bgmi_config
import os
import sys
config_path = os.getenv("BGMI_HARDLINK_PATH")
if config_path:
    sys.path.append(config_path)
from config import *
import argparse as arg
import re

if hasattr(bgmi_config, 'SAVE_PATH'):
    save_path = bgmi_config.SAVE_PATH
elif hasattr(bgmi_config, 'cfg'):
    save_path = bgmi_config.cfg.save_path
else:
    print("不支持此 BGmi 版本！")
    exit(1)

_CHINESE_NUMBERS = '一二三四五六七八九十'


def extract_season_from_bgmi(bgmi_data: dict):
    """从 BGmi 的番剧信息中获得剧集的季信息"""
    info = {
        'name': bgmi_data['bangumi_name'],
        'season': 1,
    }

    # 特殊规则
    rule = MAP_RULE.get(info['name'], None)
    if rule is not None:
        info['name'] = rule['name']
        info['season'] = rule['season']
        return info

    # 检查番剧名中的季
    r = re.search(r'^(.*?) ?第(.)季$', info['name'])
    if r is not None:
        season = r.group(2)

        # 解析季数
        if season in _CHINESE_NUMBERS:
            season = _CHINESE_NUMBERS.index(season) + 1
        else:
            try:
                season = int(season)
            except ValueError:
                season = None

        if season is not None:
            info['name'] = r.group(1)
            info['season'] = season

    return info


def run_hardlink(preview=False):
    """
    进行番剧硬链接
    :param preview: 是否预览硬链接
    """

    # 获取番剧数据
    data = Followed.get_all_followed(STATUS_DELETED, STATUS_UPDATING)
    print("共订阅", len(data), "番剧，开始扫描...")

    # 创建硬链接
    link_count = 0
    for bangumi in data:
        # 获得信息
        info = {
            'name': '',
            'season': 1,
            'episode': None,
            'format': None,
        }
        info.update(extract_season_from_bgmi(bangumi))
        # 获得播放数据
        player_data = get_player(bangumi['bangumi_name'])
        for episode, ep in player_data.items():
            info['episode'] = episode
            path = ep['path']
            info['format'] = path.split('.')[-1]
            # 源位置
            src_path = os.path.join(save_path, path[1:])
            # 目标位置
            dst_dir = os.path.join(
                HARDLINK_DEST,
                BANGUMI_FOLDER_FORMAT.format(**info)
            )
            dst_path = os.path.join(
                dst_dir,
                BANGUMI_FILE_FORMAT.format(**info)
            )
            # 目录判断
            if not os.path.exists(dst_dir):
                os.makedirs(dst_dir)
            if os.path.exists(dst_path):
                # 已经链接过
                continue
            # 硬链接
            if preview:
                print(src_path, "-->", dst_path)
            else:
                os.link(src_path, dst_path)
            link_count += 1

    print("共链接", link_count, "个文件")


def install_cron():
    """
    安装 crontab 任务
    """
    script_path = os.path.realpath(__file__)
    cmd = '(crontab -l;printf "0 */2 * * * ' \
          'LC_ALL=en_US.UTF-8 python3 ' + script_path + ' run\n")|crontab -'
    os.system(cmd)
    print("安装成功")


if __name__ == '__main__':
    parser = arg.ArgumentParser(
        description='BGmi 硬链接工具')
    parser.add_argument(dest='action', metavar='动作',
                        help='预览（preview）、运行（run）、设置定时任务（install_cron）')
    args = parser.parse_args()
    action = args.action
    if action == 'preview':
        run_hardlink(True)
    elif action == 'run':
        run_hardlink(False)
    elif action == 'install_cron':
        install_cron()
    else:
        print("动作不存在")
        exit(1)