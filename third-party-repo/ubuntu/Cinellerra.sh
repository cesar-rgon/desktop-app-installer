#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Grub
# Customizer application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 15/07/2016
# Licence: MIT
##########################################################################

# Variables
distroName="$(lsb_release -sc)"
repositoryURL="http://ppa.launchpad.net/cinelerra-ppa/ppa/ubuntu"
#repository="deb $repositoryURL $distroName main"
#repositorySource="deb-src $repositoryURL $distroName main"
targetFilename="cinelerra*.list"

# Commands to add third-party repository of the application.
if ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename"; then
	add-apt-repository -y ppa:cinelerra-ppa/ppa 2>&1
fi
