#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of
# jDownloader application.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 12/05/2014
# Licence: MIT
##########################################################################
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

add-apt-repository -y ppa:jd-team/jdownloader 2>&1
