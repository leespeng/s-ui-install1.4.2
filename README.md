#!/bin/bash
set -e
mkdir -p /opt/s-ui && cd /opt/s-ui
wget -O s-ui-1.4.2_full.tar.gz "https://github.com/leespeng/s-ui-install1.4.2/releases/download/v1.0/s-ui-1.4.2_full.tar.gz"
tar -zxvf s-ui-1.4.2_full.tar.gz
bash install.sh
systemctl start s-ui
systemctl enable s-ui
echo "安装完成！访问地址：http://$(hostname -I | awk '{print $1}'):2095/app/"
