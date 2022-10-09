#!/bin/zsh
###############################################################################
# This script automatically connects to your wiregurad server
# in case you are outside of your home network
# Maintainer: github.com/luckynrslevin
# Date: 2022/09/10
# Version: 1.0
# Prerequisites:
# 0) MacOS and zsh
# 1) You need to have a up and running wireguard server in your home network
#    See e.g. following tutorial:
#    https://github.com/luckynrslevin/doc/blob/master/rsapbian-wireguard-pihole-on-lxc.md
# 2) wiregurd command line tools need to be available on your
#    mac computer (client)
# 3) You need to properly configure your personal subnet address for your
#    home network and wireguard
# 4) you need to be able to call wireguard commands via sudo without password
#    Use `sudo visudo`command and add the following line in the end:
#    replace_with_your_mac_username ALL=(ALL) NOPASSWD:/usr/local/bin/wg-quick
# 5) replace shebang in /usr/local/bin/wg-quick script with this one:
#    #!/usr/local/bin/bash
###############################################################################


################################################################################
# Configuration
## Configure your home subnet
MY_HOME_SUBNET="192.168."
## Your wireguard client configuration file
WG_CONF="/foo/bar/wg0.conf"
################################################################################

################################################################################
# Functions
# Start wireguard in case it is not already running and exit the script
WireguardUp () {
  if [[ $WG_CONNECTED -eq 0 ]]; then
    #echo "Start wireguard"
    /usr/bin/sudo /usr/local/bin/wg-quick up $WG_CONF > /dev/null 2>&1 && \
      /usr/bin/osascript -e 'display notification "Successfully connected" with title "Wireguard connected" sound name "Ping"' > /dev/null 2>&1 
  fi
}

# Stop wireguard in case it is running and exit the script
WireguardDown () {
  if [[ $WG_CONNECTED -gt 0 ]]; then
    #echo "Stop wireguard"
    /usr/bin/sudo /usr/local/bin/wg-quick down $WG_CONF > /dev/null 2>&1 && \
      /usr/bin/osascript -e 'display notification "Successfully disconnected" with title "Wireguard disconnected" sound name "Ping"' > /dev/null 2>&1
  fi
}

################################################################################
# Script
WG_CONNECTED=$(/usr/bin/sudo /usr/local/bin/wg show | /usr/bin/wc -l)
#echo "WG connected: $WG_CONNECTED"

# Check LAN connection
LAN_CONNECTED=$(/usr/sbin/ipconfig getifaddr en0 | /usr/bin/wc -l)
#echo "LAN connected: $LAN_CONNECTED"
LAN_HOME=$(/usr/sbin/ipconfig getifaddr en0 | grep $MY_HOME_SUBNET | /usr/bin/wc -l)
#echo "LAN home: $LAN_HOME"

# CHeck WLAN connection
WLAN_CONNECTED=$(/usr/sbin/ipconfig getifaddr en1 | /usr/bin/wc -l)
#echo "WLAN connected: $WLAN_CONNECTED"
WLAN_HOME=$(/usr/sbin/ipconfig getifaddr en1 | grep $MY_HOME_SUBNET | /usr/bin/wc -l)
#echo "WLAN home: $WLAN_HOME"

if [[ $LAN_CONNECTED -eq 0 && $WLAN_CONNECTED -eq 0 ]]; then
  # Diable in case of no connection
  WireguardDown
elif [[ ( $LAN_CONNECTED -ne 0 || $WLAN_CONNECTED -ne 0 )
          && ( $WLAN_HOME -eq 1 || $LAN_HOME -eq 1 ) ]]; then
  # Diable in case of home network
    WireguardDown
else
  # in all other cases start wireguard
  WireguardUp
fi
