#!/bin/bash
##########################################################################
# This script prepares Teamviewer application to be ready to be installed
# on 64 bits OS linux
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

# We must add 32 bits architecture to be able to install Skype 32 bits in 64 bits OS
dpkg --add-architecture i386
