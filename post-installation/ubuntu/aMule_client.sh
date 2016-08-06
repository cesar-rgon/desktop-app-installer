#!/bin/bash
##########################################################################
# This script configures aMule client to be ready to use.
# This one was compatible for both linux OS: Ubuntu and Debian.
# Debian 8 has removed amule package from stable repository.
# In a future version, if aMule come back to stable repository, this
# script will back to parent directory, it means, available for both
# linux OS.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/../.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"
mkdir -p /usr/share/amule/skins
cp $scriptRootFolder/icons/aMule-faenza-theme.zip /usr/share/amule/skins
