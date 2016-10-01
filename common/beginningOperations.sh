#!/bin/bash
##########################################################################
# This script setup default Debconf interface to use
# @author César Rodríguez González
# @since   1.3, 2016-08-06
# @version 1.3, 2016-10-02
# @license MIT
##########################################################################
#
# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Set default Debconf interface to use
echo debconf debconf/frontend select $debconfInterface | debconf-set-selections

echo "$distro" > /home/cesar/debug
# Debian based O.S. patch. Disable "http://security.debian.org/" repositories while installation proccess to avoid package dependecy problems.
if [ "$distro" == "debian" ] || [ "$distro" == "lmde" ]; then
	url="http://security.debian.org"
	securityFileList=( `grep -r "$url" /etc/apt | awk -F : '{print $1}' | uniq` )
	sed -i "s/deb ${url//\//\\/}/#deb ${url//\//\\/}/g" ${securityFileList[@]} 2>/dev/null
	sed -i "s/deb-src ${url//\//\\/}/#deb-src ${url//\//\\/}/g" ${securityFileList[@]} 2>/dev/null
	sudo apt-get update
fi

