import sys
import os
import time
import json
import subprocess
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Configuration
USER_DATA_DIR = os.path.expanduser("~/.lol_ai_profile")

def init_driver():
    chrome_options = Options()
    chrome_options.add_argument(f"user-data-dir={USER_DATA_DIR}")
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
    return driver

def ask_chatgpt(prompt, silent=False):
    driver = init_driver()
    try:
        driver.get("https://chat.openai.com/")
        try:
            WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.XPATH, "//button[contains(text(), 'Log in')]")))
            if not silent:
                print("\n\x1b[1;35m[!] LOGIN REQUIRED: Please sign in to ChatGPT in the opened browser window.\x1b[0m")
            WebDriverWait(driver, 300).until(EC.presence_of_element_located((By.ID, "prompt-textarea")))
        except:
            pass

        textarea = WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.ID, "prompt-textarea")))
        textarea.send_keys(prompt)
        time.sleep(1)
        
        send_button = driver.find_element(By.XPATH, "//button[@data-testid='send-button']")
        send_button.click()
        
        if not silent: print("\x1b[1;34m[*] AI is thinking...\x1b[0m")
        
        time.sleep(5)
        WebDriverWait(driver, 90).until(EC.presence_of_element_located((By.XPATH, "//button[@data-testid='send-button']")))
        
        responses = driver.find_elements(By.XPATH, "//div[contains(@class, 'markdown')]")
        if responses:
            return responses[-1].text
    except Exception as e:
        if not silent: print(f"\x1b[1;31m[!] AI Error: {e}\x1b[0m")
    finally:
        driver.quit()

def agent_loop(user_input, target=None):
    """Conversational agent that can suggest commands"""
    system_context = f"You are the 'Ghost Agent' in the LOL (Ultimate Recon) toolkit. Target: {target if target else 'Unknown'}. Available modes: auto, remote, js, history, exploit, recon, scan, web, vuln, phone, email, user, net, sniff, kill, mac. If a command is needed, format it as 'RUN: lol <mode> <target>'."
    
    full_prompt = f"{system_context}\n\nUser: {user_input}"
    response = ask_chatgpt(full_prompt)
    
    if response:
        print("\n\x1b[1;32m[ GHOST AGENT ]\x1b[0m")
        print(response)
        
        if "RUN:" in response:
            cmd = response.split("RUN:")[1].split("\n")[0].strip()
            print(f"\x1b[1;35m\n[!] AI suggests executing: {cmd}\x1b[0m")
            print(f"\x1b[1;34m[?] Execute? (y/n): \x1b[0m", end="")
            choice = input().lower()
            if choice == 'y':
                subprocess.run(cmd, shell=True)

def analyze_log(logfile, output_json):
    if not os.path.exists(logfile): return
    with open(logfile, 'r') as f:
        log_content = f.read()[-5000:]
    prompt = f"Analyze this security recon log. Identify high-value targets, critical vulnerabilities, and suggest the exact 'lol' command for the next step. Log:\n\n{log_content}"
    analysis = ask_chatgpt(prompt, silent=True)
    if analysis:
        with open(output_json, 'w') as f:
            json.dump({"ai_analysis": analysis}, f)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    
    mode = sys.argv[1]
    if mode == "--analyze":
        analyze_log(sys.argv[2], sys.argv[3])
    elif mode == "--agent":
        target = sys.argv[2] if len(sys.argv) > 2 else None
        print("\x1b[1;35m[ GHOST-GPT ACTIVE ] Type 'exit' to return to menu.\x1b[0m")
        while True:
            print("\x1b[1;34m\nGhost> \x1b[0m", end="")
            u_input = input()
            if u_input.lower() in ['exit', 'quit']: break
            agent_loop(u_input, target)
    else:
        user_prompt = " ".join(sys.argv[1:])
        print(ask_chatgpt(f"Act as a security expert. {user_prompt}"))
