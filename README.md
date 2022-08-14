# bgmi-docker-all-in-one
由https://github.com/codysk/bgmi-docker-all-in-one 镜像改编

硬链接工具由[kaaass](https://github.com/kaaass/bgmi_hardlink_helper)大佬提供

因为默认bgmi是没有用户设置的，文件夹默认都是root用户的，所以我增加了PUID和PGID的设置，是通过定时设置容器内```/media/cartoon```文件的权限和用户组来实现的，这样既不影响bgmi和transmission，也可以解决文件权限不足的问题

如果需要重新配置GUID和PUID请删除配置文件目录下```./bgmi_hardlink_helper/userid.sh```文件，其他文件可以保持不变

支持是否开启内部transmission，可以在环境变量内设置是否启用

支持transmission增强版UI，可以在环境变量内设置是否启用

```
version: '3.3'
services:
    bgmi:
        image: ddsderek/bgmi-docker-all-in-one:latest
        container_name: "bgmi"
        restart: "always"
        volumes:
          - /bgmi:/bgmi  # config文件夹
          - /home/video2/NEW:/media  # 动漫文件
        ports:
            - '80:80'
            - '9091:9091'
            - '51413:51413/tcp'
            - '51413:51413/udp'
        environment:
          - TZ=Asia/Shanghai
          - PGID=1000
          - PUID=1000
          - TRANSMISSION=true  # 是否开启内部transmission，true为开启，false为关闭，如果使用外部transmission，可以选择false关闭内部transmission
          - TRANSMISSION_WEB_CONTROL=true # 是否启用transmission增强版UI，true为启用，false为使用默认UI，transmission增强版UI效果如图下图
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
```
![screenshots](https://user-images.githubusercontent.com/8065899/38598199-0d2e684c-3d8e-11e8-8b21-3cd1f3c7580a.png)