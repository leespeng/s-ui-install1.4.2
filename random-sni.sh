#!/bin/bash

# 域名池（100个）
DOMAINS=(
"www.baidu.com" "www.qq.com" "www.taobao.com" "www.jd.com" "www.sina.com"
"www.weibo.com" "www.163.com" "www.sohu.com" "www.360.cn" "www.alipay.com"
"www.tencent.com" "www.bytedance.com" "www.douyin.com" "www.huawei.com" "www.lenovo.com"
"www.midea.com" "www.gree.com" "www.xiaomi.com" "www.cloudflare.com" "crypto.cloudflare.com"
"speed.cloudflare.com" "cloudflare.com" "www.cloudflare.net" "cdn.cloudflare.net" "www.reddit.com"
"www.wikipedia.org" "www.cloudflare-cdn.com" "blog.cloudflare.com" "api.cloudflare.com" "dash.cloudflare.com"
"support.cloudflare.com" "developers.cloudflare.com" "community.cloudflare.com" "www.apple.com" "apple.com"
"www.microsoft.com" "microsoft.com" "www.bing.com" "www.office.com" "www.xbox.com"
"www.microsoftstore.com" "learn.microsoft.com" "update.microsoft.com" "www.google.com" "www.youtube.com"
"www.facebook.com" "www.instagram.com" "www.twitter.com" "www.tiktok.com" "www.discord.com"
"www.spotify.com" "www.telegram.org" "www.snapchat.com" "www.pinterest.com" "www.linkedin.com"
"www.wechat.com" "www.aliexpress.com" "github.com" "www.github.com" "www.stackoverflow.com"
"stackoverflow.com" "www.gitlab.com" "www.npmjs.com" "www.docker.com" "www.kubernetes.io"
"www.nginx.com" "www.apache.org" "www.amazon.com" "www.ebay.com" "www.netflix.com"
"www.nvidia.com" "www.openai.com" "www.cisco.com" "www.oracle.com" "www.ibm.com"
"www.samsung.com" "www.sony.com" "www.intel.com" "www.amd.com" "www.asus.com"
"www.msi.com" "www.gigabyte.com" "www.dell.com" "www.hp.com" "www.lg.com"
"www.panasonic.com" "www.toshiba.com" "www.philips.com" "www.hisense.com" "www.tcl.com"
)

CACHE_FILE="$HOME/.sni_cache"
[[ -f "$CACHE_FILE" ]] || touch "$CACHE_FILE"

cleanup_and_exit() {
    echo -e "\n👋 按 ESC 退出，缓存保留，下次继续。"
    exit 0
}

trap '' SIGINT

echo -e "\n🎲 SNI 随机域名延迟测试器（回车重抽 / ESC 退出）\n"

while true; do
    USED=($(cat "$CACHE_FILE"))
    AVAILABLE=()
    for d in "${DOMAINS[@]}"; do
        [[ ! " ${USED[@]} " =~ " $d " ]] && AVAILABLE+=("$d")
    done

    if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
        echo -e "⚠️  所有域名已抽完，自动重置缓存！\n"
        > "$CACHE_FILE"
        USED=()
        AVAILABLE=("${DOMAINS[@]}")
        read -n1 -p "🔄 已重置，回车继续或 ESC 退出..." key
        [[ $key == $'\e' ]] && cleanup_and_exit
        continue
    fi

    SELECTED=()
    for ((i=0; i<10; i++)); do
        idx=$((RANDOM % ${#AVAILABLE[@]}))
        SELECTED+=("${AVAILABLE[$idx]}")
        USED+=("${AVAILABLE[$idx]}")
        unset AVAILABLE[$idx]
        AVAILABLE=("${AVAILABLE[@]}")
    done

    printf "%s\n" "${USED[@]}" > "$CACHE_FILE"

    echo -e "🔍 正在为您检测这10个域名的延迟..."
    echo "----------------------------------------"

    # 先输出所有域名的延迟，不排序，也不用数组/临时文件
    echo -e "\n✅ 本次10个域名延迟测试结果："
    for domain in "${SELECTED[@]}"; do
        delay=$(curl -o /dev/null -s -w "%{time_connect}\n" "https://$domain:443" 2>/dev/null)
        if [[ $? -eq 0 && -n "$delay" ]]; then
            delay_ms=$(echo "$delay * 1000" | bc | awk '{printf "%.0f", $0}')
            if (( delay_ms < 100 )); then
                echo -e "\033[32m$domain : $delay_ms ms\033[0m"
            elif (( delay_ms < 500 )); then
                echo -e "\033[33m$domain : $delay_ms ms\033[0m"
            else
                echo -e "\033[31m$domain : $delay_ms ms\033[0m"
            fi
        else
            echo -e "\033[31m$domain : 9999 ms\033[0m"
        fi
    done

    echo -e "\n📊 剩余可用：${#AVAILABLE[@]} 个 | 已用：${#USED[@]}"
    echo -e "💡 绿色=延迟低（推荐） 黄色=延迟中等 红色=延迟高/失败"

    read -n1 -p $'\n🔁 回车重抽下一组 | ESC 退出 → ' key
    [[ $key == $'\e' ]] && cleanup_and_exit
    echo -e "\n----------------------------------------"
done
