#!/bin/bash

# Renk kodları
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} Kubi Cursor Paketi oluşturuluyor..."

# Gerekli dizinleri oluştur
mkdir -p Kubi-theme/cursors

# Mevcut kubi-cursor klasöründeki PNG'leri kontrol et
echo -e "${YELLOW}[INFO]${NC} Mevcut cursor dosyaları kontrol ediliyor..."

# Temel cursor listesi - dosya adı:cursor adı
BASIC_CURSORS=(
    "normal.png:left_ptr"      # Temel işaretçi
    "pointer.png:pointer"      # El işaretçisi
    "text.png:text"            # Metin işaretçisi
    "move.png:move"            # Taşıma işaretçisi
    "n-resize.png:n-resize"    # Kuzey (yukarı) yeniden boyutlandırma
    "e-resize.png:e-resize"    # Doğu (sağ) yeniden boyutlandırma
    "ne-resize.png:ne-resize"  # Kuzeydoğu (sağ üst) yeniden boyutlandırma
    "nw-resize.png:nw-resize"  # Kuzeybatı (sol üst) yeniden boyutlandırma
)

# Normal cursor'ları işle
echo -e "${YELLOW}[INFO]${NC} Temel cursor'lar işleniyor..."

# Temel işaretçileri işle
for cursor in "${BASIC_CURSORS[@]}"; do
    # cursor_file:cursor_name formatını ayır
    cursor_file="${cursor%%:*}"
    cursor_name="${cursor#*:}"
    
    if [ -f "$cursor_file" ]; then
        echo -e "${GREEN}[OK]${NC} $cursor_file işleniyor... ($cursor_name)"
        clickgen --png "$cursor_file" --out-name "$cursor_name" --out-dir Kubi-theme/cursors
    else
        echo -e "${YELLOW}[WARNING]${NC} $cursor_file bulunamadı, bu işaretçi atlanıyor."
    fi
done

# Alternatif isimler ve sembolleme (symlinks) ekle
echo -e "${YELLOW}[INFO]${NC} Alternatif cursor isimleri oluşturuluyor..."

# Alternatif isimler listesi - orijinal:alternatifler (virgülle ayrılmış)
ALIASES=(
    "left_ptr:default,arrow,top_left_arrow,x-cursor"
    "pointer:hand,hand1,hand2,pointing_hand"
    "text:ibeam,xterm,text_cursor"
    "move:all-scroll,fleur,size_all,mouse-move"
    "n-resize:top_side,s-resize,bottom_side"
    "e-resize:right_side,w-resize,left_side"
    "ne-resize:top_right_corner,sw-resize,bottom_left_corner"
    "nw-resize:top_left_corner,se-resize,bottom_right_corner"
)

# Alternatif isimleri oluştur
for alias in "${ALIASES[@]}"; do
    # original:alternatives formatını ayır
    original="${alias%%:*}"
    alternatives="${alias#*:}"
    
    # Orijinal cursor varsa alternatiflerini oluştur
    if [ -f "Kubi-theme/cursors/$original" ]; then
        # Virgülle ayrılmış alternatifleri ayır
        IFS=',' read -ra ALT_ARRAY <<< "$alternatives"
        for alt in "${ALT_ARRAY[@]}"; do
            echo -e "${GREEN}[OK]${NC} $original → $alt alternatifi oluşturuluyor..."
            ln -sf "$original" "Kubi-theme/cursors/$alt"
        done
    fi
done

# Eksik işaretçileri normal cursor'dan oluştur
if [ -f "normal.png" ]; then
    echo -e "${YELLOW}[INFO]${NC} Eksik cursor türleri için normal.png kullanılıyor..."
    for cursor_type in "help" "cross" "pencil" "not-allowed" "no-drop"; do
        if [ ! -f "${cursor_type}.png" ] && [ ! -f "Kubi-theme/cursors/${cursor_type}" ]; then
            echo -e "${GREEN}[OK]${NC} normal.png'den $cursor_type oluşturuluyor..."
            clickgen --png "normal.png" --out-name "$cursor_type" --out-dir Kubi-theme/cursors
        fi
    done
fi

# Animasyonlu cursor'ları işle
echo -e "${YELLOW}[INFO]${NC} Animasyonlu cursor'lar işleniyor..."

# Wait animasyonu - ayrı dosyalardan oluşturmak için
if ls wait*.png &> /dev/null; then
    echo -e "${GREEN}[OK]${NC} wait animasyonu işleniyor..."
    # Geçici bir dizine dosyaları kopyala
    mkdir -p wait-frames
    cp wait*.png wait-frames/
    # Kare sırasını doğru düzenlemek için yeniden adlandır
    i=1
    for frame in wait-frames/wait*.png; do
        mv "$frame" "wait-frames/wait-frame-$i.png"
        i=$((i+1))
    done
    clickgen --frame-dir wait-frames --out-name "wait" --fps 20 --out-dir Kubi-theme/cursors
    # Geçici dizini temizle
    rm -rf wait-frames
    
    # Wait için alternatif isimler oluştur
    for alt_name in "progress" "watch" "clock"; do
        ln -sf "wait" "Kubi-theme/cursors/$alt_name"
    done
fi

# Tema index dosyası oluştur
cat > Kubi-theme/index.theme << EOT
[Icon Theme]
Name=Kubi-theme
Comment=Mor-Viyole Temalı Cursor Paketi
Inherits=Adwaita
EOT

# Özet mesajı oluştur
AVAILABLE_CURSORS=""
for cursor in "${BASIC_CURSORS[@]}"; do
    cursor_file="${cursor%%:*}"
    if [ -f "$cursor_file" ]; then
        cursor_name="${cursor_file%.png}"
        if [ -z "$AVAILABLE_CURSORS" ]; then
            AVAILABLE_CURSORS="$cursor_name"
        else
            AVAILABLE_CURSORS="$AVAILABLE_CURSORS, $cursor_name"
        fi
    fi
done

if ls wait*.png &> /dev/null; then
    AVAILABLE_CURSORS="$AVAILABLE_CURSORS, wait (animasyonlu)"
fi

echo -e "${GREEN}[SUCCESS]${NC} Cursor paketi oluşturuldu: $(pwd)/Kubi-theme"
echo -e "${YELLOW}[INFO]${NC} Tema şu işaretçileri içeriyor: $AVAILABLE_CURSORS"
echo -e "${YELLOW}[INFO]${NC} Eksik işaretçiler Adwaita varsayılan temasından miras alınacak veya normal cursor'dan türetilecek."
echo -e "${YELLOW}[INFO]${NC} Paketi şuraya taşıyabilirsiniz: ~/.local/share/icons/Kubi-theme"
echo -e "${YELLOW}[INFO]${NC} Ya da: /usr/share/icons/Kubi-theme (sistem genelinde)"

