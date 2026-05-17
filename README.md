# LOL: Ultimate OSINT & Network Reconnaissance Tool

`lol` is a high-potency, all-in-one command-line utility designed for security professionals and OSINT researchers. It automates complex reconnaissance workflows by integrating multiple specialized tools into a single, intuitive interface.

## 🚀 Features

- **High-Potency Recon:** Domain and IP reconnaissance with WAF detection, security audits, and deep port scanning.
- **Advanced OSINT:** Automates data collection for phone numbers, emails, usernames, and domains.
- **Deep Intelligence Extraction:** Extracts Bitcoin wallets, .onion links, Telegram handles, and more from raw text or URLs.
- **Web Pentesting:** Automated sensitive file discovery and directory brute-forcing.
- **Network Operations:** ARP spoofing, internet disconnection (kill), and MAC randomization.
- **Security Analysis:** Metadata extraction (EXIF), vulnerability scanning (via Nmap scripts), and YARA malware detection.
- **Extreme-Potency Modules:** Auto-pilot mode, JS secret hunting, infrastructure history, and exploit mapping.

## 🛠️ Installation

### Option 1: Ultra-Fast Setup (Recommended)
The automated setup script detects your OS and installs all system and Python dependencies for you.

```bash
git clone https://github.com/sinXne0/lol.git
cd lol
sudo chmod +x install.sh
sudo ./install.sh
```

### Option 2: Docker Deployment (Zero-Conflict)
Run `lol` in a completely isolated container with all dependencies pre-installed.

**Build the image:**
```bash
docker build -t lol .
```

**Run the tool:**
```bash
docker run --rm -it lol auto google.com
```

### Option 3: Manual Installation
Ensure the following tools are installed:
- **System:** `nmap`, `bettercap`, `macchanger`, `arp-scan`, `exiftool`, `whois`, `dig`, `curl`, `jq`, `yara`, `python3`, `golang`
- **Python:** `cloudscraper`, `beautifulsoup4`, `holehe`, `sherlock-project`

### 3. API Configuration
`lol` uses several third-party APIs for passive intelligence gathering. On the first run, it will create a configuration file at `~/.lol_config`. You should add your API keys there for full functionality:

```bash
# Open the config file
nano ~/.lol_config
```

**Keys to add:**
- `SHODAN_API_KEY`: For remote port and vulnerability data.
- `HIBP_API_KEY`: For Have I Been Pwned email leak checks.
- `DISCORD_WEBHOOK`: (Optional) For automated reporting to a Discord channel.

### 4. (Optional) Wordlists and YARA Rules
For full functionality in `web` and `yara` modes, place your wordlists in a `./wordlists` directory and YARA rules in a `./yara-rules` directory, or use environment variables:
```bash
export WORDLIST_PATH=/path/to/wordlist.txt
export YARA_RULES_DIR=/path/to/rules
```

## 📖 Usage
```bash
./lol_osint.sh <mode> <target> [extra]
```

### Examples:
- **Auto-Pilot:** `./lol_osint.sh auto google.com` (Runs everything automatically)
- **Domain Recon:** `./lol_osint.sh recon google.com`
- **JS Secret Hunter:** `./lol_osint.sh js example.com`
- **User OSINT:** `./lol_osint.sh sherlock user123`
- **Web Discovery:** `./lol_osint.sh web example.com`
- **Metadata:** `./lol_osint.sh file image.jpg`

## ⚖️ License
This project is licensed under the MIT License.

## ⚠️ Disclaimer
This tool is for educational and authorized security testing purposes only. The author is not responsible for any misuse.
