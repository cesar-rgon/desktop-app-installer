#!/bin/bash
##########################################################################
# This script prepare Steam installation.
#
# Author: César Rodríguez González
# Version: 1.3
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

# Activate Multiverse repository (if not already activated) for install Steam package from default repositories
add-apt-repository -y multiverse 1>/dev/null



