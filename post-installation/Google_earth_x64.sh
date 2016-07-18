#!/bin/bash
##########################################################################
# This script install Google Earth application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 18/07/2016
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Commands to setup an installed application
mkdir /tmp/google_earth_package
cd /tmp/google_earth_package
dpkg --add-architecture i386
make-googleearth-package --force --quiet
gdebi --n /tmp/google_earth_package/googleearth*.deb


