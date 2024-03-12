#!/bin/bash
# config.sh

# 设置qBittorrent的URL和登录凭据
echo "请输入qBittorrent的URL（例如：http://ip:port）："
read qbittorrent_url

echo "请输入qBittorrent的用户名："
read qbittorrent_user

echo "请输入qBittorrent的密码："
read -s qbittorrent_password

echo "请输入希望限制的种子分类：（例如：动漫）"
echo "如果不使用分类请输入：A"
read expected_category

echo "请输入希望限制的种子标签：（例如：BT）"
echo "如果不使用标签请输入：A"
read expected_tag


# 将变量写入配置文件
echo "qbittorrent_url=\"$qbittorrent_url\"" > config.sh
echo "qbittorrent_user=\"$qbittorrent_user\"" >> config.sh
echo "qbittorrent_password=\"$qbittorrent_password\"" >> config.sh
echo "torrent_hash=\"$1\"" >> config.sh

if [ "$expected_category" == "A" ]; then
    echo "torrent_tag=\"$torrent_tag\"" >> config.sh
else
    echo "torrent_tag=\"$3\"" >> config.sh
fi

if [ "$expected_tag" == "A" ]; then
    echo "torrent_category=\"$torrent_category\"" >> config.sh
else
    echo "torrent_category=\"$4\"" >> config.sh
fi

echo "配置已保存到config.sh文件中"

echo "$qbittorrent_url / $qbittorrent_user / $qbittorrent_password / $expected_category / $expected_tag / $torrent_tag / $torrent_category"

# 下载scrip.sh文件
if [ ! -f "script.sh" ]; then
    echo "下载脚本文件"
    curl -s -o script.sh https://raw.githubusercontent.com/LAN-Cliv/qBittorrentScript/main/script.sh
fi
