# LOL: Ultimate OSINT & Network Reconnaissance Tool

[![Release](https://img.shields.io/github/v/release/sinXne0/lol?color=pink&label=potency)](https://github.com/sinXne0/lol/releases/latest)

`lol` is a high-potency, all-in-one platform designed for security professionals and OSINT researchers. Now powered by **Ghost-GPT**, it bridges the gap between raw data collection and autonomous intelligence orchestration.

## 🚀 Key Features

- **Ghost-GPT AI Engine:** Integrated browser-based AI that orchestrates tools, suggests attack vectors, and generates obfuscated payloads without needing API keys.
- **High-Potency Recon:** Domain and IP reconnaissance with WAF detection, security audits, and deep port scanning via `rustscan`.
- **Signal Intelligence (SIGINT):** Automated WPA handshake capture, Evil Twin orchestration, and Wi-Fi deauth.
- **Active Exploitation (Warfare):** AI-generated payloads (Wraith), automated brute-force orchestration (Havoc), and Active Directory auditing (Breacher).
- **Deep Intelligence extraction:** Automated detection of Emails, Onion links, Crypto Wallets, AWS Keys, and GitHub Tokens.

## 🖥️ Command & Control

### 1. Interactive Command Center (TUI)
Launch the TUI by running `lol` without arguments. This provides a real-time system status dashboard and a menu-driven interface for all modules.

### 2. Ghost Agent (AI Orchestration)
Found in the Command Center, the **Ghost Agent** allows you to talk to the toolkit. It can suggest and execute commands like `RUN: lol recon target.com` directly with your confirmation.

### 3. Visual War-Room Dashboards
Every session generates a modern, neon-dark HTML dashboard (`lol_dashboard_<target>.html`) featuring:
- **Strategic AI Insights:** An automated summary of vulnerabilities and recommended next steps.
- **Extracted Intel:** Categorized findings (Keys, Wallets, Emails) with auto-linking for fast navigation.

## 🛠️ Installation

### Fast Setup
The automated script handles system dependencies, Python libraries, and environment configuration.

```bash
git clone https://github.com/sinXne0/lol.git
cd lol
sudo chmod +x install.sh
sudo ./install.sh
```

### AI Configuration
To use the AI features, simply run `lol` and select the **AI Command Center**. A browser window will open for a one-time ChatGPT sign-in. Your session is stored locally and securely in `~/.lol_ai_profile` and is never committed to the repo.

## 📖 Usage
```bash
lol <mode> <target> [extra]
```

**Examples:**
- **Autonomous Scan:** `lol auto google.com`
- **AI Payload Gen:** `lol wraith`
- **JS Secret Hunter:** `lol js example.com`
- **User OSINT:** `lol user user123`

## ⚖️ License
This project is licensed under the MIT License.

## ⚠️ Disclaimer
This tool is for educational and authorized security testing purposes only. The author is not responsible for any misuse.
