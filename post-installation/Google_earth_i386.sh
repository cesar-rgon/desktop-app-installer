#!/bin/bash
##########################################################################
# This script install Google Earth application.
# @author César Rodríguez González
# @version 1.3, 2016-08-07
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
. $scriptRootFolder/common/commonVariables.properties

# Commands to setup an installed application
mkdir /tmp/google_earth_package
cd /tmp/google_earth_package
make-googleearth-package --force --quiet 2>/dev/null
gdebi --n /tmp/google_earth_package/googleearth*.deb
