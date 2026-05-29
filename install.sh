#!/bin/bash
set -e

# 1. 创建临时目录并进入
mkdir -p /tmp/s-ui && cd /tmp/s-ui

# 2. 下载你的纯净安装包（把下面的链接换成你自己的）
echo "正在下载安装包..."
wget -O s-ui.tar.gz "https://github.com/leespeng/s-ui-install1.4.2/releases/download/v1.0/s-ui-1.4.2_full.tar.gz"

# 3. 直接解压到系统根目录，确保文件路径正确
echo "正在解压文件..."
tar -zxvf s-ui.tar.gz -C /

# 4. 给脚本添加执行权限并安装
chmod +x /usr/local/s-ui/s-ui.sh
/usr/local/s-ui/s-ui.sh install

# 5. 安装系统服务文件并启动
cp /usr/local/s-ui/s-ui.service /etc/systemd/system/
systemctl daemon-reload
systemctl start s-ui
systemctl enable s-ui

# 6. 输出访问地址
IP=$(hostname -I | awk '{print $1}')
echo "✅ 安装完成！访问地址：http://$IP:2095/app/"
