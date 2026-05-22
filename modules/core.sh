#!/bin/bash

# LOL Core Module - Colors, Helpers, and UI

# NEON COLORS
NEON_BLUE='\e[1;34m'
NEON_PINK='\e[1;35m'
NEON_GREEN='\e[1;32m'
RESET='\e[0m'

req() {
    curl -s -L -A "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" "$1"
}

loading_anim() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

ghost_insertion() {
    local INTERFACE=$1
    echo -e "${NEON_BLUE}[*] GHOST INSERTION: Masking $INTERFACE...${RESET}"
    sudo ip link set dev $INTERFACE down
    sudo macchanger -r $INTERFACE | grep "New MAC"
    sudo ip link set dev $INTERFACE up
    echo -e "${NEON_GREEN}[+] GHOST ACTIVE${RESET}"
}

ghost_restore() {
    local INTERFACE=$1
    echo -e "${NEON_BLUE}[*] GHOST EXIT: Restoring $INTERFACE...${RESET}"
    sudo ip link set dev $INTERFACE down
    sudo macchanger -p $INTERFACE | grep "Permanent MAC"
    sudo ip link set dev $INTERFACE up
    echo -e "${NEON_GREEN}[+] HARDWARE IDENTITY RESTORED${RESET}"
}

ghost_mode() {
    INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}' 2>/dev/null || echo "eth0")
    ghost_insertion $INTERFACE
}

discord_notify() {
    local MSG=$1
    if [ ! -z "$DISCORD_WEBHOOK" ]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MSG\"}" $DISCORD_WEBHOOK > /dev/null 2>&1
    fi
}

show_banner() {
    clear
    echo -e "${NEON_PINK}"
    echo -e "      .                                                      .        "
    echo -e "        .n.                     .                 .         .n.       "
    echo -e "  .   .dP                  .nP                 .dP.       dP    .     "
    echo -e " dP  dP                 .dP                   dP  dP     dP           "
    echo -e " dP dP         aaaaaa    dP        aaaaaa    dP  dP     dP            "
    echo -e " dP dP      .d88888b.    dP      .d88888b.    dP  dP     dP           "
    echo -e " dP dP     d88P  Y88b    dP     d88P  Y88b    dP  dP     dP           "
    echo -e " dP dP     888    888    dP     888    888    dP  dP     dP           "
    echo -e " dP dP     888    888    dP     888    888    dP  dP     dP           "
    echo -e " dP dP     Y88b  d88P    dP     Y88b  d88P    dP  dP     dP           "
    echo -e " dP  dP.    \"Y88888P\"    dP.     \"Y88888P\"     dP  dP.    dP          "
    echo -e "  '   '\"     \"\"\"\"\"\"\"      '\"     \"\"\"\"\"\"\"        '   '\"     '          "
    echo -e "                        L   O   L"
    echo -e "                P O T E N C Y   E D I T I O N"
    echo -e " ____________________________________________________________________ "
    echo -e "${RESET}"
}

get_main_iface() {
    ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}' || echo "eth0"
}

cleanup_on_exit() {
    if [ -z "$1" ] || [ "$1" == "EXIT" ]; then
        local INTERFACE=$(get_main_iface)
        if [ ! -z "$INTERFACE" ]; then
            if [[ $(ip link show $INTERFACE | grep "PROMISC") ]] || [[ $(cat /proc/sys/net/ipv6/conf/$INTERFACE/disable_ipv6) -eq 1 ]]; then
                echo -e "\n${NEON_BLUE}[!] SESSION CLOSED. AUTO-RESTORING LINK...${RESET}"
                sudo ip link set dev $INTERFACE promisc off
                sudo sysctl -w net.ipv6.conf.$INTERFACE.disable_ipv6=0 > /dev/null
                sudo macchanger -p $INTERFACE > /dev/null 2>&1
                sudo ip link set dev $INTERFACE up
                sudo dhclient -nw $INTERFACE > /dev/null 2>&1
            fi
        fi
    fi
}
