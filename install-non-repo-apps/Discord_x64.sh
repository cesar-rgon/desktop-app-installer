#!/bin/bash
##########################################################################
# This script installs Discord application from external sources
# @author César Rodríguez González
# @version 1.3.3, 2017-04-22
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/../.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Commands to download, extract and install a non-repository application ...
URL="https://discordapp.com/api/download"
wget -O "$tempFolder/discordapp.deb" "$URL?platform=linux&format=deb" 2>&1
gdebi --n "$tempFolder/discordapp.deb"
