#!/bin/bash

# Version 0.3
# By ptath (https://ptath.ru)
# Raspberry Pi cooler script
# Edit values below to fit your needs

GPIO_N="18" # Set GPIO used to control fan (default 18)
TARGET_TEMP="55" # Set target CPU temperature (default 55)
POLL_INT="5" # Polling time in seconds (default 5)

# Setting up GPIO pin
if [ ! -e /sys/class/gpio/gpio"$GPIO_N" ]; then
  sudo echo "$GPIO_N" > /sys/class/gpio/export
  sudo echo "out" > /sys/class/gpio/gpio"$GPIO_N"/direction
  # Uncomment line below to debug
  # echo "Pin $GPIO_N is set"
else
  sudo echo "out" > /sys/class/gpio/gpio"$GPIO_N"/direction
  # Uncomment line below to debug
  # echo "Pin $GPIO_N already set"
fi

setCoolerOn()
{
  sudo echo "1" > /sys/class/gpio/gpio"$GPIO_N"/value
}

setCoolerOff()
{
  sudo echo "0" > /sys/class/gpio/gpio"$GPIO_N"/value
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
      # echo "CPU temperature is too high: $CPU_TEMP, keep cooling..."
    else
      # Uncomment line below to debug
      echo "CPU temperature is too high: $CPU_TEMP, start cooling..."
      setCoolerOn
      isCooling="yes"
    fi
  else
    if [ "$isCooling" == "yes" ]; then
      echo "CPU temperature is fine: $CPU_TEMP, cooler stopped."
      setCoolerOff
      isCooling="no"
    else
      # Uncomment line below to debug
      # echo "CPU temperature is fine: $CPU_TEMP, no need to cool."
    fi
  fi
  # Next update after POLL_INT seconds
  sleep "$POLL_INT"
done
