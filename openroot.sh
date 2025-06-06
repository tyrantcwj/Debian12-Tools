#!/bin/sh
# openroot.sh
# 作者：Tyrantcwj
# 版本：v3（更新于本次对话）
# 作用：一键开启 Debian 12 上的 SSH root 登录，并自动设置密码
# 0.确保脚本内能找到 chpasswd 命令，追加 PATH 环境变量
export PATH=$PATH:/usr/sbin

# 1. 检查是否为 root
if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 root 用户或 sudo 来运行此脚本！"
  exit 1
fi

# 2. 备份 sshd_config
CFG="/etc/ssh/sshd_config"
BACKUP="${CFG}.bak_$(date +%F_%T)"
cp "$CFG" "$BACKUP"
echo "已备份原配置到：$BACKUP"

# 3. 修改 SSH 配置
sed -i 's/^[# \t]*PermitRootLogin.*/PermitRootLogin yes/' "$CFG"
sed -i 's/^[# \t]*PasswordAuthentication.*/PasswordAuthentication yes/' "$CFG"
echo "已设置 PermitRootLogin yes，PasswordAuthentication yes"

# 4. 解锁 root 账户（若已锁定）
passwd -u root >/dev/null 2>&1 || true

# 5. 设置 root 密码为指定值
echo "root:Cwj21cwj" | chpasswd && echo "✔︎ root 密码已设置为 Cwj21cwj" || echo "✖ 设置 root 密码失败"

# 6. 重启 SSH 服务
if systemctl restart sshd 2>/dev/null; then
  echo "✔︎ SSH 服务已重启，root 登录已开启！"
else
  echo "✖ 无法重启 sshd，请手动检查 SSH 服务状态。"
fi
