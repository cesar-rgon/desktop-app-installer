#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts
# @author 	César Rodríguez González
# @since 		1.0, 2014-05-10
# @version 	1.3, 2016-08-05
# @license 	MIT
##########################################################################

##
# This funtion installs dialog or zenity packages, if not installed yet,
# according to detected enviroment: desktop or terminal
# @since v1.0
##
function installNeededPackages
{
	if [ -z $DISPLAY ]; then
		if [ -z "`dpkg -s dialog 2>&1 | grep "installed"`" ]; then
			echo "$installingPackage dialog"
			sudo apt-get -y install dialog --fix-missing
		fi
	else
		local neededPackages sudoHundler sudoOption sudoPackage
		if [ "$KDE_FULL_SESSION" != "true" ]; then
			sudoHundler="gksudo"; sudoOption="-S"; sudoPackage="gksu"
		else
			sudoHundler="kdesudo"; sudoOption="-c"; sudoPackage="kdesudo"
		fi
		if [ -z "`dpkg -s $sudoPackage 2>&1 | grep "installed"`" ]; then
			echo "$needToInstallPackage $sudoPackage" > "$logFile"; echo "$needToInstallPackage $sudoPackage"
			notify-send -i "$installerIconFolder/applications-other.svg" "$linuxAppInstallerTitle" "$needToInstallPackage $sudoPackage" 2>>"$logFile";
			zenity --error --text="$needToInstallPackage $sudoPackage" --window-icon="$installerIconFolder/tux32.png" 2>>"$logFile"
			exit 1
		fi
		if [ -z "`dpkg -s zenity 2>&1 | grep "installed"`" ]; then
			neededPackages+="zenity"
		fi
		if [ -z "`dpkg -s libnotify-bin 2>&1 | grep "installed"`" ]; then
			if [ -n "$neededPackages" ]; then neededPackages+=" "; fi
			neededPackages+="libnotify-bin"
		fi
		if [ "$distro" == "ubuntu" ] && [ "$KDE_FULL_SESSION" == "true" ]; then
			# KDE needs to install Debconf dependencies.
			if [ -z "`dpkg -s libqtgui4-perl 2>&1 | grep "installed"`" ]; then
				if [ -n "$neededPackages" ]; then neededPackages+=" "; fi
				neededPackages+="libqtgui4-perl"
			fi
		fi
		if [ -n "$neededPackages" ]; then
			`$sudoHundler $sudoOption "apt-get -y install $neededPackages" 1>/dev/null 2>>"$logFile"`
		fi
	fi
}

