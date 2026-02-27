#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="config.conf"
DOWNLOAD_DIR="downloads"
FORMATS_DIR="formats"

# Create directories if not exist
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$FORMATS_DIR"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    # Default configuration
    echo "QUALITY=best" > "$CONFIG_FILE"
    echo "FORMAT=mp4" >> "$CONFIG_FILE"
    echo "DOWNLOAD_PATH=./downloads" >> "$CONFIG_FILE"
fi

# Banner function
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════╗"
    echo "║    SOCIAL MEDIA DOWNLOADER v1.0    ║"
    echo "║      YouTube + Instagram Tool       ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${NC}"
}

# Main menu
main_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}1.${NC} Download Video"
        echo -e "${GREEN}2.${NC} Batch Download"
        echo -e "${GREEN}3.${NC} Convert Format"
        echo -e "${GREEN}4.${NC} Settings"
        echo -e "${GREEN}5.${NC} View Downloads"
        echo -e "${RED}6.${NC} Exit"
        echo ""
        read -p "Select option: " choice

        case $choice in
            1) download_video ;;
            2) batch_download ;;
            3) convert_format ;;
            4) settings_menu ;;
            5) view_downloads ;;
            6) exit 0 ;;
            *) echo -e "${RED}Invalid option!${NC}"; sleep 2 ;;
        esac
    done
}

# Download single video
download_video() {
    show_banner
    echo -e "${YELLOW}📥 Download Video${NC}"
    echo "------------------------"
    
    read -p "Enter URL (YouTube/Instagram): " url
    echo ""
    
    echo -e "${BLUE}Select Quality:${NC}"
    echo "1. Best Quality"
    echo "2. 1080p"
    echo "3. 720p"
    echo "4. 480p"
    echo "5. Audio Only (MP3)"
    read -p "Choice [1-5]: " quality
    
    case $quality in
        1) format="best" ;;
        2) format="best[height<=1080]" ;;
        3) format="best[height<=720]" ;;
        4) format="best[height<=480]" ;;
        5) format="bestaudio" ;;
        *) format="best" ;;
    esac
    
    echo -e "${GREEN}Downloading...${NC}"
    
    # YouTube download
    if [[ $url == *"youtube.com"* ]] || [[ $url == *"youtu.be"* ]]; then
        if [ "$format" == "bestaudio" ]; then
            yt-dlp -f bestaudio --extract-audio --audio-format mp3 -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
        else
            yt-dlp -f "$format" -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
        fi
    
    # Instagram download
    elif [[ $url == *"instagram.com"* ]]; then
        if [ "$format" == "bestaudio" ]; then
            echo -e "${YELLOW}Audio only not supported for Instagram${NC}"
            sleep 2
            return
        else
            yt-dlp -f best -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
        fi
    else
        echo -e "${RED}Unsupported URL!${NC}"
        sleep 2
        return
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Download complete!${NC}"
    else
        echo -e "${RED}❌ Download failed!${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# Batch download from file
batch_download() {
    show_banner
    echo -e "${YELLOW}📋 Batch Download${NC}"
    echo "------------------------"
    
    echo "Create a text file with URLs (one per line)"
    read -p "Enter file path: " filepath
    
    if [ ! -f "$filepath" ]; then
        echo -e "${RED}File not found!${NC}"
        sleep 2
        return
    fi
    
    echo -e "${GREEN}Processing batch download...${NC}"
    
    while IFS= read -r url; do
        if [ ! -z "$url" ]; then
            echo -e "${BLUE}Downloading: $url${NC}"
            yt-dlp -f best -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
        fi
    done < "$filepath"
    
    echo -e "${GREEN}✅ Batch download complete!${NC}"
    read -p "Press Enter to continue..."
}

