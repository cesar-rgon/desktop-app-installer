#!/bin/bash
##########################################################################
# This is the main script that executes a menu to select applications to
# install. After that, it starts the installation and configuration
# process and finally it shows a log file which contains reported
# installation steps and posible errors.
# @author 	César Rodríguez González
# @since 		1.0, 2014-04-29
# @version 	1.3, 2016-08-07
# @license 	MIT
##########################################################################

. ./common/commonVariables.properties "`pwd`"
. ./common/commonFunctions.sh
. ./menu/menuFunctions.sh

prepareScript "$0" --no-notification
declare -a appsToInstall=( $(menu) )
# Install all selected applications
installAndSetupApplications appsToInstall[@]
