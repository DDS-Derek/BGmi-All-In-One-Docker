# bgmi-docker-all-in-one
由https://github.com/codysk/bgmi-docker-all-in-one 镜像改编

硬链接工具由[kaaass](https://github.com/kaaass/bgmi_hardlink_helper)大佬提供

因为默认bgmi是没有用户设置的，文件夹默认都是root用户的，所以我增加了PUID和PGID的设置，是通过定时设置容器内```/media/cartoon```文件的权限和用户组来实现的，这样既不影响bgmi和transmission，也可以解决文件权限不足的问题

如果需要重新配置GUID和PUID请删除配置文件目录下```./bgmi_hardlink_helper/userid.sh```文件，其他文件可以保持不变

默认版本，只增加了GUID,PUID和硬链接
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
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
          - TZ=Asia/Shanghai
          - PGID=1000
          - PUID=1000
```
如果你使用外置下载器，可以使用下面这个版本，默认关闭了transmission，但是transmission配置文件还是会正常生成的
```
version: '3.3'
services:
    bgmi:
        image: ddsderek/bgmi-docker-all-in-one:latest-notransmission
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
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
          - TZ=Asia/Shanghai
          - PGID=1000
          - PUID=1000
```
UI加强版，在默认版本的基础上增加了transmission-web-control UI，效果如图
![screenshots](https://user-images.githubusercontent.com/8065899/38598199-0d2e684c-3d8e-11e8-8b21-3cd1f3c7580a.png)
```
version: '3.3'
services:
    bgmi:
        image: ddsderek/bgmi-docker-all-in-one:latest-web-control
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
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
          - TZ=Asia/Shanghai
          - PGID=1000
          - PUID=1000
```
