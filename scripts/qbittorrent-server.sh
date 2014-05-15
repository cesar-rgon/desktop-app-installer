#!/bin/bash
##########################################################################
# This script starts the installation and configuration process of the
# specified application and finally it shows a log file which contains
# reported installation steps and posible errors.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 15/05/2014
# Licence: MIT
##########################################################################

scriptRootFolder=`pwd`/..
. $scriptRootFolder/common/commonFunctions.sh
appName="qBittorrent_server"
logFile="qbittorrent-server.log"

prepareScript "$scriptRootFolder" "$logFile"
installAndSetupApplications $appName
