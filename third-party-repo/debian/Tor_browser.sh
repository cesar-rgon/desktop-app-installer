#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of 
# Tor browser application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 17/07/2016
# Licence: MIT
##########################################################################

# Variables
distroName="$(lsb_release -sc)"
repositoryURL="http://ppa.launchpad.net/webupd8team/tor-browser/ubuntu"
#repository="deb $repositoryURL $distroName main"
#repositorySource="deb-src $repositoryURL $distroName main"
targetFilename="*tor-browser*.list"

# Pre-requisites
apt-get -y install debian-keyring 1>/dev/null 2>/dev/null
# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	# Commands to import repository key
	gpg --keyserver keyserver.ubuntu.com --recv-key EEA14886
	gpg --armor --export EEA14886 | apt-key add -
	# Commands to add repository URL
	echo "deb $repositoryURL xenial main" > /ect/apt/sources.list.d/webupd8team-tor-browser.list
	echo "deb-src $repositoryURL xenial main" >> /ect/apt/sources.list.d/webupd8team-tor-browser.list
fi 2>/dev/null

