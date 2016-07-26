#!/bin/bash
##########################################################################
# This script configures Clementine application to use monochrome taskbar
# icons.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 26/07/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Get common variables 
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Create symbolic links for Clementine monochrome taskbar icons
ln -s /usr/share/icons/ubuntu-mono-dark/apps/24/clementine-panel.png /usr/share/icons/hicolor/24x24/status/clementine-panel.png
ln -s /usr/share/icons/ubuntu-mono-dark/apps/24/clementine-panel-grey.png /usr/share/icons/hicolor/24x24/status/clementine-panel-grey.png

