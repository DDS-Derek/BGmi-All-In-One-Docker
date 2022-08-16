# bgmi-docker-all-in-one
由https://github.com/codysk/bgmi-docker-all-in-one 镜像改编

支持硬链接，硬链接工具由[kaaass](https://github.com/kaaass/bgmi_hardlink_helper)大佬提供

支持PUID和PGID设置

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
          - TRANSMISSION_WEB_CONTROL=true # 是否启用transmission增强版UI，true为启用，false为使用默认UI
          - BGMI_SOURCE=mikan_project
          - BGMI_ADMIN_TOKEN=password
```