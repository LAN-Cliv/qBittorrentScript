#!/bin/bash

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
echo "$expected_category"

echo "请输入希望限制的种子标签：（例如：BT）"
echo "如果不使用标签请输入：A"
read expected_tag
echo "$expected_tag"

echo "请输入希望限制种子的最大分享率："
read -s target_share_ratio_limit

#测试连通性
# 临时文件用于存储curl的输出
response=$(mktemp)

# 使用curl发送请求并将HTTP状态码输出到临时文件
curl -s -i -o "$response" --header "Referer: $qbittorrent_url" --data "username=$qbittorrent_user&password=$qbittorrent_password" "$qbittorrent_url/api/v2/auth/login"

# 检查curl的返回值
if [ $? -eq 0 ]; then
    echo "连接成功"
	echo "qbittorrent_url=\"$qbittorrent_url\"" > config.sh
	echo "qbittorrent_user=\"$qbittorrent_user\"" >> config.sh
	echo "qbittorrent_password=\"$qbittorrent_password\"" >> config.sh
	echo "expected_category=\"$expected_category\"" >> config.sh
	echo "expected_tag=\"$expected_tag\"" >> config.sh
	echo "target_share_ratio_limit=\"$target_share_ratio_limit\"" >> config.sh
	echo "配置已保存到config.sh文件中"
else
    echo "连接失败，请检查设置！"
fi

# 删除临时文件
rm "$response"
