#!/bin/bash

# --- NEON AESTHETIC ---
NEON_BLUE='\e[1;34m'
NEON_PINK='\e[1;35m'
RESET='\e[0m'

TARGET=$1
EXTRA=$2

if [ -z "$TARGET" ] || [ "$TARGET" == "help" ] || [ "$TARGET" == "man" ]; then
    echo -e "${NEON_PINK}Usage: lol <target> [extra]${RESET}"
    echo -e "${NEON_BLUE}Example:${RESET} lol google.com  |  lol 192.168.1.1  |  lol 555-0199  |  lol user123"
    echo -e "${NEON_BLUE}--------------------------------------------------------${RESET}"
    echo -e "${NEON_BLUE}OSINT MODES:${RESET}"
    echo -e "  <Phone>   - Scrape identity, social media, and carrier data."
    echo -e "  <Email>   - Check registrations (120+ sites) and leak dorks."
    echo -e "  <User>    - Run Sherlock across social media and name dorks."
    echo -e "  <Domain>  - WAF detection, security audit, WHOIS, DNS, Subdomains."
    echo -e "  <IP>      - Geo-IP, HTTP Audit, and service scan."
    echo -e "  file      - Extract EXIF metadata (local path or remote URL)."
    echo -e "  scan      - Deep OSINT extractor (Emails, Onions, Wallets, Telegram)."
    echo -e "  cloud     - Enumerate S3, Azure, and GCP buckets for a keyword."
    echo -e "${NEON_BLUE}RECON & WEB MODES:${RESET}"
    echo -e "  recon     - Ultimate Domain/IP recon (Deep Nmap + OS + Scripts)."
    echo -e "  web       - Directory & API brute-forcing / sensitive file hunt."
    echo -e "  vuln      - Deep vulnerability scan (Nmap Vuln Scripts)."
    echo -e "  net       - Discover live hosts and open ports on local subnet."
    echo -e "${NEON_BLUE}SECURITY MODES:${RESET}"
    echo -e "  yara      - Scan a file or directory with local YARA rules."
    echo -e "${NEON_BLUE}NETWORK MODES:${RESET}"
    echo -e "  sniff     - Start live network monitor with ARP spoofing."
    echo -e "  kill <IP> - Cut internet for a specific device on the network."
    echo -e "  mac       - Randomize your hardware MAC address."
    echo -e "  spoof     - Open the comprehensive spoofing guide."
    exit 0
fi

clear
echo -e "${NEON_BLUE}========================================================${RESET}"
echo -e "${NEON_BLUE}      ULTIMATE OSINT & NETWORK RECON: $TARGET ${RESET}"
echo -e "${NEON_BLUE}========================================================${RESET}"

# Detect Input Type
if [[ "$TARGET" == "net" ]]; then TYPE="NET";
elif [[ "$TARGET" == "sniff" ]]; then TYPE="SNIFF";
elif [[ "$TARGET" == "kill" ]]; then TYPE="KILL";
elif [[ "$TARGET" == "mac" ]]; then TYPE="MAC";
elif [[ "$TARGET" == "spoof" ]]; then TYPE="SPOOF";
elif [[ "$TARGET" == "recon" ]]; then TYPE="RECON"; TARGET=$EXTRA;
elif [[ "$TARGET" == "web" ]]; then TYPE="WEB"; TARGET=$EXTRA;
elif [[ "$TARGET" == "scan" ]]; then TYPE="SCAN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "cloud" ]]; then TYPE="CLOUD"; TARGET=$EXTRA;
elif [[ "$TARGET" == "vuln" ]]; then TYPE="VULN"; TARGET=$EXTRA;
elif [[ "$TARGET" == "yara" ]]; then TYPE="YARA"; TARGET=$EXTRA;
elif [[ "$TARGET" =~ ^http || -f "$TARGET" ]]; then TYPE="FILE";
elif [[ "$TARGET" =~ ^[0-9\+\(\)\ -]{7,20}$ ]]; then TYPE="PHONE";
elif [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then TYPE="IP";
elif [[ "$TARGET" =~ @ ]]; then TYPE="EMAIL";
elif [[ "$TARGET" =~ \. ]]; then TYPE="DOMAIN";
else TYPE="USER"; fi

echo -e "${NEON_BLUE}[+] Mode: $TYPE${RESET}\n"

# Internal OSINT Extractor (DarkIntel Patterns)
extract_observables() {
    python3 - "$1" <<EOF
import re, sys, requests
content = ""
target = sys.argv[1]
if target.startswith("http"):
    try: content = requests.get(target, timeout=10, headers={'User-Agent': 'Mozilla/5.0'}).text
    except: print(f"[-] Failed to fetch URL: {target}"); sys.exit(1)
elif sys.stdin.isatty():
    try: content = open(target, 'r').read()
    except: print(f"[-] Failed to read file: {target}"); sys.exit(1)
else: content = sys.stdin.read()

patterns = [
    ("Email", r"[\w.+-]+@[\w.-]+\.\w+"),
    ("Onion", r"\b[a-z2-7]{56}\.onion\b"),
    ("Telegram", r"(?:https?://t\.me/|@)([A-Za-z0-9_]{5,32})"),
    ("Bitcoin", r"\b(?:bc1[a-z0-9]{25,87}|[13][a-km-zA-HJ-NP-Z1-9]{25,34})\b"),
    ("IPv4", r"\b(?:\d{1,3}\.){3}\d{1,3}\b"),
    ("Domain", r"\b(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}\b"),
]

found = False
for label, pattern in patterns:
    matches = sorted(list(set(re.findall(pattern, content))))
    if matches:
        found = True
        print(f"${NEON_BLUE}[*] {label}s Found:${RESET}")
        for m in matches: print(f"  -> {m}")
if not found: print("[-] No observables extracted.")
EOF
}

# Internal Directory Brute-forcer
brute_web() {
    local url=$1
    [[ ! $url =~ ^http ]] && url="http://$url"
    echo -e "${NEON_BLUE}[*] Starting Directory & API Brute-force on $url...${RESET}"
    check_waf "$url"
    
    local wordlist="${WORDLIST_PATH:-./wordlists/common.txt}"
    local api_list="${API_LIST_PATH:-./wordlists/api_endpoints.txt}"
    
    echo -e "\n${NEON_BLUE}[1/2] Checking Common Directories & Files...${RESET}"
    for path in ".env" ".git/config" "config.php" "wp-config.php" "admin/" "backup.sql" ".ssh/id_rsa" "robots.txt"; do
        code=$(curl -s -o /dev/null -w "%{http_code}" -L "$url/$path" --max-time 2)
        if [[ "$code" == "200" ]]; then echo -e "  ${NEON_BLUE}[+]${RESET} Found: /$path (HTTP $code)"; fi
    done

    echo -e "\n${NEON_BLUE}[2/2] Brute-forcing with Wordlist (Top 50)...${RESET}"
    head -n 50 "$wordlist" | while read -r line; do
        code=$(curl -s -o /dev/null -w "%{http_code}" -L "$url/$line" --max-time 1)
        if [[ "$code" == "200" ]]; then echo -e "  ${NEON_BLUE}[+]${RESET} /$line (HTTP $code)"; fi
    done
}

# Internal WAF Detection Function
check_waf() {
    echo -e "${NEON_BLUE}[*] [WAF] Checking for Web Application Firewall...${RESET}"
    local HEADERS=$(curl -I -s -L "$1" | tr '[:upper:]' '[:lower:]')
    if echo "$HEADERS" | grep -q "cloudflare"; then echo "  -> Detected: Cloudflare";
    elif echo "$HEADERS" | grep -q "incapsula"; then echo "  -> Detected: Imperva Incapsula";
    elif echo "$HEADERS" | grep -q "akamai"; then echo "  -> Detected: Akamai";
    elif echo "$HEADERS" | grep -q "sucuri"; then echo "  -> Detected: Sucuri";
    elif echo "$HEADERS" | grep -q "barracuda"; then echo "  -> Detected: Barracuda";
    elif echo "$HEADERS" | grep -q "f5"; then echo "  -> Detected: F5 BIG-IP";
    else echo "  -> No obvious WAF signatures found."; fi
}

# Internal Security Header Audit
check_headers() {
    echo -e "\n${NEON_BLUE}[*] [AUDIT] Security Header Check...${RESET}"
    local HEADERS=$(curl -I -s -L "$1")
    for header in "Strict-Transport-Security" "Content-Security-Policy" "X-Frame-Options" "X-Content-Type-Options" "Referrer-Policy" "Permissions-Policy"; do
        if echo "$HEADERS" | grep -qi "$header"; then echo -e "  ${NEON_BLUE}[+]${RESET} $header: Found";
        else echo -e "  ${NEON_PINK}[-]${RESET} $header: MISSING"; fi
    done
}

# Internal Python function for FastPeopleSearch
fast_people_search() {
    python3 - <<EOF
import cloudscraper
from bs4 import BeautifulSoup
import re
import sys

def search(phone):
    clean_phone = re.sub(r'\D', '', phone)
    if len(clean_phone) == 10:
        formatted_phone = f"{clean_phone[0:3]}-{clean_phone[3:6]}-{clean_phone[6:10]}"
    else:
        formatted_phone = phone

    url = f"https://www.fastpeoplesearch.com/{formatted_phone}"
    scraper = cloudscraper.create_scraper(browser={'browser': 'chrome', 'platform': 'windows', 'desktop': True})
    
    try:
        response = scraper.get(url, timeout=15)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            person_div = soup.find('div', class_=re.compile("card|col-sm-12"))
            if not person_div: return "[-] Record not found (or Cloudflare challenge active)."
            results = []
            name = soup.find('h1') or soup.find('h2')
            if name: results.append(f"NAME: {name.text.strip()}")
            age = soup.find('span', class_='age')
            if age: results.append(f"AGE: {age.text.strip()}")
            address = soup.find('a', title=re.compile("Search for addresses in"))
            if address: results.append(f"ADDRESS: {address.text.strip()}")
            relatives = soup.find('h3', string=re.compile("Possible Relatives"))
            if relatives:
                rel_p = relatives.find_next('p')
                if rel_p: results.append(f"RELATIVES: {rel_p.text.strip()}")
            return "\n".join(results) if results else "[-] Data parsing failed."
        return f"[-] Error {response.status_code}"
    except Exception as e: return f"[-] Connection Error: {str(e)}"

print(search("$1"))
EOF
}

# Internal Python function for Sherlock
sherlock_search() {
    python3 - "$1" <<EOF
import sys
from sherlock_project.sherlock import main
if __name__ == '__main__':
    # Mock sys.argv for sherlock's main()
    sys.argv = ['sherlock', sys.argv[1], '--timeout', '10', '--print-found']
    try:
        main()
    except SystemExit:
        pass
EOF
}

case $TYPE in
    RECON)
        echo -e "${NEON_PINK}[!] LAUNCHING FULL RECONNAISSANCE ON: $TARGET${RESET}"
        echo -e "${NEON_BLUE}[*] This combines multiple modules and may take a moment...${RESET}"
        # Determine if Target is Domain or IP
        if [[ "$TARGET" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            # IP Recon
            echo -e "\n${NEON_BLUE}--- IP RECON MODULE ---${RESET}"
            curl -s "https://ipinfo.io/$TARGET" | grep -v 'readme' | sed 's/[",]//g'
            echo -e "\n${NEON_BLUE}[*] Running Deep Port Scan (Nmap Top 1000 + OS + Scripts)...${RESET}"
            sudo nmap -sC -sV -O -T4 -Pn "$TARGET"
        else
            # Domain Recon
            echo -e "\n${NEON_BLUE}--- DOMAIN RECON MODULE ---${RESET}"
            check_waf "http://$TARGET"
            check_headers "http://$TARGET"
            echo -e "\n${NEON_BLUE}[*] Fetching DNS and Subdomains...${RESET}"
            dig +short A "$TARGET" | sed 's/^/  [A] /'
            curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | jq -r '.[].name_value' | sed 's/\\*\\.//g' | sort -u | grep -i "$TARGET" | head -n 10
            echo -e "\n${NEON_BLUE}[*] Running Service Discovery (Nmap Fast)...${RESET}"
            nmap -sV -F -T4 -Pn "$TARGET"
        fi
        ;;

    FILE)
        if [[ "$TARGET" =~ ^http ]]; then
            echo -e "${NEON_BLUE}[*] Analyzing Remote URL: $TARGET${RESET}"
            check_waf "$TARGET"
            check_headers "$TARGET"
            echo -e "\n${NEON_BLUE}[*] Extracting Metadata (Curl-Exif)...${RESET}"
            curl -s -L "$TARGET" > /tmp/lol_tmp_file
            exiftool /tmp/lol_tmp_file | grep -v "Directory|File Name|File Permissions"
            rm /tmp/lol_tmp_file
        else
            echo -e "${NEON_BLUE}[*] Analyzing Local File: $TARGET${RESET}"
            exiftool "$TARGET" | grep -v "Directory|File Permissions"
        fi
        ;;

    KILL)
        if [ -z "$EXTRA" ]; then echo "Usage: lol kill <IP_ADDRESS>"; exit 1; fi
        echo -e "${NEON_PINK}[!] KILLING INTERNET FOR: $EXTRA${RESET}"
        echo -e "${NEON_BLUE}[*] Tricking device into dropping all packets...${RESET}"
        sudo bettercap -eval "set arp.spoof.targets $EXTRA; arp.spoof on; set net.sniff on; set net.sniff.verbose false; net.sniff on"
        ;;

    SNIFF)
        echo -e "${NEON_BLUE}[*] Starting Live Network Monitor...${RESET}"
        sudo bettercap -eval "net.probe on; set arp.spoof.targets 192.168.1.0/24; arp.spoof on; net.sniff on"
        ;;

    MAC)
        INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
        echo -e "${NEON_BLUE}[*] Spoofing MAC Address on $INTERFACE...${RESET}"
        sudo ip link set dev $INTERFACE down
        sudo macchanger -r $INTERFACE
        sudo ip link set dev $INTERFACE up
        echo -e "${NEON_BLUE}[+] Network Identity Changed.${RESET}"
        ;;

    SPOOF)
        echo -e "${NEON_BLUE}[*] --- SPOOFING HUB ---${RESET}"
        echo -e "\n${NEON_BLUE}[1] PHONE/CALLER ID SPOOFING:${RESET}"
        echo -e "Free caller ID spoofing is blocked by telecom companies (STIR/SHAKEN)."
        echo -e "To spoof calls, you must use a paid VOIP trunk or apps like:"
        echo -e " -> SpoofCard: https://www.spoofcard.com/"
        echo -e " -> MySudo: https://mysudo.com/"
        echo -e " -> Phoner: https://phonerapp.com/"
        
        echo -e "\n${NEON_BLUE}[2] GPS SPOOFING (Android/iOS):${RESET}"
        echo -e "GPS is calculated by satellites, not your router. To spoof it, you need an app on the phone."
        echo -e " -> Android: Download 'Fake GPS location' from Play Store. Enable 'Mock Locations' in Developer Options."
        echo -e " -> iOS: Use 3uTools or iToolab AnyGo via USB connection to PC."
        
        echo -e "\n${NEON_BLUE}[3] EMAIL SPOOFING:${RESET}"
        echo -e "Modern providers (Gmail, Outlook) block spoofed emails unless SPF/DKIM align."
        echo -e "Use temporary burner emails or services like:"
        echo -e " -> Emkei's Fake Mail: https://emkei.cz/"
        echo -e " -> Guerrilla Mail: https://guerrillamail.com/"
        ;;

    PHONE)
        CLEAN=$(echo "$TARGET" | sed 's/[^0-9]//g')
        echo -e "${NEON_BLUE}[*] [1/4] Technical Scan (PhoneInfoga)...${RESET}"
        phoneinfoga scan -n "$TARGET" | grep -E "Carrier|Location|Valid|Number"
        
        echo -e "\n${NEON_BLUE}[*] [2/4] Identity Scrape (FastPeopleSearch)...${RESET}"
        fast_people_search "$CLEAN"
        
        echo -e "\n${NEON_BLUE}[*] [3/4] Google Dorks (Web Presence)...${RESET}"
        echo " - Facebook: https://www.google.com/search?q=site:facebook.com+\"$CLEAN\""
        echo " - Instagram: https://www.google.com/search?q=site:instagram.com+\"$CLEAN\""
        echo " - General: https://www.google.com/search?q=\"$CLEAN\"+OR+\"$(echo $CLEAN | sed 's/\([0-9]\{3\}\)\([0-9]\{3\}\)\([0-9]\{4\}\)/(\1) \2-\3/')\""

        echo -e "\n${NEON_BLUE}[*] [4/4] Suggested Manual Checks...${RESET}"
        echo " - That's Them: https://thatsthem.com/phone/$(echo $CLEAN | sed 's/\([0-9]\{3\}\)\([0-9]\{3\}\)\([0-9]\{4\}\)/\1-\2-\3/')"
        echo " - BreachDirectory: https://breachdirectory.org/search?query=$CLEAN"
        echo " - IntelX: https://intelx.io/?s=$CLEAN"
        ;;
        
    EMAIL)
        echo -e "${NEON_BLUE}[*] [1/3] Registration Check (Holehe)...${RESET}"
        holehe "$TARGET" --only-used
        echo -e "\n${NEON_BLUE}[*] [2/3] Pastebin & Leak Dorking...${RESET}"
        echo " - Pastebin: https://www.google.com/search?q=site:pastebin.com+\"$TARGET\""
        echo " - LinkedIn: https://www.google.com/search?q=site:linkedin.com/in+\"$TARGET\""
        echo -e "\n${NEON_BLUE}[*] [3/3] Leak Databases (Manual Check)...${RESET}"
        echo " - Leak-Lookup: https://leak-lookup.com/search?query=$TARGET&type=email"
        echo " - Snusbase: https://snusbase.com/search/$TARGET"
        echo " - DeHashed: https://dehashed.com/search?query=$TARGET"
        ;;

    NET)
        INTERFACE=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
        SUBNET=$(ip -o -f inet addr show | grep -v '127.0.0.1' | awk '/scope global/ {print $4}' | head -n 1)
        echo -e "${NEON_BLUE}[*] [1/2] Live Hosts (ARP Sweep)...${RESET}"
        sudo arp-scan --interface=$INTERFACE --localnet
        echo -e "\n${NEON_BLUE}[*] [2/2] Quick Port Scan (Nmap Top 100) on $SUBNET...${RESET}"
        nmap -F -T4 "$SUBNET"
        ;;
        
    IP)
        echo -e "${NEON_BLUE}[*] [1/3] Geo-IP Information...${RESET}"
        curl -s "https://ipinfo.io/$TARGET" | grep -E -v 'readme' | sed 's/[",]//g'
        echo -e "\n${NEON_BLUE}[*] [2/3] WAF & Header Check (if HTTP)...${RESET}"
        check_waf "http://$TARGET"
        check_headers "http://$TARGET"
        echo -e "\n${NEON_BLUE}[*] [3/3] Service Scan (Nmap Fast)...${RESET}"
        nmap -sV -F -T4 -Pn "$TARGET"
        ;;
        
    DOMAIN)
        echo -e "${NEON_BLUE}[*] [1/4] WAF & Security Audit...${RESET}"
        check_waf "http://$TARGET"
        check_headers "http://$TARGET"
        echo -e "\n${NEON_BLUE}[*] [2/4] WHOIS Registration Info...${RESET}"
        whois "$TARGET" | grep -E -i "Registrant|Admin|Tech|Email|Phone|Name Server|Creation Date|Updated Date" | grep -v 'Please' | head -n 15
        echo -e "\n${NEON_BLUE}[*] [3/4] DNS Records (A, MX, TXT)...${RESET}"
        dig +short A "$TARGET" | sed 's/^/  [A] /'
        dig +short MX "$TARGET" | sed 's/^/  [MX] /'
        dig +short TXT "$TARGET" | sed 's/^/  [TXT] /'
        echo -e "\n${NEON_BLUE}[*] [4/4] Passive Subdomain Enum (crt.sh)...${RESET}"
        curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | jq -r '.[].name_value' | sed 's/\\*\\.//g' | sort -u | grep -i "$TARGET" | head -n 20 || echo "  -> No subdomains found or crt.sh timeout"
        ;;
        
    USER)
        echo -e "${NEON_BLUE}[*] [1/2] Sherlock Social Media Search...${RESET}"
        sherlock_search "$TARGET"
        echo -e "\n${NEON_BLUE}[*] [2/2] Name Dorking...${RESET}"
        echo " - Name Check: https://www.google.com/search?q=\"$TARGET\""
        ;;

    WEB)
        if [ -z "$TARGET" ]; then echo "Usage: lol web <Domain/IP>"; exit 1; fi
        brute_web "$TARGET"
        ;;

    SCAN)
        if [ -z "$TARGET" ]; then echo "Usage: lol scan <URL/File/Text>"; exit 1; fi
        echo -e "${NEON_PINK}[!] EXTRACTING OBSERVABLES FROM: $TARGET${RESET}"
        extract_observables "$TARGET"
        ;;

    CLOUD)
        if [ -z "$TARGET" ]; then echo "Usage: lol cloud <Keyword>"; exit 1; fi
        echo -e "${NEON_BLUE}[*] Searching for public cloud buckets using keyword: $TARGET${RESET}"
        echo -e "\n${NEON_BLUE}[1/3] AWS S3 Bucket...${RESET}"
        AWS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://${TARGET}.s3.amazonaws.com")
        if [[ "$AWS_CODE" == "200" || "$AWS_CODE" == "403" ]]; then echo -e "  ${NEON_BLUE}[+]${RESET} S3 Bucket Exists: https://${TARGET}.s3.amazonaws.com (HTTP $AWS_CODE)"; else echo "  ${NEON_PINK}[-]${RESET} Not found."; fi
        echo -e "\n${NEON_BLUE}[2/3] Azure Blob Storage...${RESET}"
        AZ_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://${TARGET}.blob.core.windows.net")
        if [[ "$AZ_CODE" != "404" && "$AZ_CODE" != "000" ]]; then echo -e "  ${NEON_BLUE}[+]${RESET} Azure Storage Exists: https://${TARGET}.blob.core.windows.net (HTTP $AZ_CODE)"; else echo "  ${NEON_PINK}[-]${RESET} Not found."; fi
        echo -e "\n${NEON_BLUE}[3/3] Google Cloud Storage...${RESET}"
        GCP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://storage.googleapis.com/${TARGET}")
        if [[ "$GCP_CODE" == "200" || "$GCP_CODE" == "403" ]]; then echo -e "  ${NEON_BLUE}[+]${RESET} GCP Bucket Exists: https://storage.googleapis.com/${TARGET} (HTTP $GCP_CODE)"; else echo "  ${NEON_PINK}[-]${RESET} Not found."; fi
        ;;

    VULN)
        if [ -z "$TARGET" ]; then echo "Usage: lol vuln <Domain/IP>"; exit 1; fi
        echo -e "${NEON_PINK}[!] LAUNCHING VULNERABILITY SCAN ON: $TARGET${RESET}"
        echo -e "${NEON_BLUE}[*] This uses Nmap's vuln scripting engine. It may take several minutes...${RESET}"
        sudo nmap -sV --script vuln "$TARGET"
        ;;

    YARA)
        if [ -z "$TARGET" ]; then echo "Usage: lol yara <File/Directory>"; exit 1; fi
        local rules_dir="${YARA_RULES_DIR:-../yara-rules}"
        echo -e "${NEON_BLUE}[*] Scanning $TARGET with local YARA rules from $rules_dir...${RESET}"
        if [ ! -d "$rules_dir" ]; then echo -e "${NEON_PINK}[-] YARA rules directory not found at $rules_dir${RESET}"; exit 1; fi
        for rule in "$rules_dir"/*.yar; do
            echo -e "\n${NEON_BLUE}--- Applying rule: $(basename "$rule") ---${RESET}"
            yara "$rule" "$TARGET" -r || echo "  -> No matches found."
        done
        ;;
esac

echo -e "\n${NEON_BLUE}========================================================${RESET}"
