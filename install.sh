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

# Paket kurulumu için sorma
echo -e "${YELLOW}[INFO]${NC} Bağımlılıkları kurmak istiyor musunuz? (y/n)"
read -r install_deps

if [[ "$install_deps" == "y" || "$install_deps" == "Y" ]]; then
    # Paket yöneticisini tespit et
    if [ -x "$(command -v pacman)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Arch tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo pacman -S --noconfirm hyprland hyprpaper waybar kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard
    elif [ -x "$(command -v apt)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Debian tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo apt install -y hyprland waybar kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard
    elif [ -x "$(command -v dnf)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Fedora tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo dnf install -y hyprland waybar kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard
    else
        echo -e "${RED}[ERROR]${NC} Paket yöneticisi desteklenmiyor. Lütfen gerekli paketleri manuel olarak kurun."
    fi
fi

# Konfigürasyon dizinlerini oluştur
echo -e "${YELLOW}[INFO]${NC} Konfigürasyon dizinleri oluşturuluyor..."
mkdir -p "$CONFIG_DIR/hypr"
mkdir -p "$CONFIG_DIR/waybar/scripts"
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$HOME/Pictures/Screenshots"

# Dosyaları kopyala
echo -e "${YELLOW}[INFO]${NC} Konfigürasyon dosyaları kopyalanıyor..."

# Hyprland
if [ -f "$SCRIPT_DIR/hypr/hyprland.conf" ]; then
    cp "$SCRIPT_DIR/hypr/hyprland.conf" "$CONFIG_DIR/hypr/"
    echo -e "${GREEN}[OK]${NC} Hyprland konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} hypr/hyprland.conf bulunamadı."
fi

# Waybar
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
    chmod +x "$CONFIG_DIR/waybar/scripts/"*.py "$CONFIG_DIR/waybar/scripts/"*.sh
    echo -e "${GREEN}[OK]${NC} Waybar scriptleri kopyalandı ve çalıştırılabilir yapıldı."
else
    echo -e "${RED}[ERROR]${NC} waybar/scripts dizini bulunamadı."
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

# SDDM temasını kurma bölümü
install_sddm_theme() {
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
    sudo cp "$SCRIPT_DIR/sddm-themes/neo-futura/Main.qml" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/neo-futura/IconButton.qml" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/neo-futura/theme.conf" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/neo-futura/metadata.desktop" /usr/share/sddm/themes/neo-futura/
    sudo cp "$SCRIPT_DIR/sddm-themes/neo-futura/background.jpg" /usr/share/sddm/themes/neo-futura/
    
    # Asset dosyalarını kopyala
    sudo cp "$SCRIPT_DIR/sddm-themes/neo-futura/assets/"*.svg /usr/share/sddm/themes/neo-futura/assets/
    
    # İzinleri ayarla
    sudo chmod 644 /usr/share/sddm/themes/neo-futura/*
    sudo chmod 644 /usr/share/sddm/themes/neo-futura/assets/*
    sudo chmod 755 /usr/share/sddm/themes/neo-futura/assets
    
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

echo -e "${GREEN}[SUCCESS]${NC} Kurulum tamamlandı!"
echo -e "${YELLOW}[INFO]${NC} Wallpaper ayarlamak için:"
echo "1. Bir duvar kağıdı seçin ve ~/Pictures/Wallpapers/ dizinine kopyalayın"
echo "2. ~/.config/hypr/hyprpaper.conf dosyasını açın ve duvar kağıdı yolunu düzenleyin"
echo -e "${YELLOW}[INFO]${NC} Değişikliklerin etkili olması için oturumunuzu kapatıp yeniden giriş yapmalısınız."
echo -e "${BLUE}[TIP]${NC} Hyprland'i başlatmak için tty'de 'Hyprland' komutunu çalıştırabilirsiniz."