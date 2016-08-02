#!/bin/bash
##########################################################################
# This script check if an error has ocurred during installation process of
# an application package. If so, apply contingence measure.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 02/08/2016
# Licence: MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Get common variables
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Parameters
package="$1"

# Commands
apt-get -y install $package --fix-missing
if [ $? != 0 ]; then
	# Error installing package. Applying contingence measure
	rm -f "/var/lib/dpkg/info/$package.pre*" 1>/dev/null
	rm -f "/var/lib/dpkg/info/$package.post*" 1>/dev/null
	apt-get install -f 1>/dev/null
fi
