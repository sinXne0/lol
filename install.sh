#!/bin/bash

# LOL: Ultimate Setup Script
# Automates the installation of dependencies for the LOL toolset.

NEON_BLUE='\e[1;34m'
NEON_PINK='\e[1;35m'
RESET='\e[0m'

echo -e "${NEON_BLUE}========================================================${RESET}"
echo -e "${NEON_BLUE}       LOL: ULTIMATE POTENCY INSTALLER${RESET}"
echo -e "${NEON_BLUE}========================================================${RESET}"

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo -e "${NEON_PINK}[!] This script must be run as root (use sudo).${RESET}"
   exit 1
fi

# 1. Detect OS
echo -e "${NEON_BLUE}[*] Detecting Operating System...${RESET}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${NEON_PINK}[!] Could not detect OS. Proceeding with Debian assumptions...${RESET}"
    OS="debian"
fi
echo -e "${NEON_BLUE}[+] Detected: $OS${RESET}"

# 2. System Dependencies
echo -e "${NEON_BLUE}[*] Updating system and installing binaries...${RESET}"
case $OS in
    kali|ubuntu|debian|raspbian)
        apt update
        apt install -y nmap bettercap macchanger arp-scan exiftool whois dig curl jq yara python3 python3-pip golang-go git
        ;;
    arch)
        pacman -Sy --noconfirm nmap bettercap macchanger arp-scan exiftool whois bind curl jq yara python python-pip go git
        ;;
    fedora)
        dnf install -y nmap bettercap macchanger arp-scan perl-Image-ExifTool whois bind-utils curl jq yara python3 python3-pip golang git
        ;;
    *)
        echo -e "${NEON_PINK}[!] Unsupported OS for automated binary installation.${RESET}"
        echo -e "${NEON_PINK}[!] Please install dependencies manually: nmap, bettercap, macchanger, arp-scan, exiftool, whois, dig, curl, jq, yara, python3, golang.${RESET}"
        ;;
esac

# 3. Python Dependencies
echo -e "${NEON_BLUE}[*] Installing Python libraries...${RESET}"
pip3 install --upgrade pip
pip3 install cloudscraper beautifulsoup4 holehe sherlock-project --break-system-packages 2>/dev/null || pip3 install cloudscraper beautifulsoup4 holehe sherlock-project

# 4. Config Setup
CONFIG_FILE="$HOME/.lol_config"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${NEON_BLUE}[*] Creating initial config at $CONFIG_FILE...${RESET}"
    cat <<EOF > "$CONFIG_FILE"
SHODAN_API_KEY=""
HIBP_API_KEY=""
DISCORD_WEBHOOK=""
EOF
    # If run as sudo, $HOME might be /root. Let's ensure the actual user gets a copy if possible.
    if [ ! -z "$SUDO_USER" ]; then
        USER_HOME=$(eval echo "~$SUDO_USER")
        cp "$CONFIG_FILE" "$USER_HOME/.lol_config"
        chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.lol_config"
    fi
fi

# 5. Permissions
echo -e "${NEON_BLUE}[*] Setting permissions...${RESET}"
chmod +x lol_osint.sh lol-dist.sh
ln -sf "$(pwd)/lol_osint.sh" /usr/local/bin/lol 2>/dev/null || echo -e "${NEON_PINK}[!] Failed to create symlink at /usr/local/bin/lol. You can run it locally with ./lol_osint.sh${RESET}"

echo -e "${NEON_BLUE}========================================================${RESET}"
echo -e "${NEON_BLUE}         INSTALLATION COMPLETE${RESET}"
echo -e "${NEON_BLUE}  Type 'lol' to launch the Command Center${RESET}"
echo -e "${NEON_BLUE}========================================================${RESET}"
