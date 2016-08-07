#!/bin/bash
##########################################################################
# This script starts the installation and configuration process of the
# specified application and finally it shows a log file which contains
# reported installation steps and posible errors.
# @author César Rodríguez González
# @version 1.3, 2016-08-07
# @license MIT
##########################################################################

. ../common/commonVariables.properties "`pwd`/.."
. ../common/commonFunctions.sh
declare -a appsToInstall=( "Bleachbit" )

prepareScript "$0"
# Install all selected applications
installAndSetupApplications appsToInstall[@]
