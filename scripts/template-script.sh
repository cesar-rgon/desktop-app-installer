#!/bin/bash
scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions.sh
appName=""  # Here goes application name. It must be identically (case-sensitive) to the application name defined in ../etc/applicationList file.
logFile=""  # Here goes log file name that will be created in ~/logs/logFile

prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications $appName
