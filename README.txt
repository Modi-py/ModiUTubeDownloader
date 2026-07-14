# ModiUTubeDownloader
עבר
מיני-תוכנה להורדת אודיו או וידאו מקישורים של יוטיוב
הקובץ SETUP.BAT יוריד עבורכם את כל מה שהמיני-תוכנה צריכה, למחשב, לתוך תיקיית C:\Tools.
יווצרו 2 תיקיות בשלחן עבודה, אחת עבור הקישורים שמורידים בפורמט הוידאו, ואחת עבור הקישורים שמורידים בפורמט האודיו.
תיווצר קישור (לינק) על שלחן עבודה, למיני-תוכנה, בשם "Download_the_links.py" ("הורד את הקישורים", בלעז). מקליקים פעמיים על קובץ זה והמיני-תוכנה תיפתח. תהנו.
אין משוב: עובד - מה טוב. לא עובד - מה נעים.

אז איך זה עובד?
1. עורכים את הקובץ טקסט של רשימת הקישורים: מוסיפים כמה קישורים של יוטיוב שרוצים, אחד בכל שורה, כמו שמופיע בקובץ טקסט,
2. אחר כך שומרים את הקובץ (CTRL+S או קובץ->שמור),
3. לוחצים על "הורד הקישורים לאודיו"\"הורד הקישורים לוידאו" והוא באמת מנסה להוריד אותם!
אם הגלישה באינטרנט נשלטת על ידי נטפרי - יורדו רק הקישורים הנפתחים על ידי נטפרי.

EN
Script to download audio\video from youtube, with a simple GUI.
The Setup.bat file installs programs in the C:\Tools folder. They are: Python, yt-dlp, ffmpeg and Deno, who are used to download audio and video from Youtube.
The setup file creates 2 text files to add the links to download. Remember to save the text file before clicking in the program on "Download the links".
It also creates 2 folders on the desktop: Audio_Downloads and Video_Downloads, where the downloaded files will be stored.
It creates on the desktop the "Download_the_links.py" file, the "Program" to download the links from Youtube.