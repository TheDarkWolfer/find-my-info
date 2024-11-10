# FIND-MY-INFO.SH

###What is it ?
A bash script that lets you scan files for PII, both the file contents itself and it's exif metadata. 
To use it, just run the `find-my-info.sh` script by providing one or more files as arguments and it'll do it's thing. 
There are two dependencies : exiftool (for exif metadata reading) and jq (for json data handling from ipinfo.io). The script will check for their presence and offer to install them through your system's package manager (if supported) for you.
