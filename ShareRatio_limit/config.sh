#!/bin/bash

# 设置qBittorrent的URL和登录凭据
clear
config_dir=$(dirname "$(realpath "$0")")
echo "-------------------------------------------------------"
echo "配置仅第一次执行脚本时需要设定，后续若需要修改"
echo "请修改脚本同目录下的“config.sh”文件，或删除文件重新配置。"
echo "-------------------------------------------------------"
echo "请输入qBittorrent的URL（示例：http://192.168.50.22:8080）："
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
					echo "qbittorrent_url=\"$qbittorrent_url\"" > config.sh
					echo "qbittorrent_user=\"$qbittorrent_user\"" >> config.sh
					echo "qbittorrent_password=\"$qbittorrent_password\"" >> config.sh
					echo "expected_category=\"$expected_category\"" >> config.sh
					echo "expected_tag=\"$expected_tag\"" >> config.sh
					echo "target_share_ratio_limit=\"$target_share_ratio_limit\"" >> config.sh
					echo "配置已保存到config.sh文件中"
     					echo "请将以下目录路径信息填入qbittorrent的相关设置中"
     					echo "当前文件路径为：$config_dir/scritp.sh "
     					exit
				else
					echo "连接失败，请检查设置！"
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
            exit
			echo "退出脚本"
            break
            ;;
        *)
            echo "请输入 'y', 'n', 'c'，不区分大小写"
            ;;
    esac
done
