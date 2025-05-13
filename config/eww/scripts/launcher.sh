#!/bin/bash

# Rofi Başlatıcı script
# Farklı menüler için çeşitli rofi komutları

# Fonksiyonlar
run_launcher() {
    rofi -show drun -theme ~/.config/rofi/spotlight.rasi
}

run_wifi_menu() {
    networkmanager_dmenu -theme ~/.config/rofi/spotlight.rasi
}

run_audio_settings() {
    pavucontrol
}

# Ana fonksiyon - argümana göre ilgili komutu çalıştır
main() {
    case "$1" in
        "wifi")
            run_wifi_menu
            ;;
        "audio")
            run_audio_settings
            ;;
        *)
            run_launcher
            ;;
    esac
}

# Scripti çalıştır
main "$@" 