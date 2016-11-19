#!/bin/bash
##########################################################################
# This is the main script that executes a menu to select installed
# applications to be uninstalled. After that, it starts the
# uninstallation process, remove all settings and finally it shows
# a log file which contains reported steps and posible errors.
# @author 	César Rodríguez González
# @since 		1.3, 2016-10-10
# @version 	1.3, 2016-11-19
# @license 	MIT
##########################################################################

# Basic Variables
scriptRootFolder="`pwd`"; username="`whoami`"; homeFolder="$HOME"

# Import common variables and functions
. $scriptRootFolder/common/commonFunctions.sh --uninstaller
prepareScript "$0"
. $scriptRootFolder/menu/menuFunctions.sh

# Lauch menu and uninstall selected applications
menu
declare -a appsToUninstall=(`cat "$tempFolder/selectedAppsFile" 2>/dev/null`)
uninstallAndPurgeApplications appsToUninstall[@]
