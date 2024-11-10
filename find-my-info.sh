#!/bin/bash
#################################################################
# Made by :                                                     #
#    ____                _ _ _        ___         __  __        #
#  / ___|__ _ _ __ ___ (_) | | ___  |_ _|___    |  \/  | ___    #
# | |   / _` | '_ ` _ \| | | |/ _ \  | |/ __|   | |\/| |/ _ \   #
# | |__| (_| | | | | | | | | |  __/_ | |\__ \   | |  | |  __/   #
# \____\__,_|_| |_| |_|_|_|_|\___(_)___|___/___|_|  |_|\___|    #
#                                         |_____|               #
#################################################################
[[ "$1" = "-h" || "$1" = "--help" || "$1" = "-?" ]] && echo -e """\nMade by : Camille.Is_Me\n\nThis script is used to check if some of your personal information present on your device are present in a given file.\n\nUsage :\n$(basename "$0") <file1> <file2>\t\t:\t scans the files to see if they contain Personally Identifiable Information (PII)\n$(basename "$0") <-t or --test>\t\t:\t creates a testfile with all the information\n$(basename "$0") <-c or --creator>\t:\t displays information on how to reach me and/or contribute to the project\n\nExit codes :\n0 - operations completed successfully\n1 - no files provided\n2 - the file provided doesn't exist\n3 - error accessing site for IP information\n99 - test file requested""" && exit 0

[[ -z "$*" ]] && echo -e "Error : you need to provide at least one file to examine" && exit 1

if ! [[ "$1" = "-t" || "$1" = "--test" ]]; then
    for file in "$@"; do 
        [[ -e $file ]] || { echo "[!] FILE $file WAS NOT FOUND" ;  exit 2; }
    done
fi

TOOLS=("exiftool" "jq")
for tool in "${TOOLS[@]}"; do
    if [[ $(command -v "$tool" 2>/dev/null) ]]; then
        echo "[&]FOUND $tool"
    else
        read -rp "Would you like to install $tool? (y/n): " choice
        if [[ "$choice" == "y" ]]; then
            
            if command -v apt > /dev/null 2>&1; then
                sudo apt update && sudo apt install -y "$tool" echo "[&] Successfully installed $tool !" || echo "[!] Error installing $tool"

            elif command -v yum > /dev/null 2>&1; then
                sudo yum install -y "$tool" echo "[&] Successfully installed $tool !" || echo "[!] Error installing $tool"

            elif command -v pacman > /dev/null 2>&1; then
                sudo pacman -Sy "$tool" echo "[&] Successfully installed $tool !" || echo "[!] Error installing $tool"

            elif command -v dnf > /dev/null 2>&1; then
                sudo dnf install "$tool" && echo "[&] Successfully installed $tool !" || echo "[!] Error installing $tool"

            else
                echo "No compatible package manager found. Please install $tool manually."
            fi
        else
            echo "Skipping installation of $tool."
        fi
    fi
done
echo ""

IPINFO_RESULTS=$(curl ipinfo.io -s) || { echo -e "[!] ERROR ACCESSING IP SITE" ; exit 3; }
HOSTNAME=$(cat /etc/hostname)
OS=$(uname -s)
OS_VERSION=$(uname -r)
MAC=$(ip link show | awk '/ether/ {print $2; exit}')
IP=$(echo "$IPINFO_RESULTS" | jq ".ip" -r)
GEOLOCATION=$(echo "$IPINFO_RESULTS" | jq '.city, .region, .country' -r | paste -sd, -)
COORDINATES=$(echo "$IPINFO_RESULTS" | jq '.loc' -r | paste -sd, -)
TIME=$(date)
SSH_PUBKEY=$(cat "$HOME"/.ssh/id_rsa.pub 2>/dev/null || echo "[?] No SSH public key found")
echo -e """DATE\t\t $TIME\nIP \t\t $IP \nHOSTNAME \t $HOSTNAME\nUSER \t\t $USER\nDIRECTORY\t $PWD\nOS\t\t $OS\nOS Version\t $OS_VERSION\nMAC Address\t $MAC\nLocation\t $GEOLOCATION\nLAT - LONG \t $COORDINATES\nSSH PUBKEY\t${SSH_PUBKEY:7:39}..."""
[[ "$1" = "-t" || "$1" = "--test" ]] && { echo -e """DATE\t\t$TIME\nIP \t\t$IP \nHOSTNAME \t$HOSTNAME\nUSER \t\t$USER\nDIRECTORY\t$PWD\nOS\t\t$OS\nOS Version\t$OS_VERSION\nMAC Address\t$MAC\nLocation\t$GEOLOCATION\nLAT - LONG \t$COORDINATES\nSSH PUBKEY\t$SSH_PUBKEY""" >> "$USER-info-$(date +%Y%m%d_%H%M%S).txt"; exit 99; }

ITEMS=("$IP" "$HOSTNAME" "$USER" "$PWD" "$OS" "$OS_VERSION" "$MAC" "$GEOLOCATION" "$COORDINATES" "$DATE")

echo -e "\n"

for file in "$@"; do

    echo -e "\n[=======$file=======]"

    RESULT=()

    for item in "${ITEMS[@]}"; do

            if [[ -n "$item" ]] ; then 

            if grep -q "$item" "$file"; then
                RESULT+=("[!] <$file|FILE> FOUND $item")
            fi

            if exiftool "$file" | grep -q "$item"; then 
                RESULT+=("[!] <$file|EXIF> FOUND $item")
            fi

        fi

    done

    if [[ "${#RESULT[@]}" -ne 0 ]]; then
    
    echo -e ""

        for line in "${RESULT[@]}"; do
            echo "$line"
        done

    else

        echo -e "[&] NO INFORMATION FOUND IN <$file>\n"

    fi

done

echo ""

exit 0