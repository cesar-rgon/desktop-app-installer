#!/bin/bash
##########################################################################
# This script setup default Debconf interface to use
# @author César Rodríguez González
# @since   1.3, 2016-08-06
# @version 1.3, 2016-08-09
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

# Update repositories
if [ -z "$DISPLAY" ]; then
  apt-get update --fix-missing
else
  xterm -T "$terminalProgress. $updatingRepositories" \
    -fa 'DejaVu Sans Mono' -fs 11 \
    -geometry 200x15+0-0 \
    -xrm 'XTerm.vt100.allowTitleOps: false' \
    -e "apt-get update --fix-missing"
fi
