import tkinter as tk
from tkinter import messagebox
import subprocess
import threading
import os
import webbrowser
import urllib.request
import ssl

import pyperclip
import time

CURRENT_VERSION = "1.0.2"

def check_for_updates():
    # Create an unverified SSL context to bypass the certificate error
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    try:
        url = "https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/version.txt"
# Pass the context to urlopen
        with urllib.request.urlopen(url, context=ctx) as response:
            latest_version = response.read().decode('utf-8').strip()
            
        # Simple string comparison
        if latest_version > CURRENT_VERSION:
            if messagebox.askyesno("Update Available", f"New version {latest_version} found! Go to GitHub?"):
                webbrowser.open("https://github.com/Modi-py/ModiUTubeDownloader/releases")
        else:
            messagebox.showinfo("Update", "You are using the latest version!")
    except Exception as e:
        # This will show you exactly WHY it fails (e.g., 404 error)
        messagebox.showerror("Error", f"Could not check for updates: {e}")

# --- Configuration ---
PROJECT_PATH = r"C:\Tools\ModiUTubeDownloader"

VIDEO_OUT = os.path.join(os.environ['USERPROFILE'], 'Desktop', 'Video_Downloads')
AUDIO_OUT = os.path.join(os.environ['USERPROFILE'], 'Desktop', 'Audio_Downloads')
button_style = {'width': 20, 'height': 2, 'font': ('Arial', 9), 'wraplength': 120}

    
def get_video_base_cmd(output_path):
    return [
        'yt-dlp', '--proxy', 'http://1.1.1.1:8080', '-f', 'bestvideo+bestaudio/best', 
        '-P', output_path, '--file-access-retries', '0', 
        '--fragment-retries', '0', '--no-playlist', '--ignore-errors', 
        '--no-check-certificates', '--impersonate', 'chrome', 
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 
        '--referer', 'https://www.google.com/', '--merge-output-format', 'mp4', 
        '--sleep-requests', '2', '--min-sleep-interval', '5', '--max-sleep-interval', '10'
    ]

def get_audio_base_cmd(output_path):
    return [
        'yt-dlp', '-x', '--audio-format', 'mp3', '--audio-quality', '0', 
        '-P', output_path, '--file-access-retries', '0', 
        '--fragment-retries', '0', '--no-playlist', '--ignore-errors', 
        '--no-check-certificates', '--impersonate', 'chrome', 
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 
        '--referer', 'https://www.google.com/'
    ]


# --- GUI Setup ---
root = tk.Tk()
root.title("הורדת אודיו או וידאו מיוטיוב")
root.geometry("350x300") 
root.resizable(False, False)


# --- Functions ---
def run_download_task(command, text_file_path=None, archive_file_path=None):
# If downloading a specific link, it's already in the command list
    subprocess.run(command, shell=True)
    
