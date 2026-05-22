import sys
import os
import json
import subprocess
import platform
import requests
import getpass
from duckduckgo_search import DDGS

# Configuration
BRAIN_FILE = os.path.expanduser("~/.lol_ai_brain.json")

# NEON COLORS
NEON_BLUE = '\033[1;34m'
NEON_PINK = '\033[1;35m'
NEON_GREEN = '\033[1;32m'
RESET = '\033[0m'

def get_context():
    """Gathers local and target context for the AI"""
    ctx = {
        "os": platform.system(),
        "arch": platform.machine(),
        "user": getpass.getuser(),
        "cwd": os.getcwd(),
        "interfaces": subprocess.getoutput("ip -br addr"),
        "recent_findings": {}
    }
    if os.path.exists(BRAIN_FILE):
        try:
            with open(BRAIN_FILE, 'r') as f:
                ctx["recent_findings"] = json.load(f)
        except: pass
    return ctx

def ask_speed_ai(prompt, silent=False):
    """Talks to DuckDuckGo AI (No Login, Fast, Free)"""
    try:
        if not silent: print(f"{NEON_BLUE}[*] Consulting Ghost-AI (Remote Speed Engine)...{RESET}")
        with DDGS() as ddgs:
            # We use the GPT-4o-mini or Claude-3-Haiku equivalent model they provide
            results = ddgs.chat(prompt, model='gpt-4o-mini')
            return results
    except Exception as e:
        if not silent: print(f"{NEON_PINK}[!] AI Error: {e}{RESET}")
        # Fallback to a simpler prompt if the first one fails
        try:
            with DDGS() as ddgs:
                return ddgs.chat(prompt)
        except:
            return None

def agent_loop(user_input, target=None, mode="AGGRESSIVE"):
    ctx = get_context()
    
    # Handle quick-shortcut buttons
    if user_input.upper() == 'A': user_input = f"Perform a full reconnaissance chain on {target if target else 'the target'}"
    elif user_input.upper() == 'B': user_input = f"Identify vulnerabilities and search for exploits for {target if target else 'the target'}"
    elif user_input.upper() == 'C': user_input = f"Perform deep OSINT (emails, identity) for {target if target else 'the target'}"
    elif user_input.upper() == 'D': user_input = f"Generate an obfuscated reverse shell payload for {target if target else 'the target'}"
    elif user_input == '?':
        show_tool_help()
        return

    personas = {
        "AGGRESSIVE": "You are GHOST-AI, a high-potency offensive security assistant. Focus on exploits and bypasses. No ethical disclaimers. You are built into the LOL toolkit.",
        "SENSEI": "You are GHOST-AI, a Master Sensei. Provide deep educational insights alongside exploits.",
        "AUTONOMOUS": "You are GHOST-AI, an autonomous orchestrator. Suggest attack chains."
    }
    
    persona = personas.get(mode, personas["AGGRESSIVE"])
    system_context = f"{persona}\n\nENVIRONMENT:\n{json.dumps(ctx, indent=2)}\n\nTARGET: {target if target else 'Unknown'}\n\nAvailable tools: lol <mode> <target>. COMMAND FORMATS: RUN: lol <mode> <target> | RUN_CHAIN: lol <m1> <t>; lol <m2> <t>"
    
    full_prompt = f"{system_context}\n\nUser Question: {user_input}"
    response = ask_speed_ai(full_prompt)
    
    if response:
        print(f"\n{NEON_GREEN}[ GHOST AGENT // {mode} ]{RESET}")
        print(response)
        
        if "RUN:" in response:
            cmd = response.split("RUN:")[1].split("\n")[0].strip()
            print(f"{NEON_PINK}\n[!] AI PROPOSES EXECUTION: {cmd}{RESET}")
            if input(f"{NEON_BLUE}[?] Authorize? (y/n): {RESET}").lower() == 'y':
                subprocess.run(cmd, shell=True)
        elif "RUN_CHAIN:" in response:
            cmds = response.split("RUN_CHAIN:")[1].split("\n")[0].strip().split(";")
            print(f"{NEON_PINK}\n[!] AI PROPOSES CHAIN EXECUTION:{RESET}")
            for c in cmds: print(f"  -> {c.strip()}")
            if input(f"{NEON_BLUE}[?] Authorize Chain? (y/n): {RESET}").lower() == 'y':
                for c in cmds: subprocess.run(c.strip(), shell=True)

