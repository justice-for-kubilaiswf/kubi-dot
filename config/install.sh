#!/bin/bash

# Script'i daha sağlam hale getirmek için ayarlar
set -euo pipefail

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

# AUR yardımcısını tespit etme fonksiyonu
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

# Paket kurulumu için sorma
echo -e "${YELLOW}[INFO]${NC} Bağımlılıkları kurmak istiyor musunuz? (y/n)"
read -r install_deps

if [[ "$install_deps" == "y" || "$install_deps" == "Y" ]]; then
    # Paket yöneticisini tespit et
    if [ -x "$(command -v pacman)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Arch tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        # Temel paketler
        sudo pacman -S --noconfirm --needed hyprland kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard polkit-kde-agent
        
        # Hyprpaper (AUR'dan olabilir)
        if [ -n "$AUR_HELPER" ]; then
            echo -e "${YELLOW}[INFO]${NC} $AUR_HELPER ile hyprpaper kuruluyor..."
            $AUR_HELPER -S --noconfirm hyprpaper
        elif pacman -Si hyprpaper &>/dev/null; then
            echo -e "${YELLOW}[INFO]${NC} pacman ile hyprpaper kuruluyor..."
            sudo pacman -S --noconfirm --needed hyprpaper
        else
            echo -e "${YELLOW}[WARNING]${NC} hyprpaper resmi depolarda veya bilinen bir AUR yardımcısıyla kurulamadı. Lütfen manuel olarak kurun."
        fi

        # Qt5/6 tema ayarları için paketler
        echo -e "${YELLOW}[INFO]${NC} Qt uygulamaları için tema ayar paketlerini (qt5ct, qt6ct, kvantum) kurmak ister misiniz? (y/n)"
        read -r install_qt_theme_pkgs
        if [[ "$install_qt_theme_pkgs" == "y" || "$install_qt_theme_pkgs" == "Y" ]]; then
            echo -e "${YELLOW}[INFO]${NC} qt5ct, qt6ct kuruluyor..."
            sudo pacman -S --noconfirm --needed qt5ct qt6ct

            if [ -n "$AUR_HELPER" ]; then
                echo -e "${YELLOW}[INFO]${NC} $AUR_HELPER ile qt5-styleplugins AUR paketi kuruluyor..."
                $AUR_HELPER -S --noconfirm --needed qt5-styleplugins
            else
                echo -e "${YELLOW}[WARNING]${NC} AUR yardımcısı (yay/paru) bulunamadı. qt5-styleplugins manuel olarak kurulmalıdır (örn: yay -S qt5-styleplugins)."
            fi
            
            echo -e "${YELLOW}[INFO]${NC} Kvantum tema motorunu kurmak ister misiniz? (y/n)"
            read -r install_kvantum
            if [[ "$install_kvantum" == "y" || "$install_kvantum" == "Y" ]]; then
                if [ -n "$AUR_HELPER" ]; then
                    echo -e "${YELLOW}[INFO]${NC} $AUR_HELPER ile kvantum (veya kvantum-qt5) kuruluyor..."
                    # Kvantum için hem qt5 hem de qt6 versiyonları olabilir, AUR'da genellikle `kvantum` veya `kvantum-qt5` ve `kvantum-qt6` bulunur.
                    # Sadece genel kvantum'u kurmayı deneyelim, kullanıcı gerekirse spesifik olanı seçebilir.
                    $AUR_HELPER -S --noconfirm kvantum 
                elif pacman -Si kvantum &>/dev/null; then
                     echo -e "${YELLOW}[INFO]${NC} pacman ile kvantum kuruluyor..."
                     sudo pacman -S --noconfirm --needed kvantum
                else
                    echo -e "${YELLOW}[WARNING]${NC} Kvantum resmi depolarda veya bilinen bir AUR yardımcısıyla kurulamadı. Lütfen manuel olarak kurun."
                fi
            fi
            echo -e "${GREEN}[OK]${NC} Qt tema paketleri kurulumu tamamlandı/atlandı."
            echo -e "${YELLOW}[INFO]${NC} Kurulum sonrası Qt tema ayarlarını yapmak için 'qt5ct' ve 'qt6ct' uygulamalarını çalıştırıp 'kvantum' gibi bir stil seçebilirsiniz."
        else
            echo -e "${YELLOW}[INFO]${NC} Qt tema paketlerinin kurulumu atlandı."
        fi

        # Kullanıcıya Waybar veya EWW seçeneği sun
        echo -e "${YELLOW}[INFO]${NC} Hangi bar kullanmak istersiniz?"
        echo "1. Waybar (Basit ve stabil)"
        echo "2. EWW (ElKowars Wacky Widgets - Modern ve özelleştirilebilir)"
        read -r bar_choice
        
        if [[ "$bar_choice" == "1" ]]; then
            sudo pacman -S --noconfirm --needed waybar
            use_eww=false
        else
            if [ -n "$AUR_HELPER" ]; then
                echo -e "${YELLOW}[INFO]${NC} $AUR_HELPER ile eww kuruluyor..."
                $AUR_HELPER -S --noconfirm eww-wayland # Genellikle eww-wayland veya eww-x11 olarak bulunur
            elif pacman -Si eww &>/dev/null; then
                 echo -e "${YELLOW}[INFO]${NC} pacman ile eww kuruluyor..."
                 sudo pacman -S --noconfirm --needed eww
            else
                echo -e "${YELLOW}[WARNING]${NC} eww resmi depolarda veya bilinen bir AUR yardımcısıyla kurulamadı. Lütfen manuel olarak kurun."
                # EWW kurulamadıysa Waybar'a dön
                echo -e "${YELLOW}[INFO]${NC} EWW kurulamadığı için Waybar kurulacak."
                sudo pacman -S --noconfirm --needed waybar
                use_eww=false 
            fi
            # Eğer AUR ile eww kurulduysa use_eww=true yapalım
            if command -v eww >/dev/null 2>&1; then
                 use_eww=true
            fi
        fi
    elif [ -x "$(command -v apt)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Debian tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo apt update
        sudo apt install -y hyprland kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard # polkit-kde-agent
        
        echo -e "${YELLOW}[INFO]${NC} Hangi bar kullanmak istersiniz?"
        echo "1. Waybar (Basit ve stabil)"
        echo "2. EWW (ElKowars Wacky Widgets - Modern ve özelleştirilebilir)"
        read -r bar_choice
        
        if [[ "$bar_choice" == "1" ]]; then
            sudo apt install -y waybar
            use_eww=false
        else
            echo -e "${YELLOW}[INFO]${NC} EWW'yi manuel olarak kurmanız gerekebilir (Örn: https://elkowar.github.io/eww/eww.html). Devam etmek istiyor musunuz? (y/n)"
            read -r eww_manual
            if [[ "$eww_manual" == "y" || "$eww_manual" == "Y" ]]; then
                use_eww=true # Kullanıcı manuel kuracağını varsayıyoruz
            else
                sudo apt install -y waybar
                use_eww=false
            fi
        fi
    elif [ -x "$(command -v dnf)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Fedora tabanlı sistem tespit edildi. Gerekli paketler kuruluyor..."
        sudo dnf install -y hyprland kitty rofi playerctl pamixer brightnessctl swaylock swayidle dunst grim slurp wl-clipboard # polkit-kde-agent
        
        echo -e "${YELLOW}[INFO]${NC} Hangi bar kullanmak istersiniz?"
        echo "1. Waybar (Basit ve stabil)"
        echo "2. EWW (ElKowars Wacky Widgets - Modern ve özelleştirilebilir)"
        read -r bar_choice
        
        if [[ "$bar_choice" == "1" ]]; then
            sudo dnf install -y waybar
            use_eww=false
        else
            echo -e "${YELLOW}[INFO]${NC} EWW'yi manuel olarak kurmanız gerekebilir (Örn: https://elkowar.github.io/eww/eww.html). Devam etmek istiyor musunuz? (y/n)"
            read -r eww_manual
            if [[ "$eww_manual" == "y" || "$eww_manual" == "Y" ]]; then
                use_eww=true # Kullanıcı manuel kuracağını varsayıyoruz
            else
                sudo dnf install -y waybar
                use_eww=false
            fi
        fi
    else
        echo -e "${RED}[ERROR]${NC} Paket yöneticisi desteklenmiyor. Lütfen gerekli paketleri manuel olarak kurun."
        exit 1
    fi
else
    echo -e "${YELLOW}[INFO]${NC} Bağımlılık kurulumu atlandı. Waybar'ın kurulu olduğu varsayılıyor."
    use_eww=false
    # Waybar kurulu değilse kullanıcıyı uyar
     if ! command -v waybar >/dev/null 2>&1 && ! $use_eww; then
        echo -e "${RED}[ERROR]${NC} Waybar kurulu değil. Lütfen manuel olarak kurun veya script'i bağımlılık kurulumuyla çalıştırın."
    fi
fi

# Konfigürasyon dizinlerini oluştur
echo -e "${YELLOW}[INFO]${NC} Konfigürasyon dizinleri oluşturuluyor..."
mkdir -p "$CONFIG_DIR/hypr"
mkdir -p "$CONFIG_DIR/hypr/wallpapers"
mkdir -p "$CONFIG_DIR/swaylock"
mkdir -p "$CONFIG_DIR/waybar/scripts"
mkdir -p "$CONFIG_DIR/eww/scripts" # EWW için de dizin oluşturulmalı
mkdir -p "$CONFIG_DIR/eww/images"  # EWW için de dizin oluşturulmalı
mkdir -p "$CONFIG_DIR/kitty"
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$CONFIG_DIR/rofi/scripts"

# Tüm script dosyalarına çalıştırma izni ver
echo -e "${YELLOW}[INFO]${NC} Script dosyalarına çalıştırma izni veriliyor..."
find "$SCRIPT_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;
if [ -d "$REPO_DIR/kubi-cursor" ]; then
    find "$REPO_DIR/kubi-cursor" -type f -name "*.sh" -exec chmod +x {} \;
fi

# Dosyaları kopyala
echo -e "${YELLOW}[INFO]${NC} Konfigürasyon dosyaları kopyalanıyor..."

# Hyprland
if [ -f "$SCRIPT_DIR/hypr/hyprland.conf" ]; then
    cp -v "$SCRIPT_DIR/hypr/hyprland.conf" "$CONFIG_DIR/hypr/"
    echo -e "${GREEN}[OK]${NC} Hyprland konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/hypr/hyprland.conf bulunamadı."
fi

# Waybar veya EWW kurulumu
if [ "$use_eww" = true ] && command -v eww >/dev/null 2>&1; then
    # EWW kurulumu
    echo -e "${YELLOW}[INFO]${NC} EWW yapılandırması kuruluyor..."
    
    if [ -f "$SCRIPT_DIR/eww/eww.yuck" ]; then
        cp -v "$SCRIPT_DIR/eww/eww.yuck" "$CONFIG_DIR/eww/"
    else
        echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/eww/eww.yuck bulunamadı."
    fi

    if [ -f "$SCRIPT_DIR/eww/eww.scss" ]; then
        cp -v "$SCRIPT_DIR/eww/eww.scss" "$CONFIG_DIR/eww/"
    else
        echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/eww/eww.scss bulunamadı."
    fi
    
    if [ -d "$SCRIPT_DIR/eww/scripts" ] && [ "$(ls -A "$SCRIPT_DIR/eww/scripts" 2>/dev/null)" ]; then
        cp -rv "$SCRIPT_DIR/eww/scripts"/* "$CONFIG_DIR/eww/scripts/"
        chmod +x "$CONFIG_DIR/eww/scripts"/*.sh 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} EWW scriptleri kopyalandı ve çalıştırılabilir yapıldı."
    else
        echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/eww/scripts dizini bulunamadı veya boş."
    fi
    
    if [ -d "$SCRIPT_DIR/eww/images" ] && [ "$(ls -A "$SCRIPT_DIR/eww/images" 2>/dev/null)" ]; then
        cp -rv "$SCRIPT_DIR/eww/images"/* "$CONFIG_DIR/eww/images/"
        echo -e "${GREEN}[OK]${NC} EWW görüntü dosyaları kopyalandı."
    else
        echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/eww/images dizini bulunamadı veya boş."
    fi
    
    if [ -f "$CONFIG_DIR/hypr/hyprland.conf" ]; then
        if ! grep -q "exec-once = eww daemon" "$CONFIG_DIR/hypr/hyprland.conf"; then
            echo -e "${YELLOW}[INFO]${NC} Hyprland yapılandırmasına EWW otomatik başlatma ekleniyor..."
            # Öneri: Bu satırları ayrı bir dosyaya yazıp (örn: ~/.config/hypr/custom_autostart.conf)
            # ana hyprland.conf'tan 'source = ~/.config/hypr/custom_autostart.conf' ile çağırabilirsiniz.
            echo -e "\n# EWW bar otomatik başlatma\nexec-once = eww daemon\nexec-once = eww open bar" >> "$CONFIG_DIR/hypr/hyprland.conf"
            echo -e "${GREEN}[OK]${NC} Hyprland yapılandırması EWW için güncellendi."
        else
            echo -e "${GREEN}[INFO]${NC} EWW otomatik başlatma zaten Hyprland yapılandırmasında mevcut."
        fi
    fi
elif command -v waybar >/dev/null 2>&1; then # Waybar kurulumu (EWW seçilmediyse veya kurulamadıysa)
    echo -e "${YELLOW}[INFO]${NC} Waybar yapılandırması kuruluyor..."
    
    config_file_waybar=""
    if [ -f "$SCRIPT_DIR/waybar/config.jsonc" ]; then
        config_file_waybar="$SCRIPT_DIR/waybar/config.jsonc"
    elif [ -f "$SCRIPT_DIR/waybar/config" ]; then
        config_file_waybar="$SCRIPT_DIR/waybar/config"
    fi

    if [ -n "$config_file_waybar" ]; then
        cp -v "$config_file_waybar" "$CONFIG_DIR/waybar/"
        echo -e "${GREEN}[OK]${NC} Waybar konfigürasyonu kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/waybar/config veya config.jsonc bulunamadı."
    fi

    if [ -f "$SCRIPT_DIR/waybar/style.css" ]; then
        cp -v "$SCRIPT_DIR/waybar/style.css" "$CONFIG_DIR/waybar/"
        echo -e "${GREEN}[OK]${NC} Waybar stil dosyası kopyalandı."
    else
        echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/waybar/style.css bulunamadı."
    fi

    if [ -d "$SCRIPT_DIR/waybar/scripts" ] && [ "$(ls -A "$SCRIPT_DIR/waybar/scripts" 2>/dev/null)" ]; then
        cp -rv "$SCRIPT_DIR/waybar/scripts"/* "$CONFIG_DIR/waybar/scripts/"
        chmod +x "$CONFIG_DIR/waybar/scripts/"*.py "$CONFIG_DIR/waybar/scripts/"*.sh 2>/dev/null || true
        echo -e "${GREEN}[OK]${NC} Waybar scriptleri kopyalandı ve çalıştırılabilir yapıldı."
    else
        echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/waybar/scripts dizini bulunamadı veya boş."
    fi

    mkdir -p "$CONFIG_DIR/waybar/assets"
    if [ -d "$SCRIPT_DIR/waybar/assets" ] && [ "$(ls -A "$SCRIPT_DIR/waybar/assets" 2>/dev/null)" ]; then
        cp -rv "$SCRIPT_DIR/waybar/assets"/* "$CONFIG_DIR/waybar/assets/"
        echo -e "${GREEN}[OK]${NC} Waybar assets dosyaları kopyalandı."
    else
        echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/waybar/assets dizini bulunamadı veya boş."
    fi
else
    echo -e "${RED}[ERROR]${NC} Ne EWW ne de Waybar kurulabildi veya yapılandırılabildi. Lütfen barınızı manuel olarak kurun ve yapılandırın."
fi


# Kitty
if [ -f "$SCRIPT_DIR/kitty/kitty.conf" ]; then
    cp -v "$SCRIPT_DIR/kitty/kitty.conf" "$CONFIG_DIR/kitty/"
    echo -e "${GREEN}[OK]${NC} Kitty konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/kitty/kitty.conf bulunamadı."
fi

# Hyprpaper
if [ -f "$SCRIPT_DIR/hypr/hyprpaper.conf" ]; then
    cp -v "$SCRIPT_DIR/hypr/hyprpaper.conf" "$CONFIG_DIR/hypr/"
    echo -e "${GREEN}[OK]${NC} Hyprpaper konfigürasyonu kopyalandı."
else
    echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/hypr/hyprpaper.conf bulunamadı. Basit bir yapılandırma oluşturuluyor..."
    cat > "$CONFIG_DIR/hypr/hyprpaper.conf" << EOL
# Wallpaper ayarları
# Lütfen ~/Pictures/Wallpapers/ dizinine kendi duvar kağıdınızı ekleyin
# ve aşağıdaki satırları uygun şekilde düzenleyin.
# preload = ~/Pictures/Wallpapers/your_wallpaper.png
# wallpaper = eDP-1,~/Pictures/Wallpapers/your_wallpaper.png
# wallpaper = ,~/Pictures/Wallpapers/your_wallpaper.png # Tüm ekranlar için
EOL
fi

# Rofi
if [ -f "$SCRIPT_DIR/rofi/config.rasi" ]; then
    cp -v "$SCRIPT_DIR/rofi/config.rasi" "$CONFIG_DIR/rofi/"
    echo -e "${GREEN}[OK]${NC} Rofi konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/rofi/config.rasi bulunamadı."
fi

if [ -f "$SCRIPT_DIR/rofi/spotlight.rasi" ]; then
    cp -v "$SCRIPT_DIR/rofi/spotlight.rasi" "$CONFIG_DIR/rofi/"
    echo -e "${GREEN}[OK]${NC} Rofi Spotlight teması kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/rofi/spotlight.rasi bulunamadı."
fi

if [ -d "$SCRIPT_DIR/rofi/scripts" ] && [ "$(ls -A "$SCRIPT_DIR/rofi/scripts" 2>/dev/null)" ]; then
    cp -rv "$SCRIPT_DIR/rofi/scripts"/* "$CONFIG_DIR/rofi/scripts/"
    chmod +x "$CONFIG_DIR/rofi/scripts/"*.sh 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} Rofi scriptleri kopyalandı ve çalıştırılabilir yapıldı."
else
    echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/rofi/scripts dizini bulunamadı veya boş."
fi

# Swaylock
if [ -f "$SCRIPT_DIR/swaylock/config" ]; then
    cp -v "$SCRIPT_DIR/swaylock/config" "$CONFIG_DIR/swaylock/"
    echo -e "${GREEN}[OK]${NC} Swaylock konfigürasyonu kopyalandı."
else
    echo -e "${RED}[ERROR]${NC} $SCRIPT_DIR/swaylock/config bulunamadı."
fi

# Duvar kağıdı dosyalarını kopyala
if [ -d "$SCRIPT_DIR/hypr/wallpapers" ] && [ "$(ls -A "$SCRIPT_DIR/hypr/wallpapers" 2>/dev/null)" ]; then
    cp -rv "$SCRIPT_DIR/hypr/wallpapers"/* "$CONFIG_DIR/hypr/wallpapers/"
    echo -e "${GREEN}[OK]${NC} Duvar kağıtları kopyalandı."
else
    echo -e "${YELLOW}[WARNING]${NC} $SCRIPT_DIR/hypr/wallpapers dizini bulunamadı veya boş. Varsayılan duvar kağıdı indiriliyor..."
    if command -v curl >/dev/null 2>&1; then
        curl -sLo "$CONFIG_DIR/hypr/wallpapers/wallpaper.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
        curl -sLo "$CONFIG_DIR/hypr/wallpapers/lockscreen.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$CONFIG_DIR/hypr/wallpapers/wallpaper.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
        wget -qO "$CONFIG_DIR/hypr/wallpapers/lockscreen.png" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png"
    else
        echo -e "${RED}[ERROR]${NC} curl veya wget bulunamadı. Duvar kağıdını manuel olarak eklemeniz gerekecek."
    fi
    
    if [ -f "$CONFIG_DIR/hypr/wallpapers/wallpaper.png" ]; then
        echo -e "${GREEN}[OK]${NC} Varsayılan duvar kağıdı indirildi."
    fi
fi

# SDDM temasını kurma bölümü
install_sddm_theme() {
    THEME_SOURCE_DIR="$SCRIPT_DIR/sddm-themes"
    THEME_NAME="neo-futura" # Temanızın adını buraya yazın
    SDDM_THEMES_DIR="/usr/share/sddm/themes"
    TARGET_THEME_DIR="$SDDM_THEMES_DIR/$THEME_NAME"

    echo -e "${YELLOW}[INFO]${NC} SDDM '$THEME_NAME' teması kuruluyor..."

    # Kaynak tema dosyalarının varlığını kontrol et
    if [ ! -d "$THEME_SOURCE_DIR" ]; then
        echo -e "${RED}[ERROR]${NC} Kaynak SDDM tema dizini '$THEME_SOURCE_DIR' bulunamadı."
        echo -e "${YELLOW}[INFO]${NC} Lütfen temanızın dosyalarını bu dizine yerleştirin: Main.qml, theme.conf, metadata.desktop ve assets."
        return 1
    fi
    if [ ! -f "$THEME_SOURCE_DIR/Main.qml" ] || [ ! -f "$THEME_SOURCE_DIR/theme.conf" ] || [ ! -f "$THEME_SOURCE_DIR/metadata.desktop" ]; then
        echo -e "${RED}[ERROR]${NC} Gerekli SDDM tema dosyaları (Main.qml, theme.conf, metadata.desktop) '$THEME_SOURCE_DIR' içinde eksik."
        return 1
    fi
    if [ -d "$THEME_SOURCE_DIR/assets" ] && [ ! "$(ls -A "$THEME_SOURCE_DIR/assets" 2>/dev/null)" ]; then
         echo -e "${YELLOW}[WARNING]${NC} '$THEME_SOURCE_DIR/assets' dizini boş. Tema düzgün görünmeyebilir."
    elif [ ! -d "$THEME_SOURCE_DIR/assets" ]; then
        echo -e "${YELLOW}[WARNING]${NC} '$THEME_SOURCE_DIR/assets' dizini bulunamadı. Tema düzgün görünmeyebilir."
        mkdir -p "$THEME_SOURCE_DIR/assets" # Oluşturmayı deneyelim, belki sadece arkaplan vardı.
    fi

    # Varsayılan arkaplan resmi (eğer background.jpg yoksa)
    if [ ! -f "$THEME_SOURCE_DIR/background.jpg" ]; then
        echo -e "${YELLOW}[INFO]${NC} '$THEME_SOURCE_DIR/background.jpg' bulunamadı. Varsayılan bir arkaplan indiriliyor..."
        if command -v curl >/dev/null 2>&1; then
            curl -sLo "$THEME_SOURCE_DIR/background.jpg" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/misc/purplish-green.jpg"
        elif command -v wget >/dev/null 2>&1; then
            wget -qO "$THEME_SOURCE_DIR/background.jpg" "https://raw.githubusercontent.com/catppuccin/wallpapers/main/misc/purplish-green.jpg"
        fi
        if [ ! -f "$THEME_SOURCE_DIR/background.jpg" ]; then
            echo -e "${RED}[ERROR]${NC} Varsayılan SDDM arkaplan resmi indirilemedi. Lütfen manuel olarak bir 'background.jpg' ekleyin."
            # return 1 # Arkaplansız da devam edebiliriz aslında
        fi
    fi
    
    # SDDM sistem tema dizinini kontrol et ve oluştur (gerekirse)
    if [ ! -d "$SDDM_THEMES_DIR" ]; then
        echo -e "${YELLOW}[INFO]${NC} SDDM sistem tema dizini '$SDDM_THEMES_DIR' bulunamadı, oluşturuluyor..."
        sudo mkdir -p "$SDDM_THEMES_DIR"
    fi
    
    # Hedef tema dizinini oluştur
    echo -e "${YELLOW}[INFO]${NC} Hedef tema dizini '$TARGET_THEME_DIR' oluşturuluyor..."
    sudo mkdir -p "$TARGET_THEME_DIR/assets"
    
    # Tema dosyalarını kopyala
    echo -e "${YELLOW}[INFO]${NC} Tema dosyaları '$TARGET_THEME_DIR' dizinine kopyalanıyor..."
    sudo cp -v "$THEME_SOURCE_DIR/Main.qml" "$TARGET_THEME_DIR/"
    sudo cp -v "$THEME_SOURCE_DIR/theme.conf" "$TARGET_THEME_DIR/"
    sudo cp -v "$THEME_SOURCE_DIR/metadata.desktop" "$TARGET_THEME_DIR/"
    # Opsiyonel dosyalar
    [ -f "$THEME_SOURCE_DIR/IconButton.qml" ] && sudo cp -v "$THEME_SOURCE_DIR/IconButton.qml" "$TARGET_THEME_DIR/"
    [ -f "$THEME_SOURCE_DIR/background.jpg" ] && sudo cp -v "$THEME_SOURCE_DIR/background.jpg" "$TARGET_THEME_DIR/"
    
    # Asset dosyalarını kopyala (eğer assets dizini varsa ve boş değilse)
    if [ -d "$THEME_SOURCE_DIR/assets" ] && [ "$(ls -A "$THEME_SOURCE_DIR/assets" 2>/dev/null)" ]; then
        echo -e "${YELLOW}[INFO]${NC} Asset dosyaları '$TARGET_THEME_DIR/assets/' dizinine kopyalanıyor..."
        sudo cp -rv "$THEME_SOURCE_DIR/assets/"* "$TARGET_THEME_DIR/assets/"
    else
        echo -e "${YELLOW}[WARNING]${NC} '$THEME_SOURCE_DIR/assets' dizini bulunamadı veya boş. Assetler kopyalanmadı."
    fi
    
    # İzinleri ayarla
    echo -e "${YELLOW}[INFO]${NC} Dosya izinleri ayarlanıyor..."
    sudo chmod -R 644 "$TARGET_THEME_DIR"
    sudo find "$TARGET_THEME_DIR" -type d -exec sudo chmod 755 {} \;
    
    if [ -f "$TARGET_THEME_DIR/background.jpg" ]; then
      echo -e "${GREEN}[INFO]${NC} SDDM arkaplan resmi: $TARGET_THEME_DIR/background.jpg"
      echo -e "${BLUE}[TIP]${NC} Arkaplanı değiştirmek için bu dosyayı başka bir resimle değiştirebilirsiniz."
    fi
    
    # SDDM yapılandırmasını ayarla
    SDDM_CONF_DIR="/etc/sddm.conf.d"
    SDDM_THEME_CONF_FILE="$SDDM_CONF_DIR/10-theme.conf"
    echo -e "${YELLOW}[INFO]${NC} SDDM yapılandırması '$SDDM_THEME_CONF_FILE' dosyasına yazılıyor..."
    if [ ! -d "$SDDM_CONF_DIR" ]; then
        sudo mkdir -p "$SDDM_CONF_DIR"
    fi
    
    echo -e "[Theme]\nCurrent=$THEME_NAME" | sudo tee "$SDDM_THEME_CONF_FILE" > /dev/null
    
    echo -e "${GREEN}[SUCCESS]${NC} SDDM teması '$THEME_NAME' kuruldu!"
    echo -e "${YELLOW}[INFO]${NC} Değişikliklerin etkili olması için SDDM servisini yeniden başlatmanız veya sistemi yeniden başlatmanız gerekebilir."
}

# Ana script içinde kullanıcıya SDDM kurulumunu sor
echo -e "${YELLOW}[INFO]${NC} SDDM temasını ('neo-futura' varsayılır) kurmak istiyor musunuz? (y/n)"
read -r install_sddm

if [[ "$install_sddm" == "y" || "$install_sddm" == "Y" ]]; then
    install_sddm_theme
fi

install_cursor_theme() {
    echo -e "${YELLOW}[INFO]${NC} Kubi Cursor teması kuruluyor..."
    
    # Gerekli clickgen paketini kur (Arch için AUR)
    if [ -x "$(command -v pacman)" ]; then
        echo -e "${YELLOW}[INFO]${NC} python-clickgen paketi kontrol ediliyor/kuruluyor..."
        if [ -n "$AUR_HELPER" ]; then
            $AUR_HELPER -S --noconfirm --needed python-clickgen
        elif pacman -Si python-clickgen &>/dev/null; then # Belki resmi depolardadır? (Düşük ihtimal)
            sudo pacman -S --noconfirm --needed python-clickgen
        else
            echo -e "${RED}[ERROR]${NC} python-clickgen için bilinen bir AUR yardımcısı bulunamadı veya paket depolarda yok."
            echo -e "${YELLOW}[INFO]${NC} Lütfen python-clickgen'i manuel olarak kurun (örn: yay -S python-clickgen) ve script'i tekrar çalıştırın."
            return 1
        fi
    # Diğer dağıtımlar için pip ile devam (kullanıcı bazlı daha iyi olabilir)
    elif [ -x "$(command -v apt)" ]; then
        sudo apt update
        sudo apt install -y python3-pip python3-venv # venv önerilir
        pip3 install --user clickgen # Kullanıcı bazlı kurulum
        # ~/.local/bin'in PATH'te olduğundan emin olunması gerekir
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf install -y python3-pip python3-virtualenv # virtualenv önerilir
        pip3 install --user clickgen # Kullanıcı bazlı kurulum
    else
        echo -e "${RED}[ERROR]${NC} clickgen kurulumu için uygun bir yöntem bulunamadı."
        return 1
    fi

    if ! command -v clickgen &>/dev/null; then
        echo -e "${RED}[ERROR]${NC} clickgen komutu bulunamadı. Kurulum başarısız olmuş olabilir veya PATH'e eklenmemiş olabilir."
        echo -e "${YELLOW}[INFO]${NC} Eğer pip ile --user kurduysanız, ~/.local/bin dizininin PATH ortam değişkeninizde olduğundan emin olun."
        return 1
    fi
    
    # Cursor oluşturma scriptini çalıştır
    if [ -f "$REPO_DIR/kubi-cursor/create-cursor.sh" ]; then
        echo -e "${YELLOW}[INFO]${NC} Cursor oluşturma scripti çalıştırılıyor..."
        cd "$REPO_DIR/kubi-cursor"
        # chmod +x create-cursor.sh # Zaten yukarıda yapılıyor olmalı
        if ./create-cursor.sh; then # Scriptin başarılı olup olmadığını kontrol et
            # Kullanıcı dizinine kur
            mkdir -p "$HOME/.local/share/icons/"
            cp -rv Kubi-theme "$HOME/.local/share/icons/"
            echo -e "${GREEN}[OK]${NC} Cursor teması '$HOME/.local/share/icons/' dizinine kuruldu."
            
            # Hyprland yapılandırmasını güncelle
            if [ -f "$CONFIG_DIR/hypr/hyprland.conf" ]; then
                if ! grep -q "env = XCURSOR_THEME,Kubi-theme" "$CONFIG_DIR/hypr/hyprland.conf"; then
                    echo -e "${YELLOW}[INFO]${NC} Hyprland yapılandırmasına cursor tema ayarları ekleniyor..."
                    echo -e "\n# Cursor tema ayarları\nenv = XCURSOR_THEME,Kubi-theme\nenv = XCURSOR_SIZE,24" >> "$CONFIG_DIR/hypr/hyprland.conf"
                    echo -e "${GREEN}[OK]${NC} Hyprland yapılandırması cursor için güncellendi."
                else
                    echo -e "${GREEN}[INFO]${NC} Cursor tema ayarları zaten Hyprland yapılandırmasında mevcut."
                fi
            fi
        else
            echo -e "${RED}[ERROR]${NC} Cursor oluşturma scripti başarısız oldu."
        fi
        # Başlangıç dizinine geri dön
        cd "$SCRIPT_DIR"
    else
        echo -e "${RED}[ERROR]${NC} Cursor oluşturma scripti '$REPO_DIR/kubi-cursor/create-cursor.sh' bulunamadı."
    fi
}

# Ana script içinde kullanıcıya cursor kurulumunu sor
echo -e "${YELLOW}[INFO]${NC} Kubi Cursor temasını kurmak istiyor musunuz? (y/n)"
read -r install_cursor

if [[ "$install_cursor" == "y" || "$install_cursor" == "Y" ]]; then
    install_cursor_theme
fi

echo -e "${GREEN}[SUCCESS]${NC} Kurulum tamamlandı!"
echo -e "${YELLOW}[INFO]${NC} Önemli Notlar:"
echo -e "  - Wallpaper ayarlamak için:"
echo -e "    1. Duvar kağıdınızı '$HOME/.config/hypr/wallpapers/' dizinine kopyalayın."
echo -e "    2. Ana duvar kağıdı için 'wallpaper.png', kilit ekranı için 'lockscreen.png' olarak adlandırın."
echo -e "    3. Veya '$HOME/.config/hypr/hyprpaper.conf' ve '$HOME/.config/swaylock/config' dosyalarını düzenleyin."
echo -e "  - SDDM teması için değişikliklerin etkili olması için SDDM servisini yeniden başlatmanız ('sudo systemctl restart sddm') veya sistemi yeniden başlatmanız gerekebilir."
echo -e "  - Diğer değişikliklerin (bar, cursor vb.) etkili olması için oturumunuzu kapatıp yeniden giriş yapmalısınız."
echo -e "${BLUE}[TIP]${NC} Hyprland'i başlatmak için TTY'de 'Hyprland' komutunu çalıştırabilirsiniz."