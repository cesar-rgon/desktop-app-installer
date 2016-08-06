#!/bin/bash
##########################################################################
# This script opens a Zenity window to ask admin password
# @author 	César Rodríguez González
# @since 		1.3, 2016-08-05
# @version 	1.3, 2016-08-05
# @license 	MIT
##########################################################################

# Add common variables
if [ -n "$1" ]; then scriptRoolFolder="$1"; else scriptRoolFolder="`pwd`/.."; fi
. $scriptRoolFolder/common/commonVariables.sh

zenity --password --title "$askAdminPassword"
