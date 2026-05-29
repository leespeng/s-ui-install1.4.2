#!/bin/bash
set -e

# -------------------------- 配置区 --------------------------
BIN_URL="https://github.com/leespeng/s-ui-install1.4.2/releases/download/v1.0/s-ui-1.4.2_full.tar.gz"
INSTALL_DIR="/usr/local/s-ui"
DB_DIR="${INSTALL_DIR}/db"
SERVICE_FILE="/etc/systemd/system/s-ui.service"
# -------------------------------------------------------------

# 必须 root
if [[ $EUID -ne 0 ]]; then
  echo "❌ 必须用 root 权限执行"
  exit 1
fi

# 1. 清理旧安装（保证纯净）
systemctl stop s-ui 2>/dev/null || true
systemctl disable s-ui 2>/dev/null || true
rm -f "$SERVICE_FILE"
rm -rf "$INSTALL_DIR"
rm -rf /tmp/s-ui
mkdir -p /tmp/s-ui "$INSTALL_DIR" "$DB_DIR"

# 2. 下载
echo "📦 下载 s-ui ..."
wget -O /tmp/s-ui/s-ui.tar.gz "$BIN_URL"

# 3. 解压到系统（覆盖）
echo "📂 解压 ..."
tar -zxvf /tmp/s-ui/s-ui.tar.gz -C /

# 4. 关键：清空旧数据库 → 纯净
echo "🧹 清空旧数据库，确保全新面板 ..."
rm -f "${DB_DIR}/s-ui.db"

# 5. 权限
chmod +x "${INSTALL_DIR}/s-ui.sh"
chmod +x "${INSTALL_DIR}/sui"

# 6. 安装系统服务
cp "${INSTALL_DIR}/s-ui.service" "$SERVICE_FILE"
systemctl daemon-reload
systemctl enable s-ui

# 7. 初始化空数据库（官方步骤）
echo "🆕 初始化空数据库 ..."
"${INSTALL_DIR}/sui" migrate

# 8. 生成随机账号密码（8位）
USER="admin"
PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
"${INSTALL_DIR}/sui admin -username $USER -password $PASS"

# 9. 启动服务
systemctl start s-ui

# 10. 获取 IP 并打印（你要的 Global Address + 账号密码）
IP=$(hostname -I | awk '{print $1}')
echo "=================================================="
echo "✅ S-UI 纯净版安装成功！"
echo "🌐 Global Address: http://${IP}:2095/app/"
echo "👤 用户名: ${USER}"
echo "🔑 密码: ${PASS}"
echo "=================================================="
