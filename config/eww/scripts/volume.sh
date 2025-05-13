#!/bin/bash

# Ses seviyesini al
get_volume() {
    # pamixer ile ses seviyesini al (alternatif olarak amixer veya pactl da kullanılabilir)
    vol=$(pamixer --get-volume)
    
    # Ses kapalı mı kontrol et
    if [[ $(pamixer --get-mute) == "true" ]]; then
        echo "0"
    else
        echo "$vol"
    fi
}

# Ses seviyesini yazdır
get_volume 