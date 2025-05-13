#!/bin/bash

# WiFi bağlantı durumunu al
get_wifi_info() {
    # İstenilen çıktı türünü belirle (icon veya name)
    TYPE="$1"
    
    # NMCli ile ağ bilgilerini al
    network_info=$(nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | head -n1)
    wifi_signal=$(echo "$network_info" | cut -d':' -f3)
    wifi_name=$(echo "$network_info" | cut -d':' -f2)
    
    # WiFi bağlı değilse
    if [ -z "$network_info" ]; then
        if [ "$TYPE" = "--icon" ]; then
            echo "󰤮"  # Kapalı WiFi ikonu
        else
            echo "Bağlı Değil"
        fi
        exit 0
    fi
    
    # Sinyal gücüne göre simgeyi belirle
    if [ "$TYPE" = "--icon" ]; then
        if [ "$wifi_signal" -ge 75 ]; then
            echo "󰤨" # Güçlü sinyal
        elif [ "$wifi_signal" -ge 50 ]; then
            echo "󰤥" # Orta sinyal
        elif [ "$wifi_signal" -ge 25 ]; then
            echo "󰤢" # Zayıf sinyal
        else
            echo "󰤟" # Çok zayıf sinyal
        fi
    else
        # Ağ adını yazdır
        echo "$wifi_name"
    fi
}

# Çağrıya göre çıktıyı belirle
if [ "$1" = "--icon" ]; then
    get_wifi_info "--icon"
elif [ "$1" = "--name" ]; then
    get_wifi_info "--name"
else
    # Yardım mesajı
    echo "Kullanım: $0 --icon veya $0 --name"
    exit 1
fi 