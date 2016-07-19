#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository to be able
# to install Xonotic game
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 19/07/2016
# Licence: MIT
##########################################################################

# Variables
distroName="$(lsb_release -sc)"
repositoryURL="http://archive.getdeb.net/ubuntu"
repository="deb $repositoryURL xenial-getdeb games"
#repositorySource="deb-src $repositoryURL xenial-getdeb games"
targetFilename="getdeb.list"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	# Command to add repository key if needed
	wget -q -O - http://archive.getdeb.net/getdeb-archive.key | apt-key add -
	echo "$repository" > "/etc/apt/sources.list.d/$targetFilename"
fi