# Post-download cleanup for bulk files
    if text_file_path and archive_file_path and os.path.exists(archive_file_path):
        with open(archive_file_path, 'r', encoding='utf-8') as f:
            successes = f.read()
        if os.path.exists(text_file_path):
            with open(text_file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            with open(text_file_path, 'w', encoding='utf-8') as f:
                for line in lines:
                    if line.strip().startswith('http') and line.strip() in successes:
                        continue
                    f.write(line)

# --- Clipboard Monitoring ---
#def monitor_clipboard(root):
#    last_text = ""
#    while True:
#        try:
#            current_text = pyperclip.paste()
#            if current_text != last_text and ("youtube.com/watch" in current_text or "youtu.be/" in current_text):
#                last_text = current_text
#                root.after(0, lambda: show_download_popup(current_text))
#        except Exception:
#            pass
#        time.sleep(2)

def show_download_popup(url):
    popup = tk.Toplevel()
    popup.title("Download Selection")
    popup.attributes("-topmost", True)
    
    tk.Label(popup, text="Detected: YouTube Link").pack(pady=10, padx=20)
    
    frame = tk.Frame(popup)
    frame.pack(pady=10)
    
def start_dl(mode):
    if mode == "video":
        cmd = get_video_base_cmd(VIDEO_OUT) + [url]
    else:
        cmd = get_audio_base_cmd(AUDIO_OUT) + [url]
    threading.Thread(target=run_download_task, args=(cmd,), daemon=True).start()
    popup.destroy()

# tk.Button(frame, text="Video", command=lambda: start_dl("video")).pack(side=tk.LEFT, padx=5)
# tk.Button(frame, text="Audio", command=lambda: start_dl("audio")).pack(side=tk.LEFT, padx=5)

def run_video_download():
    text_file = os.path.join(PROJECT_PATH, 'Video.txt')
    archive_file = os.path.join(PROJECT_PATH, 'Video_downloaded_success.txt')
    cmd = [
        'yt-dlp', '--proxy', 'http://1.1.1.1:8080', '-f', 'bestvideo+bestaudio/best', 
        '-P', VIDEO_OUT, '-a', text_file, '--file-access-retries', '0', 
        '--fragment-retries', '0', '--download-archive', archive_file, 
        '--no-playlist', '--ignore-errors', '--no-check-certificates', '--impersonate', 'chrome', 
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 
        '--referer', 'https://www.google.com/', '--merge-output-format', 'mp4', 
        '--sleep-requests', '2', '--min-sleep-interval', '5', '--max-sleep-interval', '10'
    ]
    threading.Thread(target=run_download_task, args=(cmd, text_file, archive_file), daemon=True).start()

def run_audio_download():
    text_file = os.path.join(PROJECT_PATH, 'Audio.txt')
    archive_file = os.path.join(PROJECT_PATH, 'audio_downloaded_success.txt')
    cmd = [
        'yt-dlp', '-x', '--audio-format', 'mp3', '--audio-quality', '0', 
        '-P', AUDIO_OUT, '-a', text_file, '--file-access-retries', '0', 
        '--fragment-retries', '0', '--download-archive', archive_file, 
        '--no-playlist', '--ignore-errors', '--no-check-certificates', '--impersonate', 'chrome', 
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 
        '--referer', 'https://www.google.com/'
    ]
    threading.Thread(target=run_download_task, args=(cmd, text_file, archive_file), daemon=True).start()

#def monitor_clipboard():
#    last_text = ""
#    while True:
#        try:
#            current_text = pyperclip.paste()
#            # Check if it's a YouTube link and different from the last one
#            if current_text != last_text and ("youtube.com/watch" in current_text or "youtu.be/" in current_text):
#                last_text = current_text
#                
#                # Use root.after to safely trigger the GUI popup from the background thread
#                root.after(0, lambda: show_download_popup(current_text))
#                
#        except Exception:
#            pass
#        time.sleep(2) # Check every 2 seconds

    
#def show_download_popup(url):
#    popup = tk.Toplevel()
#    popup.title("Download Selection")
#    popup.attributes("-topmost", True)
#    
#    # Add a label
#    tk.Label(popup, text="What would you like to download?").pack(pady=10, padx=20)
#    
#    # Create a frame for buttons
#    frame = tk.Frame(popup)
#    frame.pack(pady=10)
#    
#    # Video Button
#    tk.Button(frame, text="Video", command=lambda: [run_download_task(url, "video"), popup.destroy()]).pack(side=tk.LEFT, padx=5)
#    
#    # Audio Button
#    tk.Button(frame, text="Audio", command=lambda: [run_download_task(url, "audio"), popup.destroy()]).pack(side=tk.LEFT, padx=5)
#
#threading.Thread(target=monitor_clipboard, daemon=True).start()

# UI Elements
tk.Button(root, text="ערוך קובץ קישורים לוידאו", **button_style, command=lambda: os.startfile(os.path.join(PROJECT_PATH, 'Video.txt'))).grid(row=0, column=0, padx=10, pady=(20,10))
tk.Button(root, text="ערוך קובץ קישורים לאודיו", **button_style, command=lambda: os.startfile(os.path.join(PROJECT_PATH, 'Audio.txt'))).grid(row=0, column=1, padx=10, pady=(20,10))
tk.Button(root, text="הורד הקישורים לוידאו", **button_style, bg="#7E57C2", fg="white", command=run_video_download).grid(row=1, column=0, padx=10, pady=10)
tk.Button(root, text="הורד הקישורים לאודיו", **button_style, bg="#FF7043", fg="white", command=run_audio_download).grid(row=1, column=1, padx=10, pady=10)
tk.Button(root, text="פתח תיקיית וידאו", **button_style, command=lambda: os.startfile(VIDEO_OUT)).grid(row=2, column=0, padx=10, pady=10)
tk.Button(root, text="פתח תיקיית אודיו", **button_style, command=lambda: os.startfile(AUDIO_OUT)).grid(row=2, column=1, padx=10, pady=10)
tk.Button(root, text="בדוק עדכונים", width=44, height=1, command=check_for_updates).grid(row=3, column=0, columnspan=2)
tk.Button(root, text="צא", width=44, height=1, command=root.quit).grid(row=4, column=0, columnspan=2, pady=10)

root.mainloop()
