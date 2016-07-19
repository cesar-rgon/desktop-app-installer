#!/bin/bash
##########################################################################
# This script installs jDowloader 2 beta application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 18/05/2014
# Licence: MIT
##########################################################################

# Download jDownloader 2 beta
if [ `uname -m` == "x86_64" ]; then
	jDownloader2File="JD2SilentSetup_x64.sh"
else
	jDownloader2File="JD2SilentSetup_x86.sh"
fi
jDownloader2URL="/tmp/jdownloader2.sh http://installer.jdownloader.org/$jDownloader2File"
wget -O /tmp/$jDownloader2File $jDownloader2URL 2>&1
bash /tmp/$jDownloader2File


