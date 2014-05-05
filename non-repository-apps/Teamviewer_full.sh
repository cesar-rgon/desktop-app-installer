#!/bin/bash
##########################################################################
# This script installs Teamviewer full support application.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
. ../common/commonVariables.sh

# Download Teamviewer full. Always 32 bits deb because 64 bits version has broken dependencies
wget -O /tmp/teamviewer_linux.deb http://download.teamviewer.com/download/teamviewer_linux.deb 2>&1
# Install application
dpkg -i /tmp/teamviewer_linux.deb
# Extract teamviewer icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/teamviewer.tar.gz"

# No need to execute this command. The main script already execute it at the end of the installation proccess.
# apt-get install -f
