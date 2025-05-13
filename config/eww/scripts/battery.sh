#!/bin/bash

# Pil yüzdesini çıkarın
get_battery() {
    # Pil dosyasının varlığını kontrol et
    if [ -d /sys/class/power_supply/BAT0 ]; then
        # Sistem pil yüzdesini oku
        cat /sys/class/power_supply/BAT0/capacity
    else
        # Pil bulunamazsa veya sanal bir makinede ise
        echo "100"
    fi
}

# Pil durumunu al
get_battery 