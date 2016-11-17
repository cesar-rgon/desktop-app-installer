#!/bin/bash
##########################################################################
# This is the main script that executes a menu to select applications to
# install. After that, it starts the installation and configuration
# process and finally it shows a log file which contains reported
# installation steps and posible errors.
# @author 	César Rodríguez González
# @since 		1.0, 2014-04-29
# @version 	1.3, 2016-11-17
# @license 	MIT
##########################################################################

# Basic Variables
scriptRootFolder="`pwd`"; username="`whoami`"; homeFolder="$HOME"

. $scriptRootFolder/common/commonFunctions.sh
prepareScript "$0"
. $scriptRootFolder/menu/menuFunctions.sh

# Lauch menu and install selected applications
menu
declare -a appsToInstall=(`cat "$tempFolder/selectedAppsFile"`)
installAndSetupApplications appsToInstall[@]
