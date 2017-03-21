#!/bin/bash
##########################################################################
# This script uninstall an application
# @author 	César Rodríguez González
# @since 		1.3, 2016-10-10
# @version 	1.3, 2016-10-10
# @license 	MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo "" 1>&2; echo "This script must be executed by a root or sudoer user" 1>&2; echo "" 1>&2; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi
if [ -n "$4" ]; then
	appName="$4"
	# Add common variables
	. $scriptRootFolder/common/commonVariables.properties

	# Get application packages: Delete blank and comment lines,then filter by application name and take package list (third column)
	packageList=`cat $appListFile | awk -v app=$appName '!/^($|#)/{ if ($2 == app) print $3; }' | tr '|' ' '`
	if [ -n "$packageList" ]; then
		apt purge -y $packageList;
	fi
fi
