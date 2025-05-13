#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          ${GREEN}Hyprland Setup Script          ${BLUE}║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"

CONFIG_DIR="$HOME/.config"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Paket kurulumu için sorma
echo -e "${YELLOW}[INFO]${NC} Bağımlılıkları kurmak istiyor musunuz? (y/n)"
read -r install_deps

if [[ "$install_deps" == "y" || "$install_deps" == "Y" ]]; then
    # Paket yöneticisini tespit et
    if [ -x "$(command -v pacman)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Arch tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo pacman -S --noconfirm hyprland hyprpaper kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard
        
        # Kullanıcıya Waybar veya EWW seçeneği sun
        echo -e "${YELLOW}[INFO]${NC} Hangi bar kullanmak istersiniz?"
        echo "1. Waybar (Basit ve stabil)"
        echo "2. EWW (ElKowars Wacky Widgets - Modern ve özelleştirilebilir)"
        read -r bar_choice
        
        if [[ "$bar_choice" == "1" ]]; then
            sudo pacman -S --noconfirm waybar
            use_eww=false
        else
            sudo pacman -S --noconfirm eww
            use_eww=true
        fi
    elif [ -x "$(command -v apt)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Debian tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo apt install -y hyprland kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard
        
        # Kullanıcıya Waybar veya EWW seçeneği sun
        echo -e "${YELLOW}[INFO]${NC} Hangi bar kullanmak istersiniz?"
        echo "1. Waybar (Basit ve stabil)"
        echo "2. EWW (ElKowars Wacky Widgets - Modern ve özelleştirilebilir)"
        read -r bar_choice
        
        if [[ "$bar_choice" == "1" ]]; then
            sudo apt install -y waybar
            use_eww=false
        else
            echo -e "${YELLOW}[INFO]${NC} EWW'yi manuel olarak kurmanız gerekebilir. Devam etmek istiyor musunuz? (y/n)"
            read -r eww_manual
            if [[ "$eww_manual" == "y" || "$eww_manual" == "Y" ]]; then
                use_eww=true
            else
                sudo apt install -y waybar
                use_eww=false
            fi
        fi
    elif [ -x "$(command -v dnf)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Fedora tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo dnf install -y hyprland kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard
        
        # Kullanıcıya Waybar veya EWW seçeneği sun
        echo -e "${YELLOW}[INFO]${NC} Hangi bar kullanmak istersiniz?"
        echo "1. Waybar (Basit ve stabil)"
        echo "2. EWW (ElKowars Wacky Widgets - Modern ve özelleştirilebilir)"
        read -r bar_choice
        
        if [[ "$bar_choice" == "1" ]]; then
            sudo dnf install -y waybar
            use_eww=false
        else
            echo -e "${YELLOW}[INFO]${NC} EWW'yi manuel olarak kurmanız gerekebilir. Devam etmek istiyor musunuz? (y/n)"
            read -r eww_manual
            if [[ "$eww_manual" == "y" || "$eww_manual" == "Y" ]]; then
                use_eww=true
            else
                sudo dnf install -y waybar
                use_eww=false
            fi
        fi
    else
        echo -e "${RED}[ERROR]${NC} Paket yöneticisi desteklenmiyor. Lütfen gerekli paketleri manuel olarak kurun."
    fi
else
    # Varsayılan olarak Waybar'ı kullan
    use_eww=false
fi

# Konfigürasyon dizinlerini oluştur
echo -e "${YELLOW}[INFO]${NC} Konfigürasyon dizinleri oluşturuluyor..."
mkdir -p "$CONFIG_DIR/hypr"
mkdir -p "$CONFIG_DIR/hypr/wallpapers"
mkdir -p "$CONFIG_DIR/swaylock"
mkdir -p "$CONFIG_DIR/waybar/scripts"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$CONFIG_DIR/rofi/scripts"

# Tüm script dosyalarına çalıştırma izni ver
echo -e "${YELLOW}[INFO]${NC} Script dosyalarına çalıştırma izni veriliyor..."
find "$SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;
find "$SCRIPT_DIR" -type f -name "*.py" -exec chmod +x {} \;
if [ -d "$REPO_DIR/kubi-cursor" ]; then
    find "$REPO_DIR/kubi-cursor" -type f -name "*.sh" -exec chmod +x {} \;
fi

# Dosyaları kopyala
echo -e "${YELLOW}[INFO]${NC} Konfigürasyon dosyaları kopyalanıyor..."

# Hyprland
if [ -f "$SCRIPT_DIR/hypr/hyprland.conf" ]; then
    cp "$SCRIPT_DIR/hypr/hyprland.conf" "$CONFIG_DIR/hypr/"
    echo -e "${GREEN}[OK]${NC} Hyprland konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} hypr/hyprland.conf bulunamadı."
fi

# Waybar veya EWW kurulumu
if [ "$use_eww" = true ]; then
    # EWW kurulumu
    echo -e "${YELLOW}[INFO]${NC} EWW yapılandırması kuruluyor..."
    mkdir -p "$CONFIG_DIR/eww/scripts"
    
    # EWW yapılandırma dosyalarını kopyala
    if [ -f "$SCRIPT_DIR/eww/eww.yuck" ]; then
        cp "$SCRIPT_DIR/eww/eww.yuck" "$CONFIG_DIR/eww/"
        echo -e "${GREEN}[OK]${NC} EWW yapılandırma dosyası kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} eww/eww.yuck bulunamadı."
    fi

    if [ -f "$SCRIPT_DIR/eww/eww.scss" ]; then
        cp "$SCRIPT_DIR/eww/eww.scss" "$CONFIG_DIR/eww/"
        echo -e "${GREEN}[OK]${NC} EWW stil dosyası kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} eww/eww.scss bulunamadı."
    fi
    
    # EWW scriptlerini kopyala
    if [ -d "$SCRIPT_DIR/eww/scripts" ]; then
        cp -r "$SCRIPT_DIR/eww/scripts"/* "$CONFIG_DIR/eww/scripts/"
        chmod +x "$CONFIG_DIR/eww/scripts"/*.sh 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} EWW scriptleri kopyalandı ve çalıştırılabilir yapıldı."
    else
        echo -e "${RED}[ERROR]${NC} eww/scripts dizini bulunamadı."
    fi
    
    # EWW assets klasörünü oluştur ve dosyaları kopyala
    if [ -d "$SCRIPT_DIR/eww/images" ]; then
        mkdir -p "$CONFIG_DIR/eww/images"
        cp -r "$SCRIPT_DIR/eww/images"/* "$CONFIG_DIR/eww/images/" 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} EWW görüntü dosyaları kopyalandı."
    fi
    
    # Hyprland yapılandırmasını güncelle - EWW otomatik başlatma
    if [ -f "$CONFIG_DIR/hypr/hyprland.conf" ]; then
        if ! grep -q "eww daemon" "$CONFIG_DIR/hypr/hyprland.conf"; then
            echo -e "\n# EWW bar otomatik başlatma\nexec-once = eww daemon\nexec-once = eww open bar" >> "$CONFIG_DIR/hypr/hyprland.conf"
            echo -e "${GREEN}[OK]${NC} Hyprland yapılandırması EWW için güncellendi."
        fi
    fi
else
    # Waybar kurulumu
    echo -e "${YELLOW}[INFO]${NC} Waybar yapılandırması kuruluyor..."
    
    # Waybar dosyaları için mevcut kodu çalıştır
    if [ -f "$SCRIPT_DIR/waybar/config.jsonc" ] || [ -f "$SCRIPT_DIR/waybar/config" ]; then
        if [ -f "$SCRIPT_DIR/waybar/config.jsonc" ]; then
            cp "$SCRIPT_DIR/waybar/config.jsonc" "$CONFIG_DIR/waybar/"
        else
            cp "$SCRIPT_DIR/waybar/config" "$CONFIG_DIR/waybar/"
        fi
        echo -e "${GREEN}[OK]${NC} Waybar konfigürasyonu kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} waybar/config bulunamadı."
    fi

    if [ -f "$SCRIPT_DIR/waybar/style.css" ]; then
        cp "$SCRIPT_DIR/waybar/style.css" "$CONFIG_DIR/waybar/"
        echo -e "${GREEN}[OK]${NC} Waybar stil dosyası kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} waybar/style.css bulunamadı."
    fi

    # Waybar scriptleri
    if [ -d "$SCRIPT_DIR/waybar/scripts" ]; then
        cp -r "$SCRIPT_DIR/waybar/scripts"/* "$CONFIG_DIR/waybar/scripts/"
        chmod +x "$CONFIG_DIR/waybar/scripts/"*.py "$CONFIG_DIR/waybar/scripts/"*.sh 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Waybar scriptleri kopyalandı ve çalıştırılabilir yapıldı."
    else
        echo -e "${RED}[ERROR]${NC} waybar/scripts dizini bulunamadı."
    fi

    # Waybar assets klasörünü oluştur ve dosyaları kopyala
    mkdir -p "$CONFIG_DIR/waybar/assets"
    if [ -d "$SCRIPT_DIR/waybar/assets" ] && [ "$(ls -A "$SCRIPT_DIR/waybar/assets" 2>/dev/null)" ]; then
        cp -r "$SCRIPT_DIR/waybar/assets"/* "$CONFIG_DIR/waybar/assets/"
        echo -e "${GREEN}[OK]${NC} Waybar assets dosyaları kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} waybar/assets dizini bulunamadı veya boş."
    fi
fi

# Kitty
if [ -f "$SCRIPT_DIR/kitty/kitty.conf" ]; then
    cp "$SCRIPT_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/"
    echo -e "${GREEN}[OK]${NC} Kitty konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} kitty/kitty.conf bulunamadı."
fi

# Hyprpaper
if [ -f "$SCRIPT_DIR/hypr/hyprpaper.conf" ]; then
    cp "$SCRIPT_DIR/hypr/hyprpaper.conf" "$CONFIG_DIR/hypr/"
    echo -e "${GREEN}[OK]${NC} Hyprpaper konfigürasyonu kopyalandı."
else
    echo -e "${YELLOW}[WARNING]${NC} hypr/hyprpaper.conf bulunamadı. Basit bir yapılandırma oluşturuluyor..."
    cat > "$CONFIG_DIR/hypr/hyprpaper.conf" << 'EOL'
# Wallpaper ayarları
# preload = ~/Pictures/Wallpapers/your_wallpaper.png
# wallpaper = ,~/Pictures/Wallpapers/your_wallpaper.png
EOL
fi

# Rofi dizinlerini oluştur
mkdir -p "$CONFIG_DIR/rofi/scripts"

# Rofi dosyalarını kopyala
if [ -f "$SCRIPT_DIR/rofi/config.rasi" ]; then
    cp "$SCRIPT_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi/"
    echo -e "${GREEN}[OK]${NC} Rofi konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} rofi/config.rasi bulunamadı."
fi

if [ -f "$SCRIPT_DIR/rofi/spotlight.rasi" ]; then
    cp "$SCRIPT_DIR/rofi/spotlight.rasi" "$CONFIG_DIR/rofi/"
    echo -e "${GREEN}[OK]${NC} Rofi Spotlight teması kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} rofi/spotlight.rasi bulunamadı."
fi

# Rofi scriptlerini kopyala
if [ -d "$SCRIPT_DIR/rofi/scripts" ]; then
    cp -r "$SCRIPT_DIR/rofi/scripts"/* "$CONFIG_DIR/rofi/scripts/"
    chmod +x "$CONFIG_DIR/rofi/scripts/"*.sh 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Rofi scriptleri kopyalandı ve çalıştırılabilir yapıldı."
else
    echo -e "${RED}[ERROR]${NC} rofi/scripts dizini bulunamadı."
fi

# Swaylock dizinini oluştur
if [ -f "$SCRIPT_DIR/swaylock/config" ]; then
    cp "$SCRIPT_DIR/swaylock/config" "$CONFIG_DIR/swaylock/"
    echo -e "${GREEN}[OK]${NC} Swaylock konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} swaylock/config bulunamadı."
fi

# Duvar kağıdı dosyalarını kopyala
if [ -d "$SCRIPT_DIR/hypr/wallpapers" ] && [ "$(ls -A "$SCRIPT_DIR/hypr/wallpapers" 2>/dev/null)" ]; then
    cp -r "$SCRIPT_DIR/hypr/wallpapers"/* "$CONFIG_DIR/hypr/wallpapers/"
    echo -e "${GREEN}[OK]${NC} Duvar kağıtları kopyalandı."
else
    echo -e "${YELLOW}[WARNING]${NC} Duvar kağıdı dosyaları bulunamadı veya dizin boş."
    # Varsayılan duvar kağıdını indirip yerleştir
    echo -e "${YELLOW}[INFO]${NC} Varsayılan duvar kağıdı indiriliyor..."
    
    # curl veya wget ile indirme denemesi
    if command -v curl >/dev/null 2>&1; then
        curl -s -o "$CONFIG_DIR/hypr/wallpapers/wallpaper.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
        curl -s -o "$CONFIG_DIR/hypr/wallpapers/lockscreen.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$CONFIG_DIR/hypr/wallpapers/wallpaper.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
        wget -q -O "$CONFIG_DIR/hypr/wallpapers/lockscreen.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
    else
        echo -e "${RED}[ERROR]${NC} curl veya wget bulunamadı. Duvar kağıdını manuel olarak eklemeniz gerekecek."
    fi
    
    if [ -f "$CONFIG_DIR/hypr/wallpapers/wallpaper.png" ]; then
        echo -e "${GREEN}[OK]${NC} Varsayılan duvar kağıdı indirildi."
    fi
fi

# SDDM temasını kurma bölümü
install_sddm_theme() {
    # Önce tema dosyalarının varlığını kontrol et
    if [ ! -d "$SCRIPT_DIR/sddm-themes" ]; then
        echo -e "${YELLOW}[WARNING]${NC} SDDM tema dizini bulunamadı, oluşturuluyor..."
        mkdir -p "$SCRIPT_DIR/sddm-themes"
        mkdir -p "$SCRIPT_DIR/sddm-themes/assets"
        
        # Örnek tema dosyalarını oluştur
        echo -e "${YELLOW}[INFO]${NC} Varsayılan SDDM tema dosyaları oluşturuluyor..."
        
        # Arkaplan indirme denemesi
        if command -v curl >/dev/null 2>&1; then
            curl -s -o "$SCRIPT_DIR/sddm-themes/background.jpg" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/misc/purplish-green.jpg"
        elif command -v wget >/dev/null 2>&1; then
            wget -q -O "$SCRIPT_DIR/sddm-themes/background.jpg" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/misc/purplish-green.jpg"
        else
            echo -e "${RED}[ERROR]${NC} curl veya wget bulunamadı. SDDM arkaplan resmini manuel olarak eklemeniz gerekecek."
        fi
        
        if [ ! -f "$SCRIPT_DIR/sddm-themes/background.jpg" ]; then
            echo -e "${RED}[ERROR]${NC} SDDM arkaplan resmi indirilemedi veya oluşturulamadı."
            return 1
        fi
    fi
    
    echo -e "${YELLOW}[INFO]${NC} SDDM 'Neo-Futura' teması kuruluyor..."
    
    # SDDM dizinini kontrol et ve oluştur
    if [ ! -d "/usr/share/sddm/themes" ]; then
        echo -e "${YELLOW}[INFO]${NC} SDDM tema dizini bulunamadı, oluşturuluyor..."
        sudo mkdir -p /usr/share/sddm/themes
    fi
    
    # Tema dizinini oluştur
    sudo mkdir -p /usr/share/sddm/themes/neo-futura
    sudo mkdir -p /usr/share/sddm/themes/neo-futura/assets
    
    # Tema dosyalarını kopyala
    sudo cp "$SCRIPT_DIR/sddm-themes/Main.qml" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/IconButton.qml" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/theme.conf" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/metadata.desktop" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/background.jpg" /usr/share/sddm/themes/neo-futura/
    
    # Asset dosyalarını kopyala
    sudo cp "$SCRIPT_DIR/sddm-themes/assets/"*.svg /usr/share/sddm/themes/neo-futura/assets/
    
    # İzinleri ayarla
    sudo chmod 644 /usr/share/sddm/themes/neo-futura/*
    sudo chmod 644 /usr/share/sddm/themes/neo-futura/assets/*
    sudo chmod 755 /usr/share/sddm/themes/neo-futura/assets
    
    echo -e "${GREEN}[INFO]${NC} SDDM arkaplan resmi: /usr/share/sddm/themes/neo-futura/background.jpg"
    echo -e "${BLUE}[TIP]${NC} Arkaplanı değiştirmek için bu dosyayı başka bir resimle değiştirebilirsiniz."
    
    # SDDM yapılandırmasını ayarla
    if [ ! -d "/etc/sddm.conf.d" ]; then
        sudo mkdir -p /etc/sddm.conf.d
    fi
    
    echo "[Theme]
Current=neo-futura" | sudo tee /etc/sddm.conf.d/10-theme.conf > /dev/null
    
    echo -e "${GREEN}[SUCCESS]${NC} SDDM teması kuruldu!"
}

# Ana script içinde kullanıcıya SDDM kurulumunu sor
echo -e "${YELLOW}[INFO]${NC} SDDM 'Neo-Futura' temasını kurmak istiyor musunuz? (y/n)"
read -r install_sddm

if [[ "$install_sddm" == "y" || "$install_sddm" == "Y" ]]; then
    install_sddm_theme
fi

install_cursor_theme() {
    echo -e "${YELLOW}[INFO]${NC} Kubi Cursor teması kuruluyor..."
    
    # Önce gerekli paketi kur
    if [ -x "$(command -v pacman)" ]; then
        sudo pacman -S --noconfirm python-pip
        pip install clickgen
    elif [ -x "$(command -v apt)" ]; then
        sudo apt install -y python3-pip
        pip3 install clickgen
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y python3-pip
        pip3 install clickgen
    fi
    
    # Cursor oluşturma scriptini çalıştır
    if [ -f "$REPO_DIR/kubi-cursor/create-cursor.sh" ]; then
        cd "$REPO_DIR/kubi-cursor"
        chmod +x create-cursor.sh
        ./create-cursor.sh
        
        # Kullanıcı dizinine kur
        mkdir -p "$HOME/.local/share/icons/"
        cp -r Kubi-theme "$HOME/.local/share/icons/"
        
        echo -e "${GREEN}[OK]${NC} Cursor teması kullanıcı dizinine kuruldu."
        
        # Hyprland yapılandırmasını güncelle
        if [ -f "$CONFIG_DIR/hypr/hyprland.conf" ]; then
            if ! grep -q "XCURSOR_THEME" "$CONFIG_DIR/hypr/hyprland.conf"; then
                echo -e "\n# Cursor tema ayarları\nenv = XCURSOR_THEME,Kubi-theme\nenv = XCURSOR_SIZE,24" >> "$CONFIG_DIR/hypr/hyprland.conf"
                echo -e "${GREEN}[OK]${NC} Hyprland yapılandırması cursor için güncellendi."
            fi
        fi
        
        # Başlangıç dizinine geri dön
        cd "$SCRIPT_DIR"
    else
        echo -e "${RED}[ERROR]${NC} Cursor oluşturma scripti bulunamadı."
        echo -e "${YELLOW}[INFO]${NC} $REPO_DIR/kubi-cursor/create-cursor.sh dosyası gerekli."
    fi
}

# Ana script içinde kullanıcıya cursor kurulumunu sor
echo -e "${YELLOW}[INFO]${NC} Kubi Cursor temasını kurmak istiyor musunuz? (y/n)"
read -r install_cursor

if [[ "$install_cursor" == "y" || "$install_cursor" == "Y" ]]; then
    install_cursor_theme
fi

echo -e "${GREEN}[SUCCESS]${NC} Kurulum tamamlandı!"
echo -e "${YELLOW}[INFO]${NC} Wallpaper ayarlamak için:"
echo "1. Duvar kağıdını ~/.config/hypr/wallpapers/ dizinine kopyalayın"
echo "2. Ana duvar kağıdı için wallpaper.png olarak, kilit ekranı için lockscreen.png olarak adlandırın"
echo "3. Veya ~/.config/hypr/hyprpaper.conf ve ~/.config/swaylock/config dosyalarını düzenleyin"
echo -e "${YELLOW}[INFO]${NC} Değişikliklerin etkili olması için oturumunuzu kapatıp yeniden giriş yapmalısınız."
echo -e "${BLUE}[TIP]${NC} Hyprland'i başlatmak için tty'de 'Hyprland' komutunu çalıştırabilirsiniz."