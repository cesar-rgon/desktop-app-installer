#!/bin/bash
##########################################################################
# This script installs Grub Customizer application.
#
# Author: César Rodríguez González
# Version: 1.11
# Last modified date (dd/mm/yyyy): 18/05/2014
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
if [ "`uname -i`" == "i686" ]; then
	grubCustomizerFile="grub-customizer_4.0.6-0ubuntu1~ppa1t_i386.deb"
else
	grubCustomizerFile="grub-customizer_4.0.6-0ubuntu1~ppa1t_amd64.deb"
fi
grubCustomizerURL="https://launchpad.net/~danielrichter2007/+archive/grub-customizer/+files/$grubCustomizerFile"
wget -P /var/cache/apt/archives $grubCustomizerURL 2>&1
dpkg -i /var/cache/apt/archives/$grubCustomizerFile
apt-get -y install -f
