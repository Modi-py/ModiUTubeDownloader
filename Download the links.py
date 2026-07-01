import tkinter as tk
import subprocess
import threading
import os
import webbrowser
import urllib.request

CURRENT_VERSION = "1.0.0"

def check_for_updates():
    try:
        # Link to the raw version.txt file in your GitHub repo
        url = "https://raw.githubusercontent.com/Modi-py/ModiUTubeDownloader/main/version.txt"
        with urllib.request.urlopen(url) as response:
            latest_version = response.read().decode('utf-8').strip()
        
        if latest_version > CURRENT_VERSION:
            if tk.messagebox.askyesno("Update Available", f"New version {latest_version} found! Go to GitHub?"):
                webbrowser.open("https://github.com/Modi-py/ModiUTubeDownloader/releases")
        else:
            tk.messagebox.showinfo("Update", "You are using the latest version!")
    except:
        tk.messagebox.showerror("Error", "Could not check for updates.")

# --- Configuration ---
PROJECT_PATH = r"C:\Tools\ModiUTubeDownloader"
VIDEO_OUT = os.path.join(os.environ['USERPROFILE'], 'Desktop', 'Video_Downloads')
AUDIO_OUT = os.path.join(os.environ['USERPROFILE'], 'Desktop', 'Audio_Downloads')
button_style = {'width': 20, 'height': 2, 'font': ('Arial', 9), 'wraplength': 120}

# --- Functions ---
def run_download_task(command, text_file_path, archive_file_path):
    # 1. Run the download
    subprocess.run(command)
    
    # 2. After download, check the archive to see what succeeded
    if os.path.exists(archive_file_path):
        with open(archive_file_path, 'r', encoding='utf-8') as f:
            successes = f.read()

        # 3. Read the original links file and keep only links that FAILED
        if os.path.exists(text_file_path):
            with open(text_file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            with open(text_file_path, 'w', encoding='utf-8') as f:
                for line in lines:
                    is_link = line.strip().startswith('http')
                    # Keep the line if it's NOT a link, OR if it's a link that wasn't in the success archive
                    if is_link and line.strip() in successes:
                        continue 
                    f.write(line)

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

# --- GUI Setup ---
root = tk.Tk()
root.title("הורדת אודיו או וידאו מיוטיוב")
root.geometry("350x300") 
root.resizable(False, False)

# UI Elements
tk.Button(root, text="ערוך קובץ קישורים לוידאו", **button_style, command=lambda: os.startfile(os.path.join(PROJECT_PATH, 'Video.txt'))).grid(row=0, column=0, padx=10, pady=(20,10))
tk.Button(root, text="ערוך קובץ קישורים לאודיו", **button_style, command=lambda: os.startfile(os.path.join(PROJECT_PATH, 'Audio.txt'))).grid(row=0, column=1, padx=10, pady=(20,10))
tk.Button(root, text="הורד הקישורים לוידאו", **button_style, bg="#7E57C2", fg="white", command=run_video_download).grid(row=1, column=0, padx=10, pady=10)
tk.Button(root, text="הורד הקישורים לאודיו", **button_style, bg="#FF7043", fg="white", command=run_audio_download).grid(row=1, column=1, padx=10, pady=10)
tk.Button(root, text="פתח תיקיית וידאו", **button_style, command=lambda: os.startfile(VIDEO_OUT)).grid(row=2, column=0, padx=10, pady=10)
tk.Button(root, text="פתח תיקיית אודיו", **button_style, command=lambda: os.startfile(AUDIO_OUT)).grid(row=2, column=1, padx=10, pady=10)
tk.Button(root, text="צא", width=44, height=1, command=root.quit).grid(row=3, column=0, columnspan=2, pady=10)
tk.Button(root, text="בדוק עדכונים", command=check_for_updates).grid(row=4, column=0, columnspan=2)

root.mainloop()