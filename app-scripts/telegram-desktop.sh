#!/bin/bash
##########################################################################
# This script starts the installation and configuration process of the
# specified application and finally it shows a log file which contains
# reported installation steps and posible errors.
# @author César Rodríguez González
# @version 1.4, 2018-03-17
# @license MIT
##########################################################################

# Basic Variables
scriptRootFolder="`pwd`/.."; username="`whoami`"; homeFolder="$HOME"

# Import common variables and functions
. $scriptRootFolder/common/commonFunctions.sh
declare -a appsToInstall=( "Telegram-Desktop" )

# Lauch menu and install selected applications
prepareScript "$0"
installAndSetupApplications appsToInstall[@]
