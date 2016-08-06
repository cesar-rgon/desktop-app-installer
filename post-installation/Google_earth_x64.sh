#!/bin/bash
##########################################################################
# This script install Google Earth application.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Commands to setup an installed application
mkdir /tmp/google_earth_package
cd /tmp/google_earth_package
dpkg --add-architecture i386
make-googleearth-package --force --quiet
gdebi --n /tmp/google_earth_package/googleearth*.deb
