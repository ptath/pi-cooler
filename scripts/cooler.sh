#!/bin/bash

# Version 0.4
# By ptath (https://ptath.ru)
# Raspberry Pi cooler script
# Edit values below to fit your needs

GPIO_N="18" # Set GPIO used to control fan (default 18)
TARGET_TEMP="55" # Set target CPU temperature (default 55)
POLL_INT="15" # Polling time in seconds (default 5)

# Colors for terminal
if test -t 1; then
    ncolors=$(which tput > /dev/null && tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
    fi
fi

# Setting up GPIO pin
if [ ! -e /sys/class/gpio/gpio"$GPIO_N" ]; then
  echo "$GPIO_N" > /sys/class/gpio/export
  echo "out" > /sys/class/gpio/gpio"$GPIO_N"/direction
  # Uncomment line below to debug
  # echo "Pin $GPIO_N is set"
else
  echo "out" > /sys/class/gpio/gpio"$GPIO_N"/direction
  # Uncomment line below to debug
  # echo "Pin $GPIO_N already set"
fi

setCoolerOn()
{
    # Turn cooler on
    echo "1" > /sys/class/gpio/gpio"$GPIO_N"/value
}

setCoolerOff()
{
    # Turn cooler off
    echo "0" > /sys/class/gpio/gpio"$GPIO_N"/value
}

getTemp()
{
  CPU_TEMP=$(vcgencmd measure_temp | cut -d '=' -f2 | sed 's/....$//')
}

# Turn cooler off on script interrupt
shutdown()
{
  setCoolerOff
  exit 0
}

trap shutdown SIGINT

# Loop till Ctrl-C (forever for daemon)
while [ 1 ]
do
  getTemp
  if [ "$CPU_TEMP" -gt "$TARGET_TEMP" ]; then
    if [ "$isCooling" == "yes" ]; then
     # Uncomment line below to debug
     # echo "CPU temperature is too high: ${red}$CPU_TEMP${normal}, keep cooling..."
     isCooling="yes"
    else
     echo "CPU temperature is too high: ${red}$CPU_TEMP${normal}, start cooling..."
     setCoolerOn
     isCooling="yes"
    fi
  else
    if [ "$isCooling" == "yes" ]; then
      echo "CPU temperature is fine: ${green}$CPU_TEMP${normal}, cooler stopped."
      setCoolerOff
      isCooling="no"
    else
      # Uncomment line below to debug
      # echo "CPU temperature is fine: ${green}$CPU_TEMP${normal}, no need to cool."
      isCooling="no"
    fi
  fi
  sleep "$POLL_INT"
done
