#!/bin/bash
##########################################################################
# This script configures aMule client application to be ready to use.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 17/07/2016
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# After install aMule application the system must be returned to stable default repository
sed -i 's/stretch main/jessie main/g' /etc/apt/sources.list

