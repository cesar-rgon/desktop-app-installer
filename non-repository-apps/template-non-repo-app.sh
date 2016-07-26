#!/bin/bash

#########################################################################################
# Check if the script is being running by a root or sudoer user				#
#########################################################################################
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi


#########################################################################################
# Common variables supplied by main script.   						#
# See file scriptRootFolder/common/commonVariables.sh 					#
# for a complete list of variables  							#
#########################################################################################
scriptRootFolder="`cat /tmp/linux-app-installer-scriptRootFolder`"
. $scriptRootFolder/common/commonVariables.sh


#########################################################################################
# CONSIDERATIONS									#
# - No need to use 'sudo' because this script must be executed as root user.		#
# - This script must be non-interactive, this means, no interaction with user at all:	#
# 	* No echo to standard output (monitor)						#
#	* No read from standard input (keyboard)					#
#	* Use auto-confirm for commands. Example: apt-get -y install <package>		#
#	* etc.										#
#########################################################################################

# Commands to download, extract and install a non-repository application ...

