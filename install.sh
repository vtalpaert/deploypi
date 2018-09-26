#!/bin/bash
cd `dirname $0`

echo "Installation script for RPi"

echo "What is your WiFi ssid?"
read home_ssid
echo "Type the password for your home WiFi"
read home_password
echo "Your Wifi has ssid $home_ssid and password $home_password"

echo "Type the password for the AP"
read ap_password
echo "Your password is $ap_password"

wlan0_mac=`ifconfig wlan0 | awk '/^[a-z]/ { iface=$1; mac=$NF; next } /inet addr:/ { print mac }'`
echo "Your MAC address for WiFi is $wlan0_mac"

sudo rpi-update


## install wlan + ap


sudo cp config/70-persistent-net.rules /etc/udev/rules.d/
sudo sed -i -e "s/wlan0_mac/$wlan0_mac/g" /etc/udev/rules.d/70-persistent-net.rules

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

sudo cp config/hostapd.conf /etc/hostapd/
sudo sed -i -e "s/ap_password/$ap_password/g" /etc/hostapd/hostapd.conf

sudo echo '
DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

sudo cp config/wpa_supplicant.conf /etc/wpa_supplicant/
sudo sed -i -e "s/ap_password/$ap_password/g" /etc/wpa_supplicant/wpa_supplicant.conf
sudo sed -i -e "s/home_ssid/$home_ssid/g" /etc/wpa_supplicant/wpa_supplicant.conf
sudo sed -i -e "s/home_password/$home_password/g" /etc/wpa_supplicant/wpa_supplicant.conf

sudo cp config/interfaces /etc/network/

sudo update-rc.d dhcpcd disable

cp config/start-ap-managed-wifi.sh ~/
chmod u+x ~/start-ap-managed-wifi.sh

echo "add '@reboot /home/pi/start-ap-managed-wifi.sh' to cron and reboot"
echo "or to /etc/rc.local"
