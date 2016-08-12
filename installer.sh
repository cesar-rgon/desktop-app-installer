#!/bin/bash
##########################################################################
# This is the main script that executes a menu to select applications to
# install. After that, it starts the installation and configuration
# process and finally it shows a log file which contains reported
# installation steps and posible errors.
# @author 	César Rodríguez González
# @since 		1.0, 2014-04-29
# @version 	1.3, 2016-08-12
# @license 	MIT
##########################################################################

# Basic Variables
scriptRootFolder="`pwd`"; username="`whoami`"; homeFolder="$HOME"

# Import common variables and functions
. ./common/commonVariables.properties
. ./common/commonFunctions.sh
. ./menu/menuFunctions.sh

# Lauch menu and install selected applications
prepareScript "$0"
declare -a appsToInstall=( $(menu) )
installAndSetupApplications appsToInstall[@]
