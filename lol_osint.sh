#!/bin/bash

# LOL: Ultimate OSINT & Network Reconnaissance Tool
# Potency Edition // Extreme Reconnaissance Platform

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 1. LOAD MODULES
source "${SCRIPT_DIR}/modules/core.sh"
source "${SCRIPT_DIR}/modules/network.sh"
source "${SCRIPT_DIR}/modules/web.sh"
source "${SCRIPT_DIR}/modules/warfare.sh"
source "${SCRIPT_DIR}/modules/gui.sh"

# 2. LOGGING & POST-EXTRACTION WRAPPER
if [ -z "$1" ]; then
    grim_gui
fi

if [ "$1" != "--no-log" ]; then
    TARGET_CLEAN=$(echo "$1" | tr -dc '[:alnum:]_.-')
    if [ -z "$TARGET_CLEAN" ] || [ "$1" == "help" ] || [ "$1" == "man" ]; then
        TARGET="help"
    else
        LOGFILE="${SCRIPT_DIR}/lol_report_${TARGET_CLEAN}.txt"
        JSON_REPORT="${SCRIPT_DIR}/lol_intel_${TARGET_CLEAN}.json"
        HTML_DASHBOARD="${SCRIPT_DIR}/lol_dashboard_${TARGET_CLEAN}.html"
        AI_REPORT="${SCRIPT_DIR}/lol_dashboard_${TARGET_CLEAN}_ai.json"
        
        echo -e "${NEON_BLUE}[+] Session active: Logging to $LOGFILE${RESET}"
        bash "$0" --no-log "$@" 2>&1 | tee >(sed -r 's/\x1b\[[0-9;]*m//g' > "$LOGFILE")
        
        # Post-session AI strategic analysis
        if [ -d "$HOME/.lol_ai_profile" ]; then
            python3 "${SCRIPT_DIR}/modules/ai_engine.py" --analyze "$LOGFILE" "$AI_REPORT"
        fi

        # Post-session automated intelligence extraction via Python module
        python3 "${SCRIPT_DIR}/modules/dashboard.py" "$LOGFILE" "$JSON_REPORT" "$HTML_DASHBOARD"
        
        exit $?
    fi
fi

if [ "$1" == "--no-log" ]; then
    shift
fi

# 3. GLOBAL TRAPS
trap 'cleanup_on_exit EXIT' EXIT
trap 'exit 0' SIGINT SIGTERM

# 4. PARSE FLAGS
USE_TOR=false
STEALTH_DELAY=0

while [[ "$1" =~ ^- ]]; do
    case "$1" in
        --tor) USE_TOR=true; shift ;;
        --stealth) STEALTH_DELAY=2; shift ;;
        *) echo "Unknown flag: $1"; shift ;;
    esac
done

TARGET=$1
EXTRA=$2

if [ -z "$TARGET" ] || [ "$TARGET" == "help" ]; then
    show_banner
    echo -e "${NEON_BLUE}POTENCY COMMAND CENTER - USAGE GUIDE${RESET}"
    echo -e "Usage: lol [flags] <mode> <target> [extra]"
    echo -e ""
    echo -e "ULTIMATE MODES:"
    echo -e "  auto, remote, js, history, exploit, flood, arp, handshake, evil_twin"
    echo -e "STANDARD MODES:"
    echo -e "  recon, scan, web, vuln, phone, email, user, net, sniff, kill, mac"
    exit 0
fi

