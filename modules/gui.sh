#!/bin/bash

# LOL GUI & Interactive Command Center

grim_gui() {
    INTERFACE=$(get_main_iface)
    LOCAL_IP=$(ip addr show $INTERFACE | grep "inet " | awk '{print $2}' | cut -d/ -f1 2>/dev/null || echo "127.0.0.1")
    BLUR_IP=false

    while true; do
        DISPLAY_IP=$LOCAL_IP
        if [ "$BLUR_IP" = true ]; then DISPLAY_IP="[ HIDDEN ]"; fi
        STEALTH_STATUS="${NEON_PINK}DISABLED${RESET}"; if [ "$USE_TOR" = true ]; then STEALTH_STATUS="${NEON_BLUE}ACTIVE (TOR)${RESET}"; fi
        HOST_NOW=$(hostname)

        show_banner
        echo -e " ${NEON_BLUE}┌─────────────────────── SYSTEM STATUS ────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET}  ${NEON_BLUE}IP:${RESET} $DISPLAY_IP  ${NEON_BLUE}STEALTH:${RESET} $STEALTH_STATUS  ${NEON_BLUE}ID:${RESET} $HOST_NOW ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└──────────────────────────────────────────────────────────────┘${RESET}"
        echo -e ""
        echo -e " ${NEON_BLUE}    [1] WEB & INFRASTRUCTURE INTEL${RESET}"
        echo -e " ${NEON_BLUE}    [2] DEEP SEARCH & OSINT HUB${RESET}"
        echo -e " ${NEON_BLUE}    [3] CYBER WARFARE OPERATIONS${RESET}"
        echo -e " ${NEON_BLUE}    [4] ETHERNET & INTERNAL OPS${RESET}"
        echo -e " ${NEON_BLUE}    [5] SIGNAL INTELLIGENCE (SIGINT)${RESET}"
        echo -e " ${NEON_BLUE}    [6] SYSTEM & ANTI-FORENSICS${RESET}"
        echo -e " ${NEON_BLUE}    [0] EXIT TO SHADOWS${RESET}"
        echo -e ""
        echo -e -n " ${NEON_PINK}lol@potency:${RESET} "; read opt

        case $opt in
            1) gui_web_intel ;;
            2) gui_deep_search ;;
            3) gui_warfare ;;
            4) gui_ethernet ;;
            5) gui_sigint ;;
            6) gui_iot ;; # Reusing IoT slot for system/iot
            0) exit 0 ;;
        esac
    done
}

gui_ethernet() {
    show_banner
    echo -e " ${NEON_BLUE}[ ETHERNET & INTERNAL OPERATIONS ]${RESET}"
    echo -e " [1] Discover Direct Links"
    echo -e " [2] Share Hunter"
    echo -e " [3] NTLM Poisoning (Responder)"
    echo -e " [4] VLAN Hopping Recon"
    echo -e " [0] BACK"
    read -p " > " opt
    case $opt in
        1) direct_link_disco ;;
        2) read -p "Target: " t; share_hunter $t ;;
        3) ntlm_poison ;;
        4) vlan_hop_recon ;;
    esac
}

gui_web_intel() {
    show_banner
    echo -e " ${NEON_BLUE}[ WEB & INFRASTRUCTURE INTEL ]${RESET}"
    echo -e " [1] Auto-Pilot Recon"
    echo -e " [2] Subdomain Discovery"
    echo -e " [3] Rapid Port Scan (Rustscan)"
    echo -e " [4] JS Secret Hunter"
    echo -e " [0] BACK"
    read -p " > " opt
    case $opt in
        1) read -p "Target: " t; api_intel $t; sub_discover $t; rust_scan $t ;;
        2) read -p "Target: " t; sub_discover $t ;;
        3) read -p "Target: " t; rust_scan $t ;;
        4) read -p "Target: " t; js_intel $t ;;
    esac
}

gui_deep_search() {
    show_banner
    echo -e " ${NEON_BLUE}[ DEEP SEARCH & OSINT HUB ]${RESET}"
    echo -e " [1] Employee/Identity Recon"
    echo -e " [2] Breach Search"
    echo -e " [3] GitHub Dorking"
    echo -e " [4] Username Trace (Sherlock)"
    echo -e " [0] BACK"
    read -p " > " opt
}

gui_iot() {
    show_banner
    echo -e " ${NEON_BLUE}[ SYSTEM & IOT ]${RESET}"
    echo -e " [1] Bluetooth Recon"
    echo -e " [2] Anti-Forensics"
    echo -e " [3] Ghost Mode (MAC Randomizer)"
    echo -e " [0] BACK"
    read -p " > " opt
    case $opt in
        1) bt_recon ;;
        2) anti_forensics ;;
        3) ghost_mode ;;
    esac
}

gui_sigint() {
    show_banner
    echo -e " ${NEON_BLUE}[ SIGNAL INTELLIGENCE ]${RESET}"
    echo -e " [1] Handshake Capture"
    echo -e " [2] Evil Twin Setup"
    echo -e " [3] Wi-Fi Deauth"
    echo -e " [0] BACK"
}

gui_warfare() {
    show_banner
    echo -e " ${NEON_BLUE}[ CYBER WARFARE ]${RESET}"
    echo -e " [1] Wraith (Reverse Shells)"
    echo -e " [2] Havoc (Brute-force)"
    echo -e " [3] Blackgate (Webshells)"
    echo -e " [4] C2 Listener"
    echo -e " [0] BACK"
}
