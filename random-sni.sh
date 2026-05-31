#!/bin/bash

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

# 临时记录已用过的域名，用完自动重置
USED=()

echo -e "\n🎲 SNI 延迟测试（和以前一样，回车再测一组，q退出）"
echo -e "💡 绿<50 | 蓝51-150 | 白151-250 | 黄251-500 | 红>500/失败\n"

while true; do
    # 构建可用域名列表
    AVAILABLE=()
    for d in "${DOMAINS[@]}"; do
        [[ ! " ${USED[@]} " =~ " $d " ]] && AVAILABLE+=("$d")
    done

    # 域名用完自动重置
    if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
        echo -e "\n⚠️ 所有域名已测试完毕，自动重置，继续测试..."
        USED=()
        AVAILABLE=("${DOMAINS[@]}")
        read -p "回车继续："
        echo "----------------------------------------"
        continue
    fi

    echo "----------------------------------------"
    echo "正在检测 Reality 伪装网站延迟..."
    echo "----------------------------------------"

    # 随机选10个可用域名
    for ((i=0; i<10; i++)); do
        if [[ ${#AVAILABLE[@]} -eq 0 ]]; then break; fi
        idx=$((RANDOM % ${#AVAILABLE[@]}))
        domain=${AVAILABLE[$idx]}

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

        echo -e "$color$domain\t: $ms ms\033[0m"
        USED+=("$domain")
        unset AVAILABLE[$idx]
        AVAILABLE=("${AVAILABLE[@]}")
    done

    echo "----------------------------------------"
    echo "剩余可用：${#AVAILABLE[@]} | 已用：${#USED[@]}"
    read -p $'\n回车重抽 | 输入 q 退出：' key
    [[ "$key" == "q" ]] && echo -e "\n👋 已退出" && exit 0
done
