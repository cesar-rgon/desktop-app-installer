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
if [ "$(id -u)" != "0" ]; then echo "" 1>&2; echo "This script must be executed by a root or sudoer user" 1>&2; echo "" 1>&2; exit 1; fi

# Get common variables
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh

# Parameters
package="$1"

# Commands
apt-get -y install $package --fix-missing >/dev/null
if [ $? -ne 0 ]; then
	echo "$packageInstallFailed $package ..." 1>&2
	# Error installing package. Applying contingence measure
	rm -f "/var/lib/dpkg/info/$package.pre*" >/dev/null
	rm -f "/var/lib/dpkg/info/$package.post*" >/dev/null
	apt-get install -f >/dev/null
	if [ $? -ne 0 ]; then
		echo "$packageInstallFailed $package" 1>&2
		echo -e "$packageReparationFailed" 1>&2
	fi
fi
