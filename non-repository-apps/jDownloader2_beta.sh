#!/bin/bash
##########################################################################
# This script installs jDowloader 2 beta application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 26/07/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Get common variables
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Commands to download, extract and install a non-repository application.
if [ `uname -m` == "x86_64" ]; then
	jDownloader2File="JD2SilentSetup_x64.sh"
else
	jDownloader2File="JD2SilentSetup_x86.sh"
fi
jDownloader2URL="/tmp/jdownloader2.sh http://installer.jdownloader.org/$jDownloader2File"
wget -O /tmp/$jDownloader2File $jDownloader2URL 2>&1
bash /tmp/$jDownloader2File
chown $usuario:$usuario -R /opt/jd2 
