#!/bin/bash
##########################################################################
# This script check if an error has ocurred during installation process of
# an application package. If so, apply contingence measure.
# @author 	César Rodríguez González
# @since 		1.3, 2016-07-28
# @version 	1.3, 2016-08-04
# @license 	MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo "" 1>&2; echo "This script must be executed by a root or sudoer user" 1>&2; echo "" 1>&2; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Parameters
package="$1"

# Commands
apt-get -y install $package --fix-missing
if [ $? -ne 0 ]; then
	echo -e "$packageInstallFailed $package ..." 1>&2
	# Error installing package. Applying contingence measure
	rm -f "/var/lib/dpkg/info/$package.pre*" 2>/dev/null
	rm -f "/var/lib/dpkg/info/$package.post*" 2>/dev/null
	apt-get -y install -f >/dev/null
	if [ $? -ne 0 ]; then
		echo -e "$packageReparationFailed" 1>&2
	fi
fi
