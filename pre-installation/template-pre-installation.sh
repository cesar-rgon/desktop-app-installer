#!/bin/bash

#########################################################################################
# Check if the script is being running by a root or sudoer user				#
#########################################################################################
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Add common variables
. ../common/commonVariables.sh "`pwd`/.."

#########################################################################################
# CONSIDERATIONS									#
# - No need to use 'sudo' because this script must be executed as root user.		#
# - No need to execute 'apt-get update' because main script will execute it.		#
# - This script must be non-interactive, this means, no interaction with user at all:	#
# 	* No echo to standard output (monitor)						#
#	* No read from standard input (keyboard)					#
#	* Use auto-confirm for commands. Example: apt-get -y install <package>		#
#	* etc.										#
#########################################################################################

# Commands to prepare the installation of an application ...
