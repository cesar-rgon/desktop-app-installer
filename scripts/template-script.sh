#!/bin/bash

scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions.sh
# Here goes application name. It must be identically (case-sensitive) to the application name defined in ../etc/applicationList.ubuntu or ../etc/applicationList.debian file.
declare -a appsToInstall=( "applicationName" )
# Here goes log file name that will be created in ~/logs/logFile
logFile="fileName.log"

prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications appsToInstall[@]
