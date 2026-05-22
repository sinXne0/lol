import sys
import os
import time
import json
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
    # Run in headless mode if not the first run (optional, but keeping it visible for login)
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
    return driver

def ask_chatgpt(prompt, silent=False):
    driver = init_driver()
    try:
        driver.get("https://chat.openai.com/")
        
        # Check if login is needed
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

def analyze_log(logfile, output_json):
    if not os.path.exists(logfile): return
    
    with open(logfile, 'r') as f:
        log_content = f.read()[-4000:] # Send the last 4000 chars to fit context

    prompt = f"Act as an expert cybersecurity analyst. Analyze the following reconnaissance log and provide a concise strategic summary including: 1. Top vulnerabilities suspected, 2. Recommended next steps for exploitation/auditing. Log data:\n\n{log_content}"
    
    print(f"\x1b[1;35m[!] AI ANALYST: Analyzing session logs for strategic insights...${RESET}")
    analysis = ask_chatgpt(prompt, silent=True)
    
    if analysis:
        with open(output_json, 'w') as f:
            json.dump({"ai_analysis": analysis}, f)
        print("\x1b[1;32m[+] AI Analysis complete. Results added to dashboard.\x1b[0m")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    
    mode = sys.argv[1]
    
    if mode == "--analyze":
        analyze_log(sys.argv[2], sys.argv[3])
    else:
        # Prompt mode
        user_prompt = " ".join(sys.argv[1:])
        contextual_prompt = f"I am a security researcher. {user_prompt}"
        response = ask_chatgpt(contextual_prompt)
        if response:
            print("\n\x1b[1;32m[ AI COMMAND CENTER ]\x1b[0m")
            print(response)
