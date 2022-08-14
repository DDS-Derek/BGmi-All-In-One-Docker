#######
# 配置 #
#######

# 硬链接目标目录
HARDLINK_DEST = '/media/cartoon'

# 硬链接特殊规则
MAP_RULE = {
    # 键值为 BGmi 显示的番名
    '我立于百万生命之上 第二季': {
        # name 表示映射后的番名
        'name': '我立于百万生命之上',
        # season 表示对应的季名，参照刮削数据库填写
        'season': 2,
    },
    '小林家的龙女仆S': {
        'name': '小林家的龙女仆',
        'season': 2,
    },
}

# 番剧文件夹格式
BANGUMI_FOLDER_FORMAT = "{name}"  # 允许有多层级，如 {name}/Season {season}

# 番剧文件格式
BANGUMI_FILE_FORMAT = "S{season:0>2d}E{episode:0>2d}.{format}"
