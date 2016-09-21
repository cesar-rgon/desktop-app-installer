#!/bin/bash
##########################################################################

# Basic Variables
scriptRootFolder="`pwd`/.."; username="`whoami`"; homeFolder="$HOME"

# Import common variables and functions
. ../common/commonVariables.properties
. ../common/commonFunctions.sh
# Here goes application name. It must be identically (case-sensitive) to the application name defined in ../etc/applist/applicationList.(ubuntu/debian/linuxmint/lmde) file.
declare -a appsToInstall=( "applicationName" )

# Lauch menu and install selected applications
prepareScript "$0"
# Install all selected applications
installAndSetupApplications appsToInstall[@]
