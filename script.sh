#!/bin/bash

# 设置时区
export TZ=Asia/Shanghai

# *qBittorrent的登录认证
qbittorrent_url="http://192.168.50.21:8080"
qbittorrent_user="user"
qbittorrent_password="password"

# 登录qBittorrent并获取SID
login_response=$(curl -s -i -X POST "$qbittorrent_url/api/v2/auth/login" --data "username=$qbittorrent_user&password=$qbittorrent_password" --header "Referer: $qbittorrent_url/" --compressed)
sid=$(echo "$login_response" | grep -oP 'Set-Cookie: SID=\K[^;]+')

# *目标种子分类和标签
expected_category="分类名"
expected_tag="A"

# qBittorrent执行程序时传递的参数(修改qBittorrent处，这里不用管)
torrent_hash=$1
torrent_category=$2
torrent_tag="A"



# *分享率上限设置(达到改分享率即可暂停种子)
target_share_ratio_limit=3


# 获取脚本所在目录的绝对路径
script_dir=$(dirname "$(realpath "$0")")

# 日志目录和文件名
log_dir="${script_dir}/ShareRatio"

log_file="${log_dir}/$(date '+%Y-%m-%d')-setShareLimits.log"

# 确保日志目录存在
mkdir -p "$log_dir"

# 日志记录函数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file"
}

# 检查并清理旧日志
cleanup_logs() {
    find "$log_dir" -type f -name '*.log' -mtime +7 -exec rm {} \;
}

# 清理旧日志
cleanup_logs

log_message "种子分类:$torrent_category。设定分类:$expected_category "
log_message "种子标签:$torrent_tag。设定标签:$expected_tag "

# 播种时间限制，-1 表示不限制
seeding_time_limit=-1
# 无活动播种时间限制，-1 表示不限制
inactive_seeding_time_limit=-1

# 检查种子是否符合指定的分类和标签
if [ "$torrent_category" == "$expected_category" ] && [ "$torrent_tag" == "$expected_tag" ]; then
    log_message "种子 $torrent_hash 符合指定的分类和标签。"
    # 符合条件，设置分享率上限
    curl -s "$qbittorrent_url/api/v2/torrents/setShareLimits" \
         --header 'Content-Type: application/x-www-form-urlencoded' \
		 --header "Cookie: SID=$sid" \
         --data-urlencode "hashes=$torrent_hash" \
         --data-urlencode "ratioLimit=$target_share_ratio_limit" \
         --data-urlencode "seedingTimeLimit=$seeding_time_limit" \
         --data-urlencode "inactiveSeedingTimeLimit=$inactive_seeding_time_limit"
         
    log_message "成功设置种子 $torrent_hash 的分享率上限为 $target_share_ratio_limit。"
else
    log_message "种子 $torrent_hash 不符合指定的分类和标签，跳过。"
fi
