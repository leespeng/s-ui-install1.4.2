#!/bin/bash
set -e

# 1. 创建工作目录并进入
mkdir -p /opt/s-ui && cd /opt/s-ui

# 2. 下载安装包
echo "正在下载安装包..."
wget -O s-ui.tar.gz "https://github.com/leespeng/s-ui-install1.4.2/releases/download/v1.0/s-ui-1.4.2_full.tar.gz"

# 3. 解压文件（会生成 s-ui-1.4.2_full 目录）
echo "正在解压文件..."
tar -zxvf s-ui.tar.gz

# 4. 关键！进入解压后的目录，再执行安装脚本
cd s-ui-1.4.2_full
chmod +x install.sh
./install.sh

# 5. 启动服务并设置开机自启
systemctl start s-ui
systemctl enable s-ui

# 6. 输出访问地址
IP=$(hostname -I | awk '{print $1}')
echo "✅ 安装完成！访问地址：http://$IP:2095/app/"
