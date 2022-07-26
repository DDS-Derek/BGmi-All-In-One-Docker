# bgmi-docker-all-in-one
由https://github.com/codysk/bgmi-docker-all-in-one 镜像改编
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
```
