#!/bin/bash

# Ekran boyutlarını al
SCREEN_WIDTH=$(hyprctl monitors -j | jq '.[0].width')
SCREEN_HEIGHT=$(hyprctl monitors -j | jq '.[0].height')

# Rofi'yi çalıştır
rofi -show drun -theme spotlight \
     -width 40 \
     -location 0 \
     -yoffset 0 \
     -xoffset 0 \
     -display-drun "" \
     -drun-display-format "{name}" \
     -show-icons