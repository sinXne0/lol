# LOL: Ultimate OSINT & Network Reconnaissance Tool

`lol` is a high-potency, all-in-one command-line utility designed for security professionals and OSINT researchers. It automates complex reconnaissance workflows by integrating multiple specialized tools into a single, intuitive interface.

## 🚀 Features

- **High-Potency Recon:** Domain and IP reconnaissance with WAF detection, security audits, and deep port scanning.
- **Advanced OSINT:** Automates data collection for phone numbers, emails, usernames, and domains.
- **Deep Intelligence Extraction:** Extracts Bitcoin wallets, .onion links, Telegram handles, and more from raw text or URLs.
- **Web Pentesting:** Automated sensitive file discovery and directory brute-forcing.
- **Network Operations:** ARP spoofing, internet disconnection (kill), and MAC randomization.
- **Security Analysis:** Metadata extraction (EXIF), vulnerability scanning (via Nmap scripts), and YARA malware detection.

## 🛠️ Installation

### 1. Prerequisites
Ensure the following tools are installed on your system:
- `nmap`, `bettercap`, `macchanger`, `arp-scan`, `exiftool`, `whois`, `dig`, `curl`, `jq`, `yara`
- `python3` with libraries: `cloudscraper`, `beautifulsoup4`, `holehe`, `sherlock_project`

### 2. Setup
Clone the repository and make the script executable:
```bash
git clone https://github.com/your-username/lol.git
cd lol
chmod +x lol
```

### 3. (Optional) Wordlists and YARA Rules
For full functionality in `web` and `yara` modes, place your wordlists in a `./wordlists` directory and YARA rules in a `./yara-rules` directory, or use environment variables:
```bash
export WORDLIST_PATH=/path/to/wordlist.txt
export YARA_RULES_DIR=/path/to/rules
```

## 📖 Usage
```bash
./lol <target> [extra]
```

### Examples:
- **Domain Recon:** `./lol recon google.com`
- **User OSINT:** `./lol sherlock user123`
- **Web Discovery:** `./lol web example.com`
- **Deep Extraction:** `./lol scan https://pastebin.com/raw/xxxxxx`
- **Metadata:** `./lol file image.jpg`

## ⚖️ License
This project is licensed under the MIT License.

## ⚠️ Disclaimer
This tool is for educational and authorized security testing purposes only. The author is not responsible for any misuse.
