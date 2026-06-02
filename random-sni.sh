#!/bin/bash

DOMAINS=(
"www.nvidia.com" "investor.nvidia.com" "www.intel.com" "www.amd.com" "www.ibm.com"
"www.oracle.com" "www.sap.com" "www.adobe.com" "www.canon.com" "www.sony.com"
"www.panasonic.com" "www.philips.com" "www.bosch.com" "www.siemens.com" "www.hp.com"
"www.dell.com" "www.lenovo.com" "www.asus.com" "www.acer.com" "www.toshiba.com"
"www.sharp-world.com" "www.cisco.com" "www.hitachi.com" "www.fujitsu.com" "www.nec.com"
"www.epson.com" "www.ricoh.com" "www.kyocera.com" "www.brother.com" "www.honeywell.com"
"www.ubuntu.com" "www.debian.org" "www.archlinux.org" "www.fedoraproject.org" "www.kali.org"
"www.python.org" "www.perl.org" "www.php.net" "nodejs.org" "www.eclipse.org"
"www.apache.org" "www.mysql.com" "www.postgresql.org" "www.sqlite.org" "www.docker.com"
"www.kubernetes.io" "www.rust-lang.org" "www.golang.org" "www.typescriptlang.org" "www.ruby-lang.org"
"www.harvard.edu" "www.mit.edu" "www.stanford.edu" "www.berkeley.edu" "www.ox.ac.uk"
"www.cam.ac.uk" "www.caltech.edu" "www.princeton.edu" "www.yale.edu" "www.columbia.edu"
"www.ethz.ch" "www.u-tokyo.ac.jp" "www.kyoto-u.ac.jp" "www.nus.edu.sg" "www.utoronto.ca"
"www.toyota.com" "www.honda.com" "www.nissan-global.com" "www.bmw.com" "www.mercedes-benz.com"
"www.audi.com" "www.volkswagen.com" "www.hyundai.com" "www.ford.com" "www.gm.com"
"www.ikea.com" "www.costco.com" "www.walmart.com" "www.target.com" "www.nike.com"
"www.adidas.com" "www.puma.com" "www.rolex.com" "www.seiko.co.jp" "www.casio.com"
"www.hsbc.com" "www.citigroup.com" "www.jpmorganchase.com" "www.goldmansachs.com" "www.morganstanley.com"
"www.barclays.com" "www.db.com" "www.ubs.com" "www.bnpparibas.com" "www.visa.com"
"www.mastercard.com" "www.amex.com" "www.fedex.com" "www.ups.com" "www.dhl.com"
"www.autodesk.com" "www.solidworks.com" "www.ansys.com" "www.mathworks.com" "www.salesforce.com"
"www.dropbox.com" "www.box.com" "www.shopify.com" "www.squarespace.com" "www.wix.com"
"www.webex.com" "www.zoom.us" "www.skype.com" "www.vimeo.com" "www.flickr.com"
"www.porsche.com" "www.ferrari.com" "www.astonmartin.com" "www.michelin.com" "www.bridgestone.com"
"www.continental.com" "www.goodyear.com" "www.pirelli.com" "www.kawasaki.com" "www.yamaha-motor.eu"
"www.suzuki.co.jp" "www.mazda.com" "www.subaru-global.com" "www.mitsubishi-motors.com" "www.isuzu.co.jp"
"www.volvocars.com" "www.jaguar.com" "www.landrover.com" "www.renaultgroup.com" "www.peugeot.com"
"www.citroen.com" "www.fiat.com" "www.alfaromeo.com" "www.jeep.com" "www.caterpillar.com"
"www.louisvuitton.com" "www.gucci.com" "www.chanel.com" "www.hermes.com" "www.prada.com"
"www.dior.com" "www.armani.com" "www.burberryplc.com" "www.ralphlauren.com" "www.omega.com"
"www.tagheuer.com" "www.longines.com" "www.tissotwatches.com" "www.swatch.com" "www.cartier.com"
"www.tiffany.com" "www.bulgari.com" "www.shiseidogroup.com" "www.loreal.com" "www.unilever.com"
"www.henkel.com" "www.colgatepalmolive.com" "www.pg.com" "www.pfizer.com" "www.roche.com"
"www.novartis.com" "www.merck.com" "www.abbvie.com" "www.bayer.com" "www.sanofi.com"
"www.bms.com" "www.astrazeneca.com" "www.gsk.com" "www.takeda.com" "www.amgen.com"
"www.gilead.com" "www.biogen.com" "www.medtronic.com" "www.siemens-healthineers.com" "www.gehealthcare.com"
"www.stryker.com" "www.shell.com" "www.bp.com" "www.chevron.com" "www.totalenergies.com"
"www.exxonmobil.com" "www.basf.com" "www.dow.com" "www.dupont.com" "www.3m.com"
"www.linde.com"
)

TOTAL_COUNT=${#DOMAINS[@]}
AVAILABLE=("${DOMAINS[@]}")
USED_COUNT=0

echo -e "\n🎲 SNI 延迟测试（200个精选域名轮询｜回车继续｜q退出）"
echo -e "💡 绿 <50ms | 蓝 51-150ms | 黄 151-250ms | 紫 251-500ms | 红 >500ms/失败\n"

while true; do
    if [[ ${#AVAILABLE[@]} -eq 0 ]]; then
        echo -e "\n🔄 200个精选域名已全部测完，正在自动重置域名池..."
        AVAILABLE=("${DOMAINS[@]}")
        USED_COUNT=0
        read -p "按回车键重新开始全新一轮轮询测试："
        echo "------------------------------------------------------------"
        continue
    fi

    echo "------------------------------------------------------------"
    echo "正在从剩余池子中随机抽取 10 个进行 Reality 延迟检测..."
    echo "------------------------------------------------------------"

    for ((i=0; i<10; i++)); do
        [[ ${#AVAILABLE[@]} -eq 0 ]] && break
        
        idx=$((RANDOM % ${#AVAILABLE[@]}))
        domain=${AVAILABLE[$idx]}

        delay=$(curl -o /dev/null -s -m 2 -w "%{time_connect}" "https://$domain:443" 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$delay" ] && [ "$delay" != "0.000" ]; then
            ms=$(awk -v t="$delay" 'BEGIN{printf "%.0f", t*1000}')
            if (( ms < 50 )); then color="\033[1;32m"
            elif (( ms <= 150 )); then color="\033[1;34m"
            elif (( ms <= 250 )); then color="\033[1;33m"
            elif (( ms <= 500 )); then color="\033[1;35m"
            else color="\033[1;31m"; ms="9999"
            fi
        else
            color="\033[1;31m"; ms="9999"
        fi

        printf "%b%-35s\t: %s ms\033[0m\n" "$color" "$domain" "$ms"

        ((USED_COUNT++))
        unset 'AVAILABLE[idx]'
        AVAILABLE=("${AVAILABLE[@]}")
    done

    echo "------------------------------------------------------------"
    echo "当前进度：已测试 $USED_COUNT / $TOTAL_COUNT | 剩余未测：${#AVAILABLE[@]}"
    
    read -p $'\n⏎ 按回车抽取下10个 | 输入 q 退出回到终端：' key
    [[ "$key" == "q" || "$key" == "Q" ]] && echo -e "\n👋 已退出测试，顺利返回 root 终端。\n" && exit 0
done
EOF
