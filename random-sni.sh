#!/bin/bash

# 域名池
DOMAINS=(
"www.baidu.com" "www.qq.com" "www.taobao.com" "www.jd.com" "www.sina.com"
"www.weibo.com" "www.163.com" "www.sohu.com" "www.360.cn" "www.alipay.com"
"www.tencent.com" "www.bytedance.com" "www.douyin.com" "www.huawei.com" "www.lenovo.com"
"www.midea.com" "www.gree.com" "www.xiaomi.com" "www.cloudflare.com" "crypto.cloudflare.com"
"speed.cloudflare.com" "cloudflare.com" "www.cloudflare.net" "cdn.cloudflare.net" "www.reddit.com"
"www.wikipedia.org" "www.apple.com" "apple.com" "www.microsoft.com" "microsoft.com"
"www.bing.com" "www.google.com" "www.youtube.com" "github.com" "www.github.com"
"www.stackoverflow.com" "www.nginx.com" "www.apache.org" "www.amazon.com"
)

clear
echo -e "\n🎲 SNI 随机域名延迟测试器（回车重抽 | q退出）"
echo -e "💡 绿<50 | 蓝51-150 | 白151-250 | 黄251-500 | 红>500\n"

# 核心：永远随机抽取，永远不会报错，永远用不完
while true; do
    echo "----------------------------------------"
    for ((i=0; i<10; i++)); do
        domain=${DOMAINS[$((RANDOM % ${#DOMAINS[@]}))]}
        delay=$(curl -o /dev/null -s -w "%{time_connect}" "https://$domain:443" 2>/dev/null)

        if [ $? -eq 0 ] && [ -n "$delay" ]; then
            ms=$(awk -v t="$delay" 'BEGIN{printf "%.0f", t*1000}')
            if (( ms < 50 )); then color="\033[32m"
            elif (( ms <= 150 )); then color="\033[34m"
            elif (( ms <= 250 )); then color="\033[0m"
            elif (( ms <= 500 )); then color="\033[33m"
            else color="\033[31m"; ms="9999"
            fi
        else
            color="\033[31m"; ms="9999"
        fi

        echo -e "$color$domain\t$ms ms\033[0m"
    done
    echo "----------------------------------------"

    read -p $'\n回车再测一组 | 输入 q 退出：' key
    [[ "$key" == "q" ]] && echo -e "\n👋 已退出" && exit 0
    clear
done
