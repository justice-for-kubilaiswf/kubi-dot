#!/bin/bash

entries=" Shutdown\n Restart\n󰍃 Logout\n Lock\n Sleep"

selected=$(echo -e $entries | rofi -dmenu -i -p "Power Menu" -l 5)

case $selected in
    " Shutdown")
        systemctl poweroff
        ;;
    " Restart")
        systemctl reboot
        ;;
    "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    " Lock")
        swaylock
        ;;
    " Sleep")
        systemctl suspend
        ;;
esac