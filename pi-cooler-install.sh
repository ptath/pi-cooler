#!/bin/bash

# Version 0.2
# By ptath (https://ptath.ru)
# Raspberry Pi cooler installation script

# Checking ~/scripts folder
[ ! -d ~/scripts ] && mkdir ~/scripts
[ -e ~/scripts/cooler.sh ] &&
  echo " Script already installed (~/scripts/cooler.sh)?" &&
  echo " Remove it manually (rm ~/scripts/cooler.sh) and run again to reinstall" &&
  exit

# Downloading script and cooler.service file
echo " Downloading script to ~/scripts/cooler.sh ..."
wget -q -N -O ~/scripts/cooler.sh https://github.com/ptath/pi-cooler/raw/master/scripts/cooler.sh
echo " Making it executable..."
chmod +x ~/scripts/cooler.sh
echo " Done!"

# Installing cooler.sh as systemd service
read -n 1 -p " Install script as systemd service and reboot? (Y/n): " choice
case $choice in
  y|Y )
    echo " Yes"
    [ -e /lib/systemd/system/cooler.service ] && echo " Cooler service exists (/lib/systemd/system/cooler.service)? Exiting..." && exit
    wget -q -N -O /tmp/cooler.service https://github.com/ptath/pi-cooler/raw/master/cooler.service
    sudo mv /tmp/cooler.service /lib/systemd/system/cooler.service
    sudo chmod 644 /lib/systemd/system/cooler.service
    sudo systemctl daemon-reload
    sudo systemctl enable cooler.service
    echo " Will reboot in 5 sec, press CTRL+C to abort..."
    sleep 5
    sudo reboot now
    ;;
  n|N|* )
    echo " No"
    echo " You can run script manually (sudo ~/scripts/cooler.sh)"
    exit
    ;;
esac
