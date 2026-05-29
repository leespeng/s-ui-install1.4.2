#!/bin/bash
set -e

# -------------------------- 配置区 --------------------------
BIN_URL="https://github.com/leespeng/s-ui-install1.4.2/releases/download/v1.0/s-ui-1.4.2_full.tar.gz"
INSTALL_DIR="/usr/local/s-ui"
DB_DIR="${INSTALL_DIR}/db"
SERVICE_FILE="/etc/systemd/system/s-ui.service"
# -------------------------------------------------------------

# 颜色定义：蓝色
BLUE='\033[0;34m'
NC='\033[0m'

# 必须 root
if [[ $EUID -ne 0 ]]; then
  echo "❌ 必须用 root 权限执行"
  exit 1
fi

# 1. 清理旧安装
systemctl stop s-ui 2>/dev/null || true
systemctl disable s-ui 2>/dev/null || true
rm -f "$SERVICE_FILE"
rm -rf "$INSTALL_DIR"
rm -rf /tmp/s-ui
mkdir -p /tmp/s-ui "$INSTALL_DIR" "$DB_DIR"

# 2. 下载安装包
echo "📦 下载 s-ui ..."
wget -O /tmp/s-ui/s-ui.tar.gz "$BIN_URL"

# 3. 解压到系统根目录
echo "📂 解压 ..."
tar -zxvf /tmp/s-ui/s-ui.tar.gz -C /

# 4. 清空旧数据库（全新纯净）
echo "🧹 清空旧数据库，确保全新面板 ..."
rm -f "${DB_DIR}/s-ui.db"

# 5. 添加执行权限
chmod +x "${INSTALL_DIR}/s-ui.sh"
chmod +x "${INSTALL_DIR}/sui"

# 6. 注册系统服务
cp "${INSTALL_DIR}/s-ui.service" "$SERVICE_FILE"
systemctl daemon-reload
systemctl enable s-ui

# 7. 启动服务并等待初始化
echo "🆕 启动服务，初始化数据库 ..."
systemctl start s-ui
sleep 3

# 8. 生成随机 8位 用户名 + 密码（字母数字混合）
gen_rand8() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1
}
USER=$(gen_rand8)
PASS=$(gen_rand8)

# 9. 写入 s-ui 管理员账号
"${INSTALL_DIR}/sui" admin -username "$USER" -password "$PASS"

# 10. 获取本机 IP（优先公网/网卡主IP）
IP=$(hostname -I | awk '{print $1}')

# 11. 蓝色 + 分行输出（你要的格式）
echo "=================================================="
echo -e "${BLUE}Global Address: http://${IP}:2095/app/${NC}"
echo -e "${BLUE}用户名: ${USER}${NC}"
echo -e "${BLUE}密码: ${PASS}${NC}"
echo "=================================================="
