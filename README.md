<h1 align="center">qBittorrentScript</h1>

<h3 align="center">一些自用的便利脚本</h3>


#### -----------------ShareRatio_limit-----------------

#### 简介：

    通过qBittorrent的执行外部程序加上本项目的脚本，达到便利化管理个别BT种子下载的需求

#### 运行方式：

### 1.进入QB的容器控制台终端（假如qb的docker容器名称为qbittorrent）
SSH的方式：

    docker ps
    docker exec -it qbittorrent /bin/sh      
    
### 2.运行以下命令

利用加速源下载

    curl -O https://mirror.ghproxy.com/https://raw.githubusercontent.com/LAN-Cliv/qBittorrentScript/main/ShareRatio_limit/script.sh && chmod +x script.sh && ./script.sh
    
可以加入 -x http://ip:prot 来进行本地代理加速脚本下载

    curl -x http://ip:prot -O https://raw.githubusercontent.com/LAN-Cliv/qBittorrentScript/main/ShareRatio_limit/script.sh && chmod +x script.sh && ./script.sh
