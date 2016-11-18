#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
# @author 	César Rodríguez González
# @since 		1.3, 2016-07-31
# @version 	1.3, 2016-11-16
# @license 	MIT
##########################################################################

. $scriptRootFolder/menu/menuVariables.properties
if [ -z "$DISPLAY" ]; then
	. $scriptRootFolder/menu/dialogFunctions.sh
else
	if [ "$yadInstalled" == "true" ]; then
		. $scriptRootFolder/menu/yadFunctions.sh
	else
		. $scriptRootFolder/menu/zenityFunctions.sh
	fi
fi
