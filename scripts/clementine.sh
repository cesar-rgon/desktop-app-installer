#!/bin/bash
scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions
appName="Clementine"
logFile="clementine.log"

########################################################################################################################
# MAIN
########################################################################################################################
prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications $appName
