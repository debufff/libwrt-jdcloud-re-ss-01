#!/bin/bash
# ==============================================
# LibWrt diy.sh 预置AP模式
# 京东云亚瑟 RE-SS-01，首次开机自动执行一次
# ==============================================
set -e

mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-set-ap << 'EOF'
#!/bin/sh
# 1. 删除wan/wan6逻辑接口
uci -q delete network.wan
uci -q delete network.wan6

# 2. 把wan物理端口添加进br-lan桥（关键！4口全部变成LAN）
uci add_list network.lan.ifname="wan"

# 3. LAN静态IP，示例主路由192.168.31.1，AP固定192.168.31.55
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.31.55'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.31.1'
uci set network.lan.dns='192.168.31.1'

# 4. 关闭LAN的DHCP服务器（AP核心）
uci set dhcp.lan.ignore='1'

# 5. 关闭防火墙
uci set firewall.@defaults[0].enabled='0'

# 保存配置
uci commit network
uci commit dhcp
uci commit firewall

# 重启网络生效
/etc/init.d/network restart
/etc/init.d/firewall stop
/etc/init.d/firewall disable

exit 0
EOF
chmod +x files/etc/uci-defaults/99-set-ap

echo "[diy] add full AP config, WAN port added to lan bridge"
