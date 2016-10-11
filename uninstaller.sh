#!/bin/bash
##########################################################################
# This is the main script that executes a menu to select installed
# applications to be uninstalled. After that, it starts the
# uninstallation process, remove all settings and finally it shows
# a log file which contains reported steps and posible errors.
# @author 	César Rodríguez González
# @since 		1.3, 2016-10-10
# @version 	1.3, 2016-10-11
# @license 	MIT
##########################################################################

# Basic Variables
scriptRootFolder="`pwd`"; username="`whoami`"; homeFolder="$HOME"

# Import common variables and functions
. ./common/commonVariables.properties
. ./common/commonFunctions.sh
. ./menu/menuFunctions.sh

# Lauch menu and uninstall selected applications
prepareScript "$0"
declare -a appsToUninstall=( $(menu --only-show-installed-repo-apps) )
uninstallAndPurgeApplications appsToUninstall[@]
