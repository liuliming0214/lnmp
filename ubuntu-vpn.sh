#!/bin/bash
echo "欢迎使用Ubuntu vpn搭建脚本:"
echo "1. 安装VPN"
read num

case "$num" in
[1] ) 
echo '脚本开始执行VPN安装...'
apt-get install -y update
#清空路由转发
iptables --flush POSTROUTING --table nat
iptables --flush FORWARD
#安装pptpd
apt-get install -y pptpd

rm /dev/ppp
mknod /dev/ppp c 108 0 
echo 1 > /proc/sys/net/ipv4/ip_forward 
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
echo "localip 172.16.36.1" >> /etc/pptpd.conf
echo "remoteip 172.16.36.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd

echo "vpn pptpd 147258369 *" >> /etc/ppp/chap-secrets

iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source `ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
iptables -A FORWARD -p tcp --syn -s 172.16.36.0/24 -j TCPMSS --set-mss 1356

service pptpd stop
service pptpd start

echo "VPN已经安装完毕，默认帐号为vpn, 密码为147258369"
;;
*) echo "没有任何操作，脚本退出";;
esac
