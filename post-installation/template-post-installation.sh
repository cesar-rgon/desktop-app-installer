#!/bin/bash

#########################################################################################
# Check if the script is being running by a root or sudoer user				            #
#########################################################################################
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties
# Uncomment if authentication is required
#. $credentialFolder/applicationName.properties

#########################################################################################
# CONSIDERATIONS									                                    #
# - No need to use 'sudo' because this script must be executed as root user.		    #
# - This script must be non-interactive, this means, no interaction with user at all:	#
# 	* No echo to standard output (monitor)						                        #
#	* No read from standard input (keyboard)					                        #
#	* Use auto-confirm for commands. Example: apt install -y <package>	                #
#	* etc.										                                        #
#########################################################################################

# Commands to setup an installed application ...
