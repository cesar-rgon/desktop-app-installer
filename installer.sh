#!/bin/bash
##########################################################################
# This is the main script that executes a menu to select applications to
# install. After that, it starts the installation and configuration
# process and finally it shows a log file which contains reported
# installation steps and posible errors.
# @author 	César Rodríguez González
# @since 		1.0, 2014-04-29
# @version 	1.3, 2016-08-05
# @license 	MIT
##########################################################################

. ./common/commonVariables.properties "`pwd`"
. ./common/commonFunctions.sh
. ./menu/menuFunctions.sh
declare -a appsToInstall=( $(menu) )

prepareScript "$0"
if [ -n $DISPLAY ]; then
	notify-send -i "$installerIconFolder/tux96.png" "$linuxAppInstallerTitle" "$linuxAppInstallerComment\n$linuxAppInstallerAuthor"
fi
if [ ${#appsToInstall[@]} -gt 0 ]; then
	if [ -n $DISPLAY ]; then
		notify-send -i "$installerIconFolder/applications-other.svg" "$linuxAppInstallerTitle" "$installingSelectedApplications"
	fi
	# Install all selected applications
	installAndSetupApplications appsToInstall[@]
fi
