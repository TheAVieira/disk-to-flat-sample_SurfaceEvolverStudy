:: Arthur Vieira, 20/08/2020
:: This sript converts raw AVI files to *.mp4. The compression can be strong (5GB to 10MB) but no significant loss was noticed.

:: REQUIREMENTS ======
:: ffmpeg : Download binaries for Windows from https://www.ffmpeg.org/download.html. There is no installation file. After downloading the *.zip, extract it to 'C:/ffmpeg'. Then add 'C/ffmpeg/bin' to PATH. Check that setup is working by running 'ffmpeg -version' in command line.

:: USAGE ======
:: Place the script in the same folder as the videos. The script will convert any *.avi, saving them to the current location. No files are ever deleted.

:: Notes =======
:: File size may vary. Picture motion is ok, but light changes make the conversion slower and final file bigger.

:: Main source: https://superuser.com/questions/525249/convert-avi-xvid-to-mp4-h-264-keeping-the-same-quality
:: This assumes FFMPEG was downloaded and path to "FFMPEG\bin" was added to Window's environmental variable PATH.

@echo off 

:: Iterate avi files and convert them. Source: https://stackoverflow.com/questions/39615/how-to-loop-through-files-matching-wildcard-in-batch-file
:: Pixel format needs setting for MatLab to read. Source: https://se.mathworks.com/matlabcentral/answers/164529-reading-video-file-compressed-losslessly-with-x264
for %%f in (*.avi) do (
	ffmpeg -i  %%f -c:v libx264 -crf 20 -preset slow -pix_fmt yuv420p %%~nf.mp4
)

echo. 
echo All files have been converted.

pause