#!/bin/bash
cd `dirname $0`


sudo rpi-update


## install wlan + ap


sudo cp 70-persistent-net.rules /etc/udev/rules.d/

sudo apt-get install dnsmasq hostapd

sudo echo "
# https://albeec13.github.io/2017/09/26/raspberry-pi-zero-w-simultaneous-ap-and-managed-mode-wifi/
interface=lo,ap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=198.101.242.72
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h" >> /etc/dnsmasq.conf

sudo cp hostapd.conf /etc/hostapd/

sudo echo '
DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

sudo cp wpa_supplicant.conf /etc/wpa_supplicant/

sudo cp interfaces /etc/network/

sudo update-rc.d dhcpcd disable

cp start-ap-managed-wifi.sh ~/
chmod u+x ~/start-ap-managed-wifi.sh

echo "add '@reboot /home/pi/start-ap-managed-wifi.sh' to cron and reboot"
echo "or to /etc/rc.local"
