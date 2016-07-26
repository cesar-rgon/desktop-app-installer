#!/bin/bash
##########################################################################
# This script install Google Earth application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 26/07/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Get common variables 
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Commands to setup an installed application
mkdir /tmp/google_earth_package
cd /tmp/google_earth_package
dpkg --add-architecture i386
make-googleearth-package --force --quiet
gdebi --n /tmp/google_earth_package/googleearth*.deb


