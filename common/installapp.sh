#!/bin/bash
##########################################################################
# This script check if an error has ocurred during installation process of
# an application package. If so, apply contingence measure.
# @author 	César Rodríguez González
# @since 		1.3, 2016-07-28
# @version 	1.3, 2016-08-19
# @license 	MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo "" 1>&2; echo "This script must be executed by a root or sudoer user" 1>&2; echo "" 1>&2; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi
appName="$4"
# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Get application packages: Delete blank and comment lines,then filter by application name and take package list (third column forward to the end)
packageList=`cat $appListFile | awk -v app=$appName '!/^($|#)/{if ($2 == app) for(i=3;i<=NF;i++)printf "%s",$i (i==NF?ORS:OFS)}'`

if [ -n "$packageList" ]; then
	totalPackagesToInstall=`echo "$packageList" | wc -w`

	for package in "$packageList"; do
		# If application has EULA
		if [ -f "$eulaFolder/$appName" ]; then
			# Delete previous Debconf configuration
			echo PURGE | debconf-communicate $package
			# Setup debconf from parameters read from an EULA file. Debconf is used to determinate if the window is displayed on terminal or desktop mode
			while read line; do
				lineWithoutSpaces=`echo $line | tr -d ' '`
				if [ -n "$lineWithoutSpaces" ] && [[ "$line" != "#"* ]]; then
					debconfCommands+="echo $line | debconf-set-selections;"
				fi
			done < "$eulaFolder/$appName"
			bash -c "$debconfCommands"
		fi
	  # Install package
		apt-get -y install $package --fix-missing
		if [ $? -ne 0 ]; then
			echo -e "$packageInstallFailed ..." 1>&2
			# Error installing package. Applying contingence measure
			rm /var/lib/dpkg/info/$package.pre* 2>/dev/null
			rm /var/lib/dpkg/info/$package.post* 2>/dev/null
		fi
		apt-get -y install -f >/dev/null
	done
fi
