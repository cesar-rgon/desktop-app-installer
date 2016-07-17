#!/bin/bash
# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

################################################
#                                              #
# Common variables supplied by main script:    #
#                                              #
# username: system username                    #
# tempFolder: main script temporal folder      #
# homeFolder: user's home folder               #
# scriptRootFolder: root folder of main script #
# homeDownloadFolder: user's download folder   #
#                                              #
################################################

# - No need to use 'sudo' because this script must be executed as root user.
# - This script must be non-interactive, this means, no interaction with user at all:
# 	* No echo to standard output (monitor)
#	* No read from standard input (keyboard)
#	* Use auto-confirm for commands. Example: apt-get -y install <package>
#	* etc.

# Variables
distroName="$(lsb_release -sc)"
repositoryURL="..."
repository="deb $repositoryURL <parameters>"
repositorySource="deb-src $repositoryURL <parameters>"
targetFilename="destinationFilename"

# Commands to add third-party repository of the application.
if [ ! -f "/etc/apt/sources.list.d/$targetFilename" ] || [ ! grep -q "$repositoryURL" "/etc/apt/sources.list.d/$targetFilename" ]; then
	# Command to add repository key if needed
	# ...
	echo "$repository" >> "/etc/apt/sources.list.d/$targetFilename"
	# Uncomment if needed [optional]
	# echo "$repositorySource" >> "/etc/apt/sources.list.d/$targetFilename"
fi 2>/dev/null

