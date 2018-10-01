#!/bin/bash
cd `dirname $0`

echo "Installation script for RPi"

echo "What is your WiFi ssid?"
read home_ssid
echo "Type the password for your home WiFi"
read home_password
echo "Your Wifi has ssid $home_ssid and password $home_password"

echo "What ssid would you like for the access point?"
read ap_ssid
echo "Type the password for the AP"
read ap_password
echo "Your AP will have ssid $ap_ssid and password $ap_password"

wlan0_mac=`cat /sys/class/net/wlan0/address`
echo "Your MAC address for WiFi is $wlan0_mac"

cp config/start-ap-managed-wifi.sh ~/
chmod u+x ~/start-ap-managed-wifi.sh

crontab -l | cat - config/crontab-fragment.txt > crontab.txt
crontab crontab.txt
rm crontab.txt

sudo -i

rpi-update


## install wlan + ap

cp config/70-persistent-net.rules /etc/udev/rules.d/
sed -i -e "s/wlan0_mac/$wlan0_mac/g" /etc/udev/rules.d/70-persistent-net.rules

apt-get install dnsmasq hostapd

echo "
# https://albeec13.github.io/2017/09/26/raspberry-pi-zero-w-simultaneous-ap-and-managed-mode-wifi/
interface=lo,ap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=198.101.242.72
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h" >> /etc/dnsmasq.conf

cp config/hostapd.conf /etc/hostapd/
sed -i -e "s/ap_ssid/$ap_ssid/g" /etc/hostapd/hostapd.conf
sed -i -e "s/ap_password/$ap_password/g" /etc/hostapd/hostapd.conf

echo '
DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

cp config/wpa_supplicant.conf /etc/wpa_supplicant/
sed -i -e "s/ap_ssid/$ap_ssid/g" /etc/wpa_supplicant/wpa_supplicant.conf
sed -i -e "s/ap_password/$ap_password/g" /etc/wpa_supplicant/wpa_supplicant.conf
sed -i -e "s/home_ssid/$home_ssid/g" /etc/wpa_supplicant/wpa_supplicant.conf
sed -i -e "s/home_password/$home_password/g" /etc/wpa_supplicant/wpa_supplicant.conf

cp config/interfaces /etc/network/

update-rc.d dhcpcd disable
