#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository to be able
# to install Xonotic game
# @author César Rodríguez González
# @version 1.3, 2016-08-09
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
repositoryURL="http://archive.getdeb.net/ubuntu"
repository="deb $repositoryURL xenial-getdeb games"
#repositorySource="deb-src $repositoryURL xenial-getdeb games"
repositoryFilename="getdeb-xonotic.list"

# Commands to add third-party repository of the application.
rm -f "/etc/apt/sources.list.d/$repositoryFilename"
wget -q -O - http://archive.getdeb.net/getdeb-archive.key | apt-key add -
echo "$repository" > "/etc/apt/sources.list.d/$repositoryFilename"
# Uncomment if needed [optional]
# echo "$repositorySource" >> "/etc/apt/sources.list.d/$repositoryFilename"