# Convert video format
convert_format() {
    show_banner
    echo -e "${YELLOW}🔄 Convert Format${NC}"
    echo "------------------------"
    
    # List downloaded videos
    echo "Available videos:"
    ls -1 "$DOWNLOAD_DIR"/*.{mp4,mkv,webm,mp3} 2>/dev/null | nl
    
    echo ""
    read -p "Enter file number to convert: " filenum
    
    file=$(ls -1 "$DOWNLOAD_DIR"/*.{mp4,mkv,webm,mp3} 2>/dev/null | sed -n "${filenum}p")
    
    if [ -z "$file" ]; then
        echo -e "${RED}Invalid selection!${NC}"
        sleep 2
        return
    fi
    
    echo -e "${BLUE}Select output format:${NC}"
    echo "1. MP4"
    echo "2. MKV"
    echo "3. AVI"
    echo "4. MP3 (Audio only)"
    read -p "Choice: " fmt_choice
    
    filename=$(basename "$file")
    name="${filename%.*}"
    
    case $fmt_choice in
        1) output="$DOWNLOAD_DIR/$name.mp4"
           ffmpeg -i "$file" -c copy "$output" ;;
        2) output="$DOWNLOAD_DIR/$name.mkv"
           ffmpeg -i "$file" -c copy "$output" ;;
        3) output="$DOWNLOAD_DIR/$name.avi"
           ffmpeg -i "$file" "$output" ;;
        4) output="$DOWNLOAD_DIR/$name.mp3"
           ffmpeg -i "$file" -q:a 0 -map a "$output" ;;
        *) echo -e "${RED}Invalid!${NC}"; return ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Conversion complete!${NC}"
    else
        echo -e "${RED}❌ Conversion failed!${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# Settings menu
settings_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}⚙️ Settings${NC}"
        echo "------------------------"
        echo "1. Default Quality"
        echo "2. Download Location"
        echo "3. Show Current Settings"
        echo "4. Back to Main Menu"
        read -p "Choice: " set_choice
        
        case $set_choice in
            1) change_quality ;;
            2) change_location ;;
            3) show_settings ;;
            4) break ;;
            *) echo "Invalid!"; sleep 1 ;;
        esac
    done
}

# Change quality
change_quality() {
    echo -e "${BLUE}Select default quality:${NC}"
    echo "1. Best"
    echo "2. 1080p"
    echo "3. 720p"
    read -p "Choice: " q
    
    case $q in
        1) sed -i 's/QUALITY=.*/QUALITY=best/' "$CONFIG_FILE" ;;
        2) sed -i 's/QUALITY=.*/QUALITY=1080p/' "$CONFIG_FILE" ;;
        3) sed -i 's/QUALITY=.*/QUALITY=720p/' "$CONFIG_FILE" ;;
    esac
    echo -e "${GREEN}Settings updated!${NC}"
    sleep 2
}

# Change download location
change_location() {
    read -p "Enter new download path: " newpath
    mkdir -p "$newpath"
    sed -i "s|DOWNLOAD_PATH=.*|DOWNLOAD_PATH=$newpath|" "$CONFIG_FILE"
    DOWNLOAD_DIR="$newpath"
    echo -e "${GREEN}Location updated!${NC}"
    sleep 2
}

# Show settings
show_settings() {
    echo -e "${YELLOW}Current Settings:${NC}"
    cat "$CONFIG_FILE"
    read -p "Press Enter to continue..."
}

# View downloads
view_downloads() {
    show_banner
    echo -e "${YELLOW}📁 Downloaded Files${NC}"
    echo "------------------------"
    
    if [ -d "$DOWNLOAD_DIR" ] && [ "$(ls -A $DOWNLOAD_DIR)" ]; then
        ls -lh "$DOWNLOAD_DIR" | awk '{print $9 " (" $5 ")"}'
    else
        echo "No downloads yet!"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Check dependencies
check_dependencies() {
    deps=("yt-dlp" "ffmpeg")
    
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "${YELLOW}Installing $dep...${NC}"
            pkg install $dep -y
        fi
    done
}

# Start script
check_dependencies
main_menu
