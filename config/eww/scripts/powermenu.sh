#!/bin/bash

# Hyprland için güç menüsü
# Kapatma, yeniden başlatma, oturumu kapatma ve uyku modları için

# Tema dosyasının konumu
THEME="$HOME/.config/rofi/spotlight.rasi"

# Fonksiyonlar
power_off() {
    systemctl poweroff
}

reboot() {
    systemctl reboot
}

logout() {
    hyprctl dispatch exit
}

suspend() {
    systemctl suspend
}

# Menüyü göster ve seçimi işle
show_menu() {
    options=("Kapat" "Yeniden Başlat" "Çıkış" "Uyku")
    
    selected=$(printf "%s\n" "${options[@]}" | rofi -dmenu -i -theme "$THEME" -p "Güç Menüsü" -no-custom)
    
    case "$selected" in
        "Kapat")
            power_off
            ;;
        "Yeniden Başlat")
            reboot
            ;;
        "Çıkış")
            logout
            ;;
        "Uyku")
            suspend
            ;;
    esac
}

# Menüyü çalıştır
show_menu 