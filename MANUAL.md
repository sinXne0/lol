# LOL Tool Manual - Ultimate OSINT & Network Recon (v4 Extreme-Potency)

The `lol` tool is an all-in-one command-line utility for high-level intelligence gathering and security auditing.

## New Extreme-Potency Features (v4)
- **Auto-Pilot Mode (`auto`)**: Chained execution. Runs Remote Intelligence -> Infrastructure History -> JS Secret Hunting -> CMS Audit -> Active Port Scanning in one pass.
- **Remote Passive Intelligence (`remote`)**: Pulls data from third-party APIs (Shodan, OTX AlienVault, HackerTarget) to gather port data, vulnerabilities, and shared hosting info without sending a single packet to the target.
- **JS Secret Hunter (`js`)**: Crawls remote JavaScript files to extract API keys (Google, AWS, Firebase), hidden endpoints, and authentication tokens.
- **Infrastructure History (`history`)**: Retrieves historical DNS records and WHOIS registration data from remote databases to find hidden or old assets.
- **Exploit Mapping (`exploit`)**: Queries remote vulnerability databases (Vulners) for known exploits based on detected software versions.

## Usage
```bash
lol [flags] <mode> <target> [extra]
```

### Flags
- `--tor`: Route all web requests through the Tor network.
- `--stealth`: Add randomized 1-3s delays between requests to bypass WAFs.

## High-Potency Modes

### 1. AUTO (Ultimate Chaining)
**Command:** `lol auto <Domain/IP>`
The most lethal command. Automates the entire recon lifecycle from passive intelligence to active scanning.

### 2. REMOTE (Passive Intelligence)
**Command:** `lol remote <Domain/IP>`
Finds open ports (via Shodan), shared hosting neighbors, and GeoIP data entirely through remote APIs. Zero direct interaction with the target.

### 3. JS (Secret Hunting)
**Command:** `lol js <URL/Domain>`
Extracts and analyzes all JS files for sensitive strings like `AIza...` (Google Maps), `AKIA...` (AWS), or hidden `/api/v2/` endpoints.

### 4. HISTORY (Infrastructure History)
**Command:** `lol history <Domain>`
Pulls historical DNS records and WHOIS data. Great for finding old subdomains or developer email addresses.

### 5. EXPLOIT (Vulnerability Search)
**Command:** `lol exploit <Version> <Software>`
**Example:** `lol exploit 2.4.49 apache`
Queries remote databases for known CVEs and exploit titles for the specific version.

### 6. RECON (Full Audit)
**Command:** `lol recon <Domain/IP>`
Combines remote intelligence with active WAF/CMS detection and a deep service scan.

## Standard Modes
- **Phone/Email/User**: Deep OSINT scrapers for identities and account registrations.
- **Web**: Directory and API brute-forcing with `ffuf` support.
- **Vuln**: Deep vulnerability scanning via Nmap scripts and `nuclei`.
- **Net/Sniff/Kill**: Local network intervention and monitoring.

## Output Files
- `lol_report_<target>.txt`: Complete session log (stored in script directory).
- `lol_intel_<target>.json`: Automated extraction of Emails, Onions, Wallets, and Secrets (stored in script directory).
