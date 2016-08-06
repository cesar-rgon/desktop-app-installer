#!/bin/bash
##########################################################################
# This script setup default Debconf interface to use
# @author César Rodríguez González
# @since   1.3, 2016-08-06
# @version 1.3, 2016-08-06
# @license MIT
##########################################################################
#
# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

# Update repositories
apt-get update --fix-missing
