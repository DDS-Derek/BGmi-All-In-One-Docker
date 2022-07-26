from bgmi.lib.models import STATUS_DELETED, STATUS_END, STATUS_UPDATING, Followed
from bgmi.front.index import get_player
from bgmi.config import SAVE_PATH
import os
from config import *
import argparse as arg


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
            'name': bangumi['bangumi_name'],
            'season': 1,
            'episode': None,
            'format': None,
        }
        if info['name'] in MAP_RULE:
            oname = bangumi['bangumi_name']
            info['name'] = MAP_RULE[oname]['name']
            info['season'] = MAP_RULE[oname]['season']
        # 获得播放数据
        player_data = get_player(bangumi['bangumi_name'])
        for episode, ep in player_data.items():
            info['episode'] = episode
            path = ep['path']
            info['format'] = path.split('.')[-1]
            # 源位置
            src_path = os.path.join(SAVE_PATH, path[1:])
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
