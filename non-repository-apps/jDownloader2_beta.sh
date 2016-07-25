#!/bin/bash
##########################################################################
# This script installs jDowloader 2 beta application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 25/07/2016
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Download jDownloader 2 beta
if [ `uname -m` == "x86_64" ]; then
	jDownloader2File="JD2SilentSetup_x64.sh"
else
	jDownloader2File="JD2SilentSetup_x86.sh"
fi
jDownloader2URL="/tmp/jdownloader2.sh http://installer.jdownloader.org/$jDownloader2File"
wget -O /tmp/$jDownloader2File $jDownloader2URL 2>&1
bash /tmp/$jDownloader2File
chown $usuario:$usuario -R /opt/jd2 
