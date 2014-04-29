#!/bin/bash
scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions
appName="Shutter"
logFile="shutter.log"

########################################################################################################################
# MAIN
########################################################################################################################
prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications $appName
