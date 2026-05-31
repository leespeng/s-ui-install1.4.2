#!/bin/bash

# 你指定的纯净域名 无国内 无重复 一行多个
DOMAINS=(
"www.microsoft.com" "www.bing.com" "www.yahoo.com" "www.apple.com" "cdn.apple.com"
"init.itunes.apple.com" "books.apple.com" "apps.mzstatic.com" "www.nvidia.com" "investor.nvidia.com"
"www.intel.com" "www.amd.com" "www.ibm.com" "www.oracle.com" "www.sap.com"
"www.adobe.com" "www.canon.com" "www.sony.com" "www.panasonic.com" "www.philips.com"
"www.bosch.com" "www.siemens.com" "www.hp.com" "www.dell.com" "www.lenovo.com"
"www.asus.com" "www.acer.com" "www.toshiba.com" "www.sharp-world.com" "www.cisco.com"
"www.ubuntu.com" "www.debian.org" "www.archlinux.org" "www.fedoraproject.org" "www.kali.org"
"www.python.org" "www.perl.org" "www.php.net" "nodejs.org" "www.eclipse.org"
"www.apache.org" "www.mozilla.org" "addons.mozilla.org" "support.mozilla.org" "www.wikipedia.org"
"en.wikipedia.org" "commons.wikimedia.org" "www.redhat.com" "access.redhat.com" "www.cloudflare.com"
"blog.cloudflare.com" "www.akamai.com" "www.fastly.com" "www.linkedin.com" "www.twitter.com"
"www.facebook.com" "about.fb.com" "www.instagram.com" "www.whatsapp.com" "web.whatsapp.com"
"www.tiktok.com" "www.snapchat.com" "www.pinterest.com" "www.reddit.com" "old.reddit.com"
"www.quora.com" "www.medium.com" "www.github.com" "docs.github.com" "api.github.com"
"www.stackoverflow.com" "www.nytimes.com" "www.washingtonpost.com" "www.bbc.com" "www.theguardian.com"
"www.reuters.com" "www.bloomberg.com" "www.forbes.com" "www.cnn.com" "www.aljazeera.com"
"www.economist.com" "www.ft.com" "www.wsj.com" "www.usatoday.com" "www.huffpost.com"
"www.nationalgeographic.com" "www.discovery.com" "www.imdb.com" "www.rottentomatoes.com" "www.spotify.com"
"open.spotify.com" "www.netflix.com" "www.paypal.com" "www.ebay.com" "www.shopify.com"
"www.salesforce.com" "www.dropbox.com" "www.box.com" "drive.google.com" "docs.google.com"
"www.amazon.com" "smile.amazon.com" "aws.amazon.com" "portal.azure.com" "www.digitalocean.com"
"www.heroku.com" "www.wordpress.com" "www.wix.com" "www.weebly.com" "www.cloudfront.net"
"d1nflstz14dl9t.cloudfront.net"
)

USED=()

echo -e "\n🎲 SNI 延迟测试（纯净域名｜回车继续｜q退出）"
echo -e "💡 绿<50 | 蓝51-150 | 白151-250 | 黄251-500 | 红>500/失败\n"

while true; do
    AVAILABLE=()
    for d in "${DOMAINS[@]}"; do
        [[ ! " ${USED[@]} " =~ " $d " ]] && AVAILABLE+=("$d")
    done

    if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
        echo -e "\n⚠️ 全部测完，自动重置"
        USED=()
        AVAILABLE=("${DOMAINS[@]}")
        read -p "回车继续："
        echo "----------------------------------------"
        continue
    fi

    echo "----------------------------------------"
    echo "正在检测 Reality 伪装网站延迟..."
    echo "----------------------------------------"

    for ((i=0; i<10; i++)); do
        [[ ${#AVAILABLE[@]} -eq 0 ]] && break
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
