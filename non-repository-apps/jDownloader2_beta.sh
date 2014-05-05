#!/bin/bash
##########################################################################
# This script installs jDowloader 2 beta application.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
# Licence: MIT
##########################################################################

# Download jDownloader 2 beta
if [ `uname -i` == "x86_64" ]
then
	# 64 bits
	wget -O /tmp/jdownloader2.sh http://installer.jdownloader.org/JD2SilentSetup_x64.sh 2>&1
else
	# 32 bits
	wget -O /tmp/jdownloader2.sh http://installer.jdownloader.org/JD2SilentSetup_x86.sh 2>&1
fi

bash /tmp/jdownloader2.sh
