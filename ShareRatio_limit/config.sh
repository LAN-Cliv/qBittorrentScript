#!/bin/bash

# 设置qBittorrent的URL和登录凭据
clear

echo "-------------------------------------------------------"
echo "配置仅第一次执行脚本时需要设定，后续若需要修改"
echo "请修改脚本./scriptconfig目录下的“config.sh”文件，或删除文件重新配置。"
echo "-------------------------------------------------------"
echo "请输入qBittorrent的内网IP+端口（示例：http://192.168.50.22:8080）："
read qbittorrent_url

while [ -z "$qbittorrent_url" ]; do
    echo "未输入任何内容，请重新输入："
    read -r qbittorrent_url
done

echo "请输入qBittorrent的用户名："
read qbittorrent_user

while [ -z "$qbittorrent_user" ]; do
    echo "未输入任何内容，请重新输入："
    read -r qbittorrent_user
done

echo "请输入qBittorrent的密码："
read qbittorrent_password

while [ -z "$qbittorrent_password" ]; do
    echo "未输入任何内容，请重新输入："
    read -r qbittorrent_password
done

echo "请输入QBdocker的映射容器内目录："
echo "举例：宿主机目录为/mnt/qbittorrent"
echo "		docker内目录为/config"
echo "		完整映射为/mnt/qbittorrent:/config"
echo "		则填入/config"
echo "		请慎重填写路径，确保为映射的容器内目录路径，否则部分情况下本脚本可能丢失！"
read -p "请输入目录路径： " scriptpath

while [ -z "$scriptpath" ] || [ ! -d "$scriptpath" ]; do
    echo "未输入有效的目录路径，请重新输入："
    read -r scriptpath
done

#TG消息开启状态判断
echo "是否开启Telegram消息通知，输入'1'为开启"
read tg_massage
while [ -z "$tg_massage" ]; do
    echo "未输入任何内容，请重新输入："
    read -r tg_massage
done

[[ $tg_massage -eq 1 ]] && {
    echo "请输入Telegram_Bot的Token值"
	read tg_token
    while [ -z "$tg_token" ]; do
		echo "未输入任何内容，请重新输入："
		read -r tg_token
	done
	
	echo "请输入个人Chat ID"
	read tg_chatid
    while [ -z "$tg_chatid" ]; do
		echo "未输入任何内容，请重新输入："
		read -r tg_chatid
	done
}

[[ $tg_massage -eq 1 ]] && {
    echo "开启消息代理（示例：http://192.168.50.1:3333）"
	read tg_proxy
    while [ -z "$tg_proxy" ]; do
		echo "未输入任何内容，请重新输入："
		read -r tg_proxy
	done
}

if [ $tg_massage -eq 1 ]; then
    tgmsopen="开启"
else
    tgmsopen="关闭"
fi

echo "请输入希望限制的种子分类：（例如：动漫）"
echo "如果不使用分类请输入：A"
echo "默认为A"
read expected_category
if [ -z "$expected_category" ]; then
    expected_category="A"
fi
echo "请输入希望限制的种子标签：（例如：BT）"
echo "如果不使用标签请输入：A"
echo "默认为A"
read expected_tag
if [ -z "$expected_tag" ]; then
    expected_tag="A"
fi
echo "请输入希望限制种子的最大分享率：(仅限数字)"
echo "默认为 3"
read target_share_ratio_limit
if [ -z "$target_share_ratio_limit" ]; then
    target_share_ratio_limit="3"
fi

#确定输入内容
echo "-------------------------------------------------------"
echo "当前设定的qbittorrent_url为：$qbittorrent_url"
echo "当前设定的qbittorrent_user为：$qbittorrent_user"
echo "当前设定的qbittorrent_password为：$qbittorrent_password"
echo "当前设定的种子分类为：$expected_category"
echo "当前设定的种子标签为：$expected_tag"
echo "当前设定的分享率为：$target_share_ratio_limit"
echo "当前设定的脚本目录为：$scriptpath"
echo "当前Telegram消息通知状态为$tgmsopen"
echo "-------------------------------------------------------"

while true; do
    echo "请确定当前输入的配置,并输入 (y：进行下一步/n：重新执行脚本/c：退出脚本执行)"
    read choice
    case "$choice" in
        y)
            
			#测试连通性
				# 临时文件用于存储curl的输出
				response=$(mktemp)

				# 使用curl发送请求并将HTTP状态码输出到临时文件

				echo "进行连接性测试!"
				curl -s -i -o "$response" --header "Referer: $qbittorrent_url" --data "username=$qbittorrent_user&password=$qbittorrent_password" "$qbittorrent_url/api/v2/auth/login"

				# 检查curl的返回值
				if [ $? -eq 0 ]; then
					echo "连接成功"
					echo "qbittorrent_url=\"$qbittorrent_url\"" > $scriptpath/config.sh
					echo "qbittorrent_user=\"$qbittorrent_user\"" >> $scriptpath/config.sh
					echo "qbittorrent_password=\"$qbittorrent_password\"" >> $scriptpath/config.sh
					echo "expected_category=\"$expected_category\"" >> $scriptpath/config.sh
					echo "expected_tag=\"$expected_tag\"" >> $scriptpath/config.sh
					echo "target_share_ratio_limit=\"$target_share_ratio_limit\"" >> $scriptpath/config.sh
					echo "scriptpath=\"$scriptpath\"" >> $scriptpath/config.sh
					#判断TG消息状态并添加相关定义
					[[ $tg_massage -eq 1 ]] && echo "tg_massage=\"$tg_massage\"" >> $scriptpath/config.sh
					[[ $tg_massage -eq 1 ]] && echo "tg_token=\"$tg_token\"" >> $scriptpath/config.sh
					[[ $tg_massage -eq 1 ]] && echo "tg_chatid=\"$tg_chatid\"" >> $scriptpath/config.sh
					[[ $tg_massage -eq 1 ]] && echo "tg_proxy=\"$tg_proxy\"" >> $scriptpath/config.sh
					echo "配置已保存到$scriptpath/config.sh文件中"
					echo "请将以下信息填入qbittorrent的相关设置中"
					echo "复制引号内所有信息' bash $scriptpath/script.sh \"%I\" \"%L\" \"%G\" \"%N\" '填入'新增torrent时运行外部程序'"
					mv script.sh $scriptpath/script.sh
					sleep 2
					rm "$0"
					exit 1
				else
					echo "连接失败，请检查设置！将重新执行脚本"
					sleep 2
					./script.sh
				fi
				
				# 删除临时文件
				rm "$response"
            break
            ;;
        n)
			echo "2秒后重新执行脚本"
			sleep 2
			./script.sh
            ;;
        c)
			echo "退出脚本"
			exit
            break
            ;;
        *)
            echo "请输入 'y', 'n', 'c'，不区分大小写"
            ;;
    esac
done
