#!/bin/bash

# Ekran parlaklığını al
get_brightness() {
    # brightnessctl ile mevcut parlaklığı al
    max=$(brightnessctl max)
    current=$(brightnessctl get)
    
    # Yüzde hesapla
    percentage=$(( (current * 100) / max ))
    echo "$percentage"
}

# Ekran parlaklığını yazdır
get_brightness 