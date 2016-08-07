#!/bin/bash
##########################################################################
# This script installs Sublime text application.
# @author Isidro Rodríguez González and César Rodríguez González
# @version 1.3, 2016-08-07
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
. $scriptRootFolder/common/commonVariables.properties

# Commands to download, extract and install a non-repository application.
if [ `uname -m` == "x86_64" ]; then
  package="XnConvert-linux-x64.deb"
else
  package="XnConvert-linux.deb"
fi

wget -P /var/cache/apt/archives http://download.xnview.com/$package 2>&1
dpkg -i /var/cache/apt/archives/$package
apt-get -y install -f
