#!/bin/bash
set -e

# -------------------------- 配置区 --------------------------
BIN_URL="https://github.com/leespeng/s-ui-install1.4.2/releases/download/v1.0/s-ui-1.4.2_full.tar.gz"
INSTALL_DIR="/usr/local/s-ui"
DB_DIR="${INSTALL_DIR}/db"
SERVICE_FILE="/etc/systemd/system/s-ui.service"
# -------------------------------------------------------------

# 颜色
BLUE='\033[0;34m'
GREEN='\033[0;32m'
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

# 2. 下载
echo "📦 下载 s-ui ..."
wget -O /tmp/s-ui/s-ui.tar.gz "$BIN_URL"

# 3. 解压到系统根目录
echo "📂 解压 ..."
tar -zxvf /tmp/s-ui/s-ui.tar.gz -C /

# 4. 全局 s-ui 命令（关键）
ln -sf "${INSTALL_DIR}/s-ui.sh" /usr/bin/s-ui
chmod +x "${INSTALL_DIR}/s-ui.sh" "${INSTALL_DIR}/sui"

# 5. 清空旧库
echo "🧹 清空旧数据库，全新面板 ..."
rm -f "${DB_DIR}/s-ui.db"

# 6. 注册服务
cp "${INSTALL_DIR}/s-ui.service" "$SERVICE_FILE"
systemctl daemon-reload
systemctl enable s-ui

# 7. 启动服务
echo "🆕 启动服务，初始化数据库 ..."
systemctl start s-ui
sleep 3

# 8. 生成随机8位账号密码
gen_rand8() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1
}
USER=$(gen_rand8)
PASS=$(gen_rand8)

# 9. 设置管理员账号（先写死）
"${INSTALL_DIR}/sui" admin -username "$USER" -password "$PASS"

# 10. 获取 IP
echo "🌐 正在获取 IP 地址..."
PUBLIC_IPV4=$(curl -s --max-time 5 -4 ifconfig.me || echo "N/A")
LOCAL_IP=$(hostname -I | awk '{print $1}')
PUBLIC_IPV6=$(curl -s --max-time 5 -6 ifconfig.me || echo "N/A")

# 11. 输出访问地址（和官方一致）
echo "=================================================="
echo -e "${BLUE}Local address: http://${LOCAL_IP}:2095/app/${NC}"
[ "$PUBLIC_IPV6" != "N/A" ] && echo -e "${BLUE}Global address: http://[${PUBLIC_IPV6}]:2095/app/${NC}"
echo -e "${BLUE}Global address: http://${PUBLIC_IPV4}:2095/app/${NC}"
echo "=================================================="
echo -e "${GREEN}用户名: ${USER}${NC}"
echo -e "${GREEN}密码: ${PASS}${NC}"
echo "=================================================="

# 12. 关键：增加官方同款 y/n 配置提示
echo
read -p "Do you want to continue with the modification [y/n]? " ans
if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
  echo "🔧 进入交互式配置（端口/路径/账号）..."
  # 调用官方自带的配置函数
  "${INSTALL_DIR}/s-ui.sh" config_after_install
else
  echo "ℹ️ 已取消，使用当前配置继续。"
fi

# 13. 打印 s-ui 快捷命令说明（和你截图一致）
echo
echo "--------------------------------------------------"
echo "S-UI 控制菜单用法"
echo "--------------------------------------------------"
echo "子命令:"
echo "  s-ui          - 管理员管理脚本"
echo "  s-ui start    - 启动 s-ui"
echo "  s-ui stop     - 停止 s-ui"
echo "  s-ui restart  - 重启 s-ui"
echo "  s-ui status   - 查看 s-ui 当前状态"
echo "  s-ui enable   - 启用开机自启"
echo "  s-ui disable  - 禁用开机自启"
echo "  s-ui log      - 查看 s-ui 日志"
echo "  s-ui update   - 更新"
echo "  s-ui install  - 安装"
echo "  s-ui uninstall- 卸载"
echo "  s-ui help     - 控制菜单用法"
echo "--------------------------------------------------"
