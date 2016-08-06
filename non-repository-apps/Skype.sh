#!/bin/bash
##########################################################################
# This script installs Skype application.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Commands to download, extract and install a non-repository application.
skypeURL="http://www.skype.com/go/getskype-linux-deb"
wget -O /var/cache/apt/archives/skype.deb $skypeURL 2>&1
gdebi --n /var/cache/apt/archives/skype.deb
apt-get -y install -f