##
# This funtion calls previous functions and creates needed folders and
# files used by installation script
# @since 	v1.3
# @param  String scriptPath Folder path to access main script root folder
# @return String 						path and log filename
##
function getLogFilename
{
	local scriptPath="$1"
	declare -ag splittedPath
	IFS='/' read -ra splittedPath <<< "$scriptPath"
	local numberItemsPath=${#splittedPath[@]}
	local scriptName=${splittedPath[$(($numberItemsPath-1))]}
	echo "$logsFolder/${scriptName/.sh/}-$snapshot.log"
}

##
# This funtion prepares main installer script to be executed
# @since v1.0
##
function prepareScript
{
	logFile=$( getLogFilename "$1" )
	# Create temporal folders and files
	mkdir -p "$tempFolder" "$logsFolder"
	rm -f "$logFile"

	installNeededPackages
	echo -e "$linuxAppInstallerTitle\n========================" > "$logFile"
}

##
# This funtion setup debconf from parameters read from an EULA file.
# Debconf is used to determinate if the window is displayed on terminal or desktop mode
# @since 	v1.0
# @param  String eulaFilename EULA file wich contains parameters to setup debconf
# @return String 							commands to setup debconf-set-selections
##
function setDebconfFromFile
{
	local eulaFilename="$1"
	local line lineWithoutSpaces debconfCommands
	# Read eula file ignoring comment and blank lines
	while read line; do
		lineWithoutSpaces=`echo $line | tr -d ' '`
		if [ -n "$lineWithoutSpaces" ] && [[ "$line" != "#"* ]]; then
			debconfCommands+="echo $line | debconf-set-selections 2>>\"$logFile\";"
		fi
	done < "$eulaFolder/$eulaFilename"
	echo $debconfCommands
}

##
# This function generates commands to execute subscripts during installation process
# @since 	v1.3
# @param  String targetFolder destination folder where subscript is placed
# @param  String appName 			application name refered by subscript
# @param  String message 			optional message to be showed in box/window
# @return String 							list of bash shell commands separated by ;
##
function generateCommands
{
	local targetFolder="$1" appName="$2" message="$3"
	local commands messageCommand

	if [ -n "$appName" ] && [ -n "$targetFolder" ]; then
		local i386="_i386" x64="_x64"

		if [ `uname -m` == "x86_64" ]; then
			# For 64 bits OS
			if [ -f "$targetFolder/$distro/$appName$x64.sh" ]; then
				commands+="bash \"$targetFolder/$distro/$appName$x64.sh\" \"$scriptRootFolder\" 2>>\"$logFile\""
			fi
			if [ -f "$targetFolder/$appName$x64.sh" ]; then
				commands+="bash \"$targetFolder/$appName$x64.sh\" \"$scriptRootFolder\" 2>>\"$logFile\""
			fi
		else
			# For 32 bits OS
			if [ -f "$targetFolder/$distro/$appName$i386.sh" ]; then
				commands+="bash \"$targetFolder/$distro/$appName$i386.sh\" \"$scriptRootFolder\" 2>>\"$logFile\""
			fi
			if [ -f "$targetFolder/$appName$i386.sh" ]; then
				commands+="bash \"$targetFolder/$appName$i386.sh\" \"$scriptRootFolder\" 2>>\"$logFile\""
			fi
		fi
		# For all CPU arquitectures
		if [ -f "$targetFolder/$distro/$appName.sh" ]; then
			commands+="bash \"$targetFolder/$distro/$appName.sh\" \"$scriptRootFolder\" 2>>\"$logFile\""
		fi
		if [ -f "$targetFolder/$appName.sh" ]; then
			commands+="bash \"$targetFolder/$appName.sh\" \"$scriptRootFolder\" 2>>\"$logFile\""
		fi
		if [ -n "$message" ]; then
			if [ -z $DISPLAY ]; then
				local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
				commands+="| dialog --title \"$message $appName ...\" --backtitle \"$backtitle\" --progressbox $dialogHeight $dialogWidth"
			fi
			messageCommand="echo \"# $message $appName\"; echo \"$message $appName ...\" >> \"$logFile\";"
		fi
		commands+=";"
	fi
	if [ -n "$commands" ]; then	echo "$messageCommand $commands"; else echo ""; fi
}

##
# This funtion generates commands to install packages of applications from
# default or third-party repositories
# @since 	v1.3
# @return String 				List of bash shell commands separated by ;
##
function generateCommandsInstallRepoPackages
{
	local totalApplicationsToInstall=${#packagestoInstallPerApplication[@]}
	local totalPackagesToInstall=`echo "${packagestoInstallPerApplication[@]}" | wc -w`
	local indexA=1 indexP=1 appName package commands

	for appName in ${!packagestoInstallPerApplication[@]}; do
		for package in ${packagestoInstallPerApplication[$appName]}; do
			# If application or package has EULA
			if [ -f "$eulaFolder/$appName" ] || [ -f "$eulaFolder/$package" ]; then
				if [ -z $DISPLAY ]; then commands+="clear;"; fi
				# Delete previous Debconf configuration
				commands+="echo \"# $removeOldDebconfConfiguration $package\"; echo \"$removeOldDebconfConfiguration $package...\" >> \"$logFile\";"
				commands+="echo PURGE | debconf-communicate $package 2>>\"$logFile\";"
				# Set default Debconf configuration
				commands+="echo \"# $setNewDebconfConfiguration $package\"; echo \"$setNewDebconfConfiguration $package...\" >> \"$logFile\";"
				commands+="bash -c \"$( setDebconfFromFile $package )\";"
			fi
			commands+="echo -e \"# $installingApplication $indexA/$totalApplicationsToInstall: $appName\n$installingPackage $indexP/$totalPackagesToInstall: $package\"; echo \"$installingPackage $package\" >> \"$logFile\";"
			commands+="bash \"$scriptRootFolder/common/installapp.sh\" \"$package\" 2>>\"$logFile\""
			if [ -z $DISPLAY ]; then
				local title="$installingPackage $indexP/$totalPackagesToInstall: $package"
				local backtitle="$installingApplication $indexA/$totalApplicationsToInstall: $appName"
				commands+="| dialog --title \"$title\" --backtitle \"$backtitle\" --progressbox $dialogHeight $dialogWidth"
			fi
			commands+=";"
			indexP=$(($indexP+1))
		done
		indexA=$(($indexA+1))
	done
	echo "$commands"
}

##
# This funtion generates commands to setup Debconf interface for accept terms
# of application use (EULA)
# @since 	v1.3
# @return String 				List of bash shell commands separated by ;
##
function generateCommandsDebconf
{
	# Set default Debconf interface to use
	local commands="echo \"# $settingDebconfInterface\"; echo \"$settingDebconfInterface ...\" >> \"$logFile\";"
	commands+="echo debconf debconf/frontend select $debconfInterface | debconf-set-selections 2>>\"$logFile\""
	if [ -z $DISPLAY ]; then
		local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
		commands+="| dialog --title \"$settingDebconfInterface\" --backtitle \"$backtitle\" --progressbox $dialogHeight $dialogWidth"
	fi
	commands+=";"
	echo "$commands"
}

##
# This funtion generates commands to update repositories
# @since 	v1.3
# @return String 				List of bash shell commands separated by ;
##
function generateCommandsUpdateRepositories
{
	local commands="echo \"# $updatingRepositories\"; echo \"$updatingRepositories ...\" >> \"$logFile\";"
	commands+="apt-get update --fix-missing 2>>\"$logFile\""
	if [ -z $DISPLAY ]; then
		local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
		commands+="| dialog --title \"$updatingRepositories\" --backtitle \"$backtitle\" --progressbox $dialogHeight $dialogWidth"
	fi
	commands+=";"
	echo "$commands"
}

##
# This funtion generates commands to execute final operations: clean, etc.
# @since 	v1.3
# @return String 				List of bash shell commands separated by ;
##
function generateCommandsFinalOperations
{
	# Delete temp files and packages
	local commands="echo \"# $cleaningTempFiles\"; echo \"$cleaningTempFiles ...\" >> \"$logFile\";"
	local cleanTempFilesCommands="apt-get -y autoremove 2>>\"$logFile\"; apt-get clean 2>>\"$logFile\"; rm -rf \"$tempFolder\";"
	commands+="bash -c \"$cleanTempFilesCommands\""
	if [ -z $DISPLAY ]; then
		local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
		commands+="| dialog --title \"$cleaningTempFiles ...\" --backtitle \"$backtitle\" --progressbox $dialogHeight $dialogWidth"
	fi
	commands+=";"

	commands+="echo \"# $installationFinished\"; echo \"$installationFinished\" >> \"$logFile\";"
	# Change ownership of log file
	commands+="chown $username:$username \"$logFile\" 2>>\"$logFile\""
	echo "$commands"
}

##
# This funtion executes commands to install a set of applications
# @since v1.0
# @param String commands 	List of bash shell commands separated by ;
##
function executeCommands
{
	local commands="$1"
	if [ -n "commands" ]; then
		if [ -z $DISPLAY ]; then
			clear; sudo bash -c "$commands"
			dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $dialogHeight $dialogWidth
		else
			# Ask for admin password to execute script like sudoer user
			( SUDO_ASKPASS="bash -c \"$scriptRootFolder/common/askpass.sh\"" sudo -A bash -c "$commands" ) |
			zenity --progress --title="$linuxAppInstallerTitle" --no-cancel --pulsate --width=$zenityWidth --window-icon="$installerIconFolder/tux32.png"
			# Show notification and log
			notify-send -i "$installerIconFolder/logviewer.svg" "$linuxAppInstallerTitle" "$logFileLocation\n$logFile"
			zenity --text-info --title="$linuxAppInstallerTitle Log" --filename="$logFile" --width=$zenityWidth --height=$zenityHeight --window-icon="$installerIconFolder/tux32.png"
		fi
	fi
}

##
# This funtion generates and executes bash commands to install a
# set of applications
# @since v1.0
# @param String[] appsToInstall	 List of applications to be installed
##
function installAndSetupApplications
{
	declare -ag appsToInstall=("${!1}")
	if [ ${#appsToInstall[@]} -gt 0 ]; then
		local repoCommands preInstallationCommands nonRepoAppCommands postInstallationCommands appName apps

		for appName in ${appsToInstall[@]}; do
			repoCommands+=$( generateCommands "$thirdPartyRepoFolder" "$appName" "$addingThirdPartyRepo" )
			preInstallationCommands+=$( generateCommands "$preInstallationFolder" "$appName" "$preparingInstallationOf" )
			if [ -z $DISPLAY ]; then nonRepoAppCommands+="clear;"; fi
			nonRepoAppCommands+=$( generateCommands "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApp" )
			postInstallationCommands+=$( generateCommands "$postInstallationFolder" "$appName" "$settingUpApplication" )

			# Delete blank and comment lines,then filter by application name and take package list (third column forward to the end)
			apps=`cat $appListFile | awk -v app=$appName '!/^($|#)/{if ($2 == app) for(i=3;i<=NF;i++)printf "%s",$i (i==NF?ORS:OFS)}'`
			packagestoInstallPerApplication[$appName]=`echo "$apps"`
		done

		local commands=$( generateCommandsDebconf )
		commands+="$repoCommands $preInstallationCommands"
		commands+=$( generateCommandsUpdateRepositories )
		commands+=$( generateCommandsInstallRepoPackages )
		commands+="$nonRepoAppCommands $postInstallationCommands"
		commands+=$( generateCommandsFinalOperations )

		executeCommands "$commands"
	fi
}