# 5. TYPE PARSING
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
elif [[ "$TARGET" == "set_iface" ]]; then TYPE="SET_IFACE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "wraith" ]]; then TYPE="WRAITH"; TARGET=$EXTRA;
elif [[ "$TARGET" == "havoc" ]]; then TYPE="HAVOC"; TARGET=$EXTRA;
elif [[ "$TARGET" == "blackgate" ]]; then TYPE="BLACKGATE"; TARGET=$EXTRA;
elif [[ "$TARGET" == "breacher" ]]; then TYPE="BREACHER"; TARGET=$EXTRA;
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
elif [[ "$TARGET" == "internal" ]]; then TYPE="INTERNAL"; TARGET=$EXTRA;
elif [[ "$TARGET" == "direct" ]]; then TYPE="DIRECT"; TARGET=$EXTRA;
elif [[ "$TARGET" == "shares" ]]; then TYPE="SHARES"; TARGET=$EXTRA;
elif [[ "$TARGET" == "wpad" ]]; then TYPE="WPAD"; TARGET=$EXTRA;
elif [[ "$TARGET" == "protocol" ]]; then TYPE="PROTOCOL"; TARGET=$EXTRA;
elif [[ "$TARGET" == "vlan" ]]; then TYPE="VLAN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "snmp" ]]; then TYPE="SNMP"; TARGET=$EXTRA;
elif [[ "$TARGET" == "yara" ]]; then TYPE="YARA"; TARGET=$EXTRA;
elif [[ "$TARGET" == "anti_forensics" ]]; then TYPE="ANTI_FORENSICS"; TARGET=$EXTRA;
elif [[ "$TARGET" == "c2_listener" ]]; then TYPE="C2_LISTENER"; TARGET=$EXTRA;
elif [[ "$TARGET" == "dns_hijack" ]]; then TYPE="DNS_HIJACK"; TARGET=$EXTRA;
elif [[ "$TARGET" == "net" ]]; then TYPE="NET";
elif [[ "$TARGET" == "sniff" ]]; then TYPE="SNIFF";
elif [[ "$TARGET" == "kill" ]]; then TYPE="KILL";
elif [[ "$TARGET" == "mac" ]]; then TYPE="MAC";
elif [[ "$TARGET" == "recon" ]]; then TYPE="RECON"; TARGET=$EXTRA;
fi

# 6. CORE EXECUTION CASE
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
    IP) api_intel "$TARGET"; rust_scan "$TARGET" ;;
    DOMAIN) api_intel "$TARGET"; sub_discover "$TARGET" ;;
    CMS) detect_cms "$TARGET" ;;
    EMAIL) email_osint "$TARGET" ;;
    PHONE) phone_osint "$TARGET" ;;
    DEAUTH) wifi_deauth "$TARGET" ;;
    HANDSHAKE) wifi_handshake ;;
    EVIL_TWIN) evil_twin_start ;;
    BT) bt_recon ;;
    SET_IFACE) set_wifi_iface ;;
    WRAITH) wraith_shells ;;
    HAVOC) havoc_brute "$TARGET" ;;
    BLACKGATE) blackgate_webshells ;;
    BREACHER) breacher_ad ;;
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
    INTERNAL) internal_enum "$TARGET" ;;
    DIRECT) direct_link_disco ;;
    SHARES) share_hunter "$TARGET" ;;
    WPAD) wpad_audit ;;
    PROTOCOL) protocol_audit ;;
    VLAN) vlan_hop_recon ;;
    SNMP) snmp_map "$TARGET" ;;
    YARA) yara_scan "$TARGET" ;;
    ANTI_FORENSICS) anti_forensics ;;
    C2_LISTENER) c2_listener ;;
    DNS_HIJACK) dns_hijack ;;
    CLOUD) cloud_recon "$TARGET" ;;
    FILE) exiftool "$TARGET" | grep -v "Directory" ;;
    NET) sudo arp-scan --interface=$(get_main_iface) --localnet --retry=5 --ignoredups ;;
    SNIFF) sudo bettercap -eval "net.probe on; net.sniff on" ;;
    KILL) echo -ne "Target IP: "; read t; sudo bettercap -eval "set arp.spoof.targets $t; arp.spoof on; net.sniff on" ;;
    MAC) ghost_mode ;;
    RECON) api_intel "$TARGET"; vuln_scan "$TARGET" ;;
esac

echo -e "\n${NEON_BLUE}========================================================${RESET}"
