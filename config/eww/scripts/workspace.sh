#!/bin/bash

# Hyprland workspaceleri için EWW script
# Aktif, dolu ve boş workspace'leri görüntüler

workspaces() {
    # Hyprland'da mevcut workspace'leri al
    active=$(hyprctl activeworkspace | grep "workspace ID" | awk '{print $3}')
    
    # Tüm pencereleri al ve hangi workspace'lerde olduklarını bul
    occupied=$(hyprctl workspaces | grep "workspace ID" | awk '{print $3}' | sort -n)
    
    # Çıktı için HTML/XML benzeri yapı oluştur
    echo "(box :class \"workspace-widget\" :orientation \"h\" :space-evenly false :halign \"center\""
    
    # Standart 10 workspace için döngü oluştur (isteğe bağlı olarak değiştirilebilir)
    for i in {1..10}; do
        # O workspace'in aktif olup olmadığını kontrol et
        if [ "$i" == "$active" ]; then
            echo "(button :class \"workspace-button current\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
        # O workspace'te pencere olup olmadığını kontrol et
        elif [[ $occupied == *"$i"* ]]; then
            echo "(button :class \"workspace-button occupied\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
        # Boş workspace
        else
            echo "(button :class \"workspace-button\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
        fi
    done
    
    echo ")"
}

# Çıktıyı göster
workspaces 