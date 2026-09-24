#!/bin/bash
# LibWrt 25.12  DSA AP预置脚本  适配Dave's Guitar（小米CR8808）
set -e

mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-set-ap << 'EOF'
#!/bin/sh
# 删除wan/wan6逻辑接口
uci -q delete network.wan
uci -q delete network.wan6

# DSA网桥：删除原有ports，逐个添加4个网口
uci delete network.@device[0].ports
uci add_list network.@device[0].ports=lan1
uci add_list network.@device[0].ports=lan2
uci add_list network.@device[0].ports=lan3
uci add_list network.@device[0].ports=wan

# LAN静态IP
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.31.52'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.31.1'
uci set network.lan.dns='192.168.31.1'

# 关闭LAN的DHCP服务器
uci set dhcp.lan.ignore='1'

# 关闭防火墙
uci set firewall.@defaults[0].enabled='0'

uci commit network
uci commit dhcp
uci commit firewall

# 重启网络
/etc/init.d/network restart

# 确保SSH服务正常启动，防止网络重启后dropbear停止
/etc/init.d/dropbear enable
/etc/init.d/dropbear start
exit 0
EOF
chmod +x files/etc/uci-defaults/99-set-ap

echo "[diy] DSA AP脚本：4口加入br-lan，IP=192.168.31.52"
