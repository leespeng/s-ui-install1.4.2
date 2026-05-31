#!/bin/bash

DOMAINS=(
# 国内大厂
"www.baidu.com"
"www.qq.com"
"www.taobao.com"
"www.jd.com"
"www.sina.com"
"www.weibo.com"
"www.163.com"
"www.sohu.com"
"www.360.cn"
"www.alipay.com"
"www.tencent.com"
"www.bytedance.com"
"www.douyin.com"
"www.huawei.com"
"www.lenovo.com"
"www.midea.com"
"www.gree.com"
"www.xiaomi.com"

# Cloudflare系
"www.cloudflare.com"
"crypto.cloudflare.com"
"speed.cloudflare.com"
"cloudflare.com"
"www.cloudflare.net"
"cdn.cloudflare.net"
"www.reddit.com"
"www.wikipedia.org"
"www.cloudflare-cdn.com"
"blog.cloudflare.com"
"api.cloudflare.com"
"dash.cloudflare.com"
"support.cloudflare.com"
"developers.cloudflare.com"
"community.cloudflare.com"

# 苹果+微软
"www.apple.com"
"apple.com"
"www.microsoft.com"
"microsoft.com"
"www.bing.com"
"www.office.com"
"www.xbox.com"
"www.microsoftstore.com"
"learn.microsoft.com"
"update.microsoft.com"

# 谷歌/社交
"www.google.com"
"www.youtube.com"
"www.facebook.com"
"www.instagram.com"
"www.twitter.com"
"www.tiktok.com"
"www.discord.com"
"www.spotify.com"
"www.telegram.org"
"www.snapchat.com"
"www.pinterest.com"
"www.linkedin.com"
"www.wechat.com"
"www.aliexpress.com"

# 技术/开源
"github.com"
"www.github.com"
"www.stackoverflow.com"
"stackoverflow.com"
"www.gitlab.com"
"www.npmjs.com"
"www.docker.com"
"www.kubernetes.io"
"www.nginx.com"
"www.apache.org"

# 科技/硬件品牌（含AMD/华硕/微星等）
"www.amazon.com"
"www.ebay.com"
"www.netflix.com"
"www.nvidia.com"
"www.openai.com"
"www.cisco.com"
"www.oracle.com"
"www.ibm.com"
"www.samsung.com"
"www.sony.com"
"www.intel.com"
"www.amd.com"
"www.asus.com"
"www.msi.com"
"www.gigabyte.com"
"www.dell.com"
"www.hp.com"

# 家电/消费电子品牌（含LG/松下/美的等）
"www.lg.com"
"www.panasonic.com"
"www.toshiba.com"
"www.philips.com"
"www.hisense.com"
"www.tcl.com"
"www.ford.com"
"www.bmw.com"
"www.mercedes-benz.com"
"www.vmware.com"
"www.qualcomm.com"
)

CACHE_FILE="$HOME/.sni_cache"
touch "$CACHE_FILE"
USED=($(cat "$CACHE_FILE"))

AVAILABLE=()
for d in "${DOMAINS[@]}"; do
    if ! [[ " ${USED[@]} " =~ " $d " ]]; then
        AVAILABLE+=("$d")
    fi
done

if [ ${#AVAILABLE[@]} -lt 10 ]; then
    echo -e "\n🔄 已抽完所有域名，自动重置缓存..."
    > "$CACHE_FILE"
    AVAILABLE=("${DOMAINS[@]}")
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

echo -e "\n✅ 本次随机 10 个 SNI 伪装域名：\n"
for s in "${SELECTED[@]}"; do
    echo "  $s"
done

echo -e "\n📊 剩余可用：${#AVAILABLE[@]} 个"
echo "ℹ️ 再次运行 = 抽下一组 10 个（不重复）"
echo
