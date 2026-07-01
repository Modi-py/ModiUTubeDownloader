import tkinter as tk
import subprocess
import threading
import os

# --- Configuration ---
# 'wraplength' helps the Hebrew text wrap inside the buttons
button_style = {'width': 20, 'height': 2, 'font': ('Arial', 9), 'wraplength': 120}

# Helper to run the download command
def run_download_task(command):
    # This keeps the CMD window visible while the download is in progress.
    # It will close automatically when the command finishes.
    subprocess.run(command)

# --- Functions ---
def run_video_download():
    cmd = [
        'yt-dlp', '--proxy', 'http://1.1.1.1:8080', '-f', 'bestvideo+bestaudio/best', 
        '-P', './Video_Downloads', '-a', 'Video.txt', '--file-access-retries', '0', 
        '--fragment-retries', '0', '--download-archive', 'Video_downloaded_success.txt', 
        '--no-playlist', '--ignore-errors', '--no-check-certificates', '--impersonate', 'chrome', 
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 
        '--referer', 'https://www.google.com/', '--merge-output-format', 'mp4', 
        '--sleep-requests', '2', '--min-sleep-interval', '5', '--max-sleep-interval', '10'
    ]
    threading.Thread(target=run_download_task, args=(cmd,), daemon=True).start()

def run_audio_download():
    cmd = [
        'yt-dlp', '-x', '--audio-format', 'mp3', '--audio-quality', '0', 
        '-P', './Audio_Downloads', '-a', 'Audio.txt', '--file-access-retries', '0', 
        '--fragment-retries', '0', '--download-archive', 'audio_downloaded_success.txt', 
        '--no-playlist', '--ignore-errors', '--no-check-certificates', '--impersonate', 'chrome', 
        '--user-agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36', 
        '--referer', 'https://www.google.com/'
    ]
    threading.Thread(target=run_download_task, args=(cmd,), daemon=True).start()

# --- GUI Setup ---
root = tk.Tk()
root.title("הורדת אודיו או וידאו מיוטיוב")
root.geometry("350x250") 
root.resizable(False, False)

# Row 0: Edit file buttons
tk.Button(root, text="ערוך קובץ קישורים להורדת וידאו", **button_style, command=lambda: os.startfile("Video.txt")).grid(row=0, column=0, padx=10, pady=(20,10))
tk.Button(root, text="ערוך קובץ קישורים להורדת אודיו", **button_style, command=lambda: os.startfile("Audio.txt")).grid(row=0, column=1, padx=10, pady=(20,10))

# Row 1: Download buttons
tk.Button(root, text="הורד הקישורים לוידאו", **button_style, bg="#7E57C2", fg="white", command=run_video_download).grid(row=1, column=0, padx=10, pady=10)
tk.Button(root, text="הורד הקישורים לאודיו", **button_style, bg="#FF7043", fg="white", command=run_audio_download).grid(row=1, column=1, padx=10, pady=10)

# Row 2: Open folder buttons
tk.Button(root, text="פתח תיקיית וידאו", **button_style, command=lambda: os.startfile(os.path.realpath("./Video_Downloads"))).grid(row=2, column=0, padx=10, pady=10)
tk.Button(root, text="פתח תיקיית אודיו", **button_style, command=lambda: os.startfile(os.path.realpath("./Audio_Downloads"))).grid(row=2, column=1, padx=10, pady=10)

# Row 3: Exit button
tk.Button(root, text="צא", width=44, height=1, command=root.quit).grid(row=3, column=0, columnspan=2, pady=10)

root.mainloop()