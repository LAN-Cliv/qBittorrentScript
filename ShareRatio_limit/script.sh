#!/bin/bash

# 检查本地是否存在 config.sh 文件
if [ -f "./config.sh" ]; then
    source ./config.sh
elif [ -f "$scriptpath/config.sh" ]; then
    source "$scriptpath/config.sh"
else
    echo "本地和指定路径下的 config.sh 文件都不存在，开始下载..."
	sleep 2
    # 从GitHub下载config.sh文件
    curl -s -o config.sh https://raw.githubusercontent.com/LAN-Cliv/qBittorrentScript/main/ShareRatio_limit/config.sh
    if [ $? -eq 0 ]; then        
        echo "config.sh文件下载成功！"
        chmod +x config.sh
        ./config.sh
        exit 1
    else
        echo "下载失败，请检查网络连接或手动下载文件。"
        echo "下载地址：https://raw.githubusercontent.com/LAN-Cliv/qBittorrentScript/main/ShareRatio_limit/config.sh"
        exit 1
    fi
fi

# 设置时区
export TZ=Asia/Shanghai

#传入种子哈希值
torrent_hash=$1
torrent_name=$4

#判断分类与标签值
if [ "$expected_category" == "A" ]; then
    torrent_category="A"
else
    torrent_category=$2
fi


if [ "$expected_tag" == "A" ]; then
    torrent_tag="A"
else
    torrent_tag=$3
fi

#TG消息相关
tg_api="https://api.telegram.org/bot$tg_token/sendMessage"
sendtg="curl -s -x $tg_proxy -X POST $tg_api -d chat_id=$tg_chatid -d text="

# 登录qBittorrent并获取SID
login_response=$(curl -s -i --header "Referer: $qbittorrent_url" --data "username=$qbittorrent_user&password=$qbittorrent_password" "$qbittorrent_url/api/v2/auth/login")
# 传入SID
sid=$(echo "$login_response" | awk 'tolower($0) ~ /set-cookie: sid=/ {split($0,a,"SID="); split(a[2],b,";"); print b[1]; exit}')

# 获取脚本所在目录的绝对路径
script_dir=$(dirname "$(realpath "$0")")

# 日志目录和文件名
log_dir="${script_dir}/ShareLimits"

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
cleanup_logs

# 播种时间限制，-1 表示不限制
seeding_time_limit=-1
# 无活动播种时间限制，-1 表示不限制
inactive_seeding_time_limit=-1

# 检查种子是否符合指定的分类和标签
if [ "$torrent_category" == "$expected_category" ] && [ "$torrent_tag" == "$expected_tag" ]; then
    #log_message "种子 $torrent_hash 符合指定的分类和标签。"
    # 符合条件，设置分享率上限
    curl -s "$qbittorrent_url/api/v2/torrents/setShareLimits" \
         --header 'Content-Type: application/x-www-form-urlencoded' \
		 --header "Cookie: SID=$sid" \
         --data-urlencode "hashes=$torrent_hash" \
         --data-urlencode "ratioLimit=$target_share_ratio_limit" \
         --data-urlencode "seedingTimeLimit=$seeding_time_limit" \
         --data-urlencode "inactiveSeedingTimeLimit=$inactive_seeding_time_limit"
         
    log_message "成功设置种子 $torrent_name 的分享率上限为 $target_share_ratio_limit。"
	[[ $tg_massage -eq 1 ]] && $sendtg"成功设置种子 $torrent_name 的分享率上限为 $target_share_ratio_limit。"
else
    log_message "种子 $torrent_hash 不符合指定的分类和标签，跳过。"
fi
