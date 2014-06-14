#!/bin/bash
##########################################################################
# This script installs Sublime text application.
#
# Author: Isidro Rodríguez González and César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 09/06/2014
# Licence: MIT
##########################################################################
# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Commands to download, extract and install a non-repository application.
if [ `uname -m` == "x86_64" ]; then
  package="XnConvert-linux-x64.deb"
else
  package="XnConvert-linux.deb"
fi

wget -P /var/cache/apt/archives http://download.xnview.com/$package 2>&1
dpkg -i $package
apt-get -y install -f

