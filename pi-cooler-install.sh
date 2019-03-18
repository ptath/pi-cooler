#!/bin/bash

# Version 0.1
# By ptath (https://ptath.ru)
# Raspberry Pi cooler installation script

# Checking ~/scripts folder
[ ! -d ~/scripts ] && mkdir ~/scripts
[ -e ~/scripts/cooler.sh ] && echo " Script already installed (~/scripts/cooler.sh)? Exiting..." && exit

# Downloading script and cooler.service file
wget -q -N -O ~/scripts/cooler.sh https://github.com/ptath/pi-cooler/raw/master/scripts/cooler.sh
chmod +x ~/scripts/cooler.sh

# Installing cooler.sh as systemd service
read -n 1 -p " Install script as systemd service and reboot? (Y/n): " choice
[ -z "$choice" ] && choice="y"
case $version_choice in
  y|Y )
    echo " Yes"
      [ -e /lib/systemd/system/cooler.service ] && echo " Cooler service exists (/lib/systemd/system/cooler.service)? Exiting..." && exit
      wget -q -N -O /tmp/cooler.service https://github.com/ptath/pi-cooler/raw/master/cooler.service
      sudo mv /tmp/cooler.service /lib/systemd/system/cooler.service
      sudo chmod 644 /lib/systemd/system/cooler.service
      sudo systemctl daemon-reload
      sudo systemctl enable cooler.service
      sudo reboot now
      ;;
  n|N|* )
    echo " No" && exit
    ;;
esac
