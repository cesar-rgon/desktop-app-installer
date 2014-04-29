#!/bin/bash
scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions
appName="Skype"
logFile="skype.log"

########################################################################################################################
# MAIN
########################################################################################################################
prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications $appName
