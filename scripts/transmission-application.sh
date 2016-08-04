#!/bin/bash
##########################################################################
# This script starts the installation and configuration process of the
# specified application and finally it shows a log file which contains
# reported installation steps and posible errors.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 04/08/2016
# Licence: MIT
##########################################################################

. ../common/commonVariables.sh "`pwd`/.."
. ../common/commonFunctions.sh
declare -a appsToInstall=( "Transmission_application" )

prepareScript "$0"
if [ -n $DISPLAY ]; then
  notify-send -i "$installerIconFolder/applications-other.svg" "$linuxAppInstallerTitle" "$installingSelectedApplications"
fi
# Install all selected applications
installAndSetupApplications appsToInstall[@]
