#!/bin/bash
scriptRootFolder=`pwd`
. $scriptRootFolder/common/commonFunctions
. $scriptRootFolder/common/menuFunctions
logFile="linux-app-installer.log"

########################################################################################################################
# MAIN
########################################################################################################################
prepareScript "$scriptRootFolder" "$logFile"
if [ -n $DISPLAY ]; then
	notify-send -i shellscript "$linuxAppInstallerTitle" "$linuxAppInstallerCredits"
fi

appsToInstall=$(menu)
if [ "$appsToInstall" != "" ]; then
	if [ -n $DISPLAY ]; then
		notify-send -i applications-other "$linuxAppInstallerTitle" "$installingSelectedApplications"
	fi
	# Install all selected applications
	installAndSetupApplications "$appsToInstall"
fi
