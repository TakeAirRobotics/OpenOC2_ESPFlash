#!/bin/bash

DIRECTORY=/sys/class/gpio/gpio33
if [[ -d "$DIRECTORY" ]]
then
    echo "GPIO-33 is already set as a GPIO"
else
    echo "GPIO-33 set as a GPIO."
    echo "33" > /sys/class/gpio/export
fi

sleep 1 #so it does not refuse the next command

echo "out" > /sys/class/gpio/gpio33/direction

read -p "Set the jumper J9, then press enter"

echo "Setting EN LO"
echo "0" > /sys/class/gpio/gpio33/value
sleep 1

echo "Setting EN HI"
echo "1" > /sys/class/gpio/gpio33/value
sleep 1

read -p "Remove jumper J9, then press enter"

echo "Device should now be in update mode, uploading binary"
esptool.py -p /dev/ttyTHS1 write_flash 0 $1
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo "Flashing failed!"
	exit
fi

echo "Finished, resetting device to run from FLASH content"
echo "0" > /sys/class/gpio/gpio33/value
sleep 1
echo "1" > /sys/class/gpio/gpio33/value
echo "Reset finished, device should be running code..."
