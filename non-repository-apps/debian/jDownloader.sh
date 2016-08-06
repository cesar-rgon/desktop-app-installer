#!/bin/bash
##########################################################################
# This script installs jDowloader application.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/../.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Commands to download, extract and install a non-repository application.
# Pre-requisite
apt-get -y install default-jre

# Commands to download, extract and install a non-repository application.
jDownloaderFile="jd_unix_0_9.sh"
jDownloaderURL="http://installer.jdownloader.org/$jDownloaderFile"
wget -P /var/cache/apt/archives $jDownloaderURL 2>&1
bash /var/cache/apt/archives/$jDownloaderFile
