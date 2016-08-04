#!/bin/bash
##########################################################################
# This script installs jDowloader application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 04/08/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
. ../../common/commonVariables.sh "`pwd`/../.."

# Commands to download, extract and install a non-repository application.
# Pre-requisite
apt-get -y install default-jre

# Commands to download, extract and install a non-repository application.
jDownloaderFile="jd_unix_0_9.sh"
jDownloaderURL="http://installer.jdownloader.org/$jDownloaderFile"
wget -P /var/cache/apt/archives $jDownloaderURL 2>&1
bash /var/cache/apt/archives/$jDownloaderFile
