#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository of Etcher
# application.
# @author César Rodríguez González
# @version 1.3.4, 2017-11-26
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Install needed packages
apt install -y dirmngr apt-transport-https

repositoryFilename="etcher.list"
# Commands to add third-party repository of the application.
rm -f "/etc/apt/sources.list.d/$repositoryFilename"
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 379CE192D401AB61
echo "deb https://dl.bintray.com/resin-io/debian stable etcher" > "/etc/apt/sources.list.d/$repositoryFilename"
#echo "deb https://dl.bintray.com/resin-io/debian stable etcher" >> "/etc/apt/sources.list.d/$repositoryFilename"
