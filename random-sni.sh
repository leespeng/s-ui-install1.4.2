#!/bin/bash

# 域名池（100个，含AMD、家电等）
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
# 确保缓存文件存在
[[ -f "$CACHE_FILE" ]] || touch "$CACHE_FILE"

# ESC 退出清理函数
cleanup_and_exit() {
    echo -e "\n\n👋 按 ESC 退出，缓存保留，下次继续。"
    exit 0
}

# 捕获 ESC（在 read 里处理）
trap '' SIGINT  # 临时屏蔽 Ctrl+C，避免误触

echo -e "\n🎲 SNI 随机域名生成器（回车重抽 / ESC 退出）\n"

while true; do
    # 读取已用
    USED=($(cat "$CACHE_FILE"))
    # 计算可用
    AVAILABLE=()
    for d in "${DOMAINS[@]}"; do
        [[ ! " ${USED[@]} " =~ " $d " ]] && AVAILABLE+=("$d")
    done

    # 情况1：全部抽完 → 清空缓存，最后一组后回到初始态
    if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
        echo -e "⚠️  所有域名已抽完，自动重置缓存！\n"
        > "$CACHE_FILE"
        USED=()
        AVAILABLE=("${DOMAINS[@]}")
        read -n1 -p "🔄 已重置，回车继续或 ESC 退出..." key
        [[ $key == $'\e' ]] && cleanup_and_exit
        continue
    fi

    # 抽10个
    SELECTED=()
    for ((i=0; i<10; i++)); do
        idx=$((RANDOM % ${#AVAILABLE[@]}))
        SELECTED+=("${AVAILABLE[$idx]}")
        USED+=("${AVAILABLE[$idx]}")
        unset AVAILABLE[$idx]
        AVAILABLE=("${AVAILABLE[@]}")
    done

    # 保存已用
    printf "%s\n" "${USED[@]}" > "$CACHE_FILE"

    # 输出结果
    echo -e "\n✅ 本次 10 个 SNI："
    for s in "${SELECTED[@]}"; do echo "  $s"; done
    echo -e "\n📊 剩余：${#AVAILABLE[@]} 个 | 已用：${#USED[@]}"

    # 等待按键：回车=重抽，ESC=退出
    read -n1 -p $'\n🔁 回车重抽 | ESC 退出 → ' key
    [[ $key == $'\e' ]] && cleanup_and_exit
    # 按其他键（含回车）都继续循环
    echo -e "\n----------------------------------------"
done
