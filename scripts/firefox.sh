#!/bin/bash
scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions
appName="Firefox"
logFile="firefox.log"

########################################################################################################################
# MAIN
########################################################################################################################
prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications $appName
