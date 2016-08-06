#!/bin/bash
##########################################################################

. ../common/commonVariables.properties "`pwd`/.."
. ../common/commonFunctions.sh
# Here goes application name. It must be identically (case-sensitive) to the application name defined in ../etc/applicationList.ubuntu or ../etc/applicationList.debian file.
declare -a appsToInstall=( "applicationName" )

prepareScript "$0"
if [ -n $DISPLAY ]; then
  notify-send -i "$installerIconFolder/applications-other.svg" "$linuxAppInstallerTitle" "$installingSelectedApplications"
fi
# Install all selected applications
installAndSetupApplications appsToInstall[@]
