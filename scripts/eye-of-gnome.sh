#!/bin/bash
##########################################################################
# This script starts the installation and configuration process of the
# specified application and finally it shows a log file which contains
# reported installation steps and posible errors.
# @author César Rodríguez González
# @version 1.3, 2016-08-05
# @license MIT
##########################################################################

. ../common/commonVariables.properties "`pwd`/.."
. ../common/commonFunctions.sh
declare -a appsToInstall=( "Eye_of_Gnome" )

prepareScript "$0"
if [ -n $DISPLAY ]; then
  notify-send -i "$installerIconFolder/applications-other.svg" "$linuxAppInstallerTitle" "$installingSelectedApplications"
fi
# Install all selected applications
installAndSetupApplications appsToInstall[@]
