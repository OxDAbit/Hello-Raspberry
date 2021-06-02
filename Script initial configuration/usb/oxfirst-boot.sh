#!/bin/bash
readonly VERSION=0.1

#-------------------------------------------------------#
#                 oxfirst-boot.sh                       #
#                                                       #
# Purpose:      Configure raspbian lite after burn image#
# Version:      v0.1                                    #
# Created:      04/11/2020                              #
#                                                       #
# Author:       David Alvarez Medina aka OxDA_bit       #
# Mail:         0xdabit@gmail.com                       #
# Twitter:      @0xDA_bit                               #
# Github:       OxDAbit	                        	#
#-------------------------------------------------------#

declare wifi_ssid="your_ssid"
declare wifi_pswd="your_password"

# Config Spanish keyboard ##############################################
sed '/XKBLAYOUT/c XKBLAYOUT="es"' /etc/default/keyboard -i
########################################################################

# Config language ######################################################
sed '/LANG/c LANG=es_ES.UTF-8' /etc/default/locale -i
########################################################################

# Enable SSH connection ################################################
update-rc.d ssh enable
########################################################################

# WiFi connection ######################################################
## Enable wlan0
rfkill unblock wifi

## Config WiFi Country
wpa_cli -i "wlan0" set country "ES"
wpa_cli -i "wlan0" save_config > /dev/null 2>&1

## Config WiFi SSID and Password
if grep -q "ssid" /etc/wpa_supplicant/wpa_supplicant.conf; then
	wpa_cli -i "wlan0" set_network "$wifi_ssid" psk "\"$wifi_pswd\"" 2>&1
	wpa_cli -i "wlan0" save_config > /dev/null 2>&1
else
echo "" >> /etc/wpa_supplicant/wpa_supplicant.conf
cat <<EOF >> /etc/wpa_supplicant/wpa_supplicant.conf
network={
	ssid="$wifi_ssid"
	psk="$wifi_pswd"
}
EOF
fi

## Set new WiFi configuration
wpa_cli -i wlan0 reconfigure
########################################################################

# Reboot question ######################################################
if (whiptail --title "oxconfiguration" --yesno "Configuration is over. Do you want reboot system right now?" 8 78 --defaultno); then
	reboot
fi
########################################################################
