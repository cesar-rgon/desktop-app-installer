#!/bin/bash
##########################################################################
# This script prepares Teamviewer application to be ready to be installed
# on 64 bits OS linux
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

# We must add a non-free repository to be able to install Steam
echo "deb http://httpredir.debian.org/debian/ jessie main contrib non-free" > /etc/apt/sources.list.d/steam.list

# We must add 32 bits architecture to be able to install Steam 32 bits in 64 bits OS
dpkg --add-architecture i386
