#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Grub
# Customizer application.
# @author César Rodríguez González
# @version 1.3, 2016-09-25
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/../.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Variables
repositoryURL="http://ppa.launchpad.net/danielrichter2007/grub-customizer/ubuntu"
#repository="deb $repositoryURL $distroName main"
#repositorySource="deb-src $repositoryURL $distroName main"
repositoryFilename="danielrichter2007-grub-customizer*.list"

# Commands to add third-party repository of the application.
rm -f "/etc/apt/sources.list.d/$repositoryFilename"
apt-get -y install xterm
xterm -e "add-apt-repository -y ppa:danielrichter2007/grub-customizer"