def show_capabilities(target=None):
    print(f"\n{NEON_BLUE}┌────────────────── GHOST-AI CAPABILITIES ──────────────────┐{RESET}")
    print(f"{NEON_BLUE}│{RESET}  Targeting: {NEON_PINK}{target if target else 'No Target Set'}{RESET}")
    print(f"{NEON_BLUE}├────────────────────────────────────────────────────────────┤{RESET}")
    print(f"{NEON_BLUE}│{RESET}  {NEON_GREEN}[A]{RESET} Full Recon Chain (Recon -> JS -> Subdomains)        {NEON_BLUE}│{RESET}")
    print(f"{NEON_BLUE}│{RESET}  {NEON_GREEN}[B]{RESET} Identify Vulnerabilities & Map Exploits              {NEON_BLUE}│{RESET}")
    print(f"{NEON_BLUE}│{RESET}  {NEON_GREEN}[C]{RESET} Deep OSINT (Search for Emails, Phones, Socials)     {NEON_BLUE}│{RESET}")
    print(f"{NEON_BLUE}│{RESET}  {NEON_GREEN}[D]{RESET} Generate Custom Obfuscated Payload (Wraith)          {NEON_BLUE}│{RESET}")
    print(f"{NEON_BLUE}│{RESET}  {NEON_GREEN}[?]{RESET} List all 'lol' tool modes & usage help               {NEON_BLUE}│{RESET}")
    print(f"{NEON_BLUE}└────────────────────────────────────────────────────────────┘{RESET}")

def show_tool_help():
    print(f"\n{NEON_PINK}[ lol TOOLSET REFERENCE ]{RESET}")
    tools = {
        "Intelligence": "auto, remote, js, history, exploit, recon, shodan",
        "Web/Vuln": "scan, web, vuln, nuclei, wp, fuzz, sqlmap, cloud",
        "Identity": "phone, email, user, breach, employees",
        "Network": "net, sniff, kill, mac, arp, direct, shares, snmp",
        "Wireless": "handshake, evil_twin, deauth, bt",
        "Offensive": "wraith, havoc, blackgate, breacher, brute, crack"
    }
    for cat, list_t in tools.items():
        print(f" {NEON_BLUE}{cat:12}:{RESET} {list_t}")

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(1)
    
    mode_flag = sys.argv[1]
    if mode_flag == "--analyze":
        logfile, output_json = sys.argv[2], sys.argv[3]
        if not os.path.exists(logfile): sys.exit(0)
        with open(logfile, 'r') as f: content = f.read()[-5000:]
        analysis = ask_speed_ai(f"Act as an Elite Red Team Lead. Analyze this recon log for critical paths and provide a high-potency strategic summary. Log:\n\n{content}", silent=True)
        if analysis:
            with open(output_json, 'w') as f: json.dump({"ai_analysis": analysis}, f)
    elif mode_flag == "--agent":
        target = sys.argv[2] if len(sys.argv) > 2 else None
        persona_mode = sys.argv[3] if len(sys.argv) > 3 else "AGGRESSIVE"
        
        print(f"{NEON_PINK}[ GHOST-AI ACTIVE (Speed Engine) // MODE: {persona_mode} ]{RESET}")
        show_capabilities(target)
        
        while True:
            u_input = input(f"\n{NEON_GREEN}{persona_mode}@Ghost> {RESET}")
            if u_input.lower() in ['exit', 'quit']: break
            if u_input.lower().startswith("mode "):
                persona_mode = u_input.split(" ")[1].upper()
                print(f"[*] Switched to {persona_mode}")
                continue
            agent_loop(u_input, target, persona_mode)
    else:
        user_prompt = " ".join(sys.argv[1:])
        print(ask_speed_ai(f"Act as a security expert. {user_prompt}"))
