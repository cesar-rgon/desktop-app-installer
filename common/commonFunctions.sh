#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts
# @author 	César Rodríguez González
# @since 	1.0, 2014-05-10
# @version 	1.3, 2016-08-09
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
			echo "$installingApplication Dialog"
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
			echo "$installingApplication $sudoPackage"
			sudo apt-get -y install $sudoPackage --fix-missing
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
# This funtion sets application log file
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
	echo "${scriptName/.sh/}-$snapshot.log"
}

##
# This funtion prepares main installer script to be executed
# Creates needed folders and files used by installation script
# @since v1.0
##
function prepareScript
{
	if [ -n $DISPLAY ] && [ "$3" != "--no-notification" ]; then notify-send -i "$installerIconFolder/tux96.png" "$linuxAppInstallerTitle" "$testedOn\n$testedOnDistros" -t 10000; fi

	echo "$2" > "$tempFolder/linux-app-installer-info"
	echo "`whoami`" >> "$tempFolder/linux-app-installer-info"
	echo "$HOME" >> "$tempFolder/linux-app-installer-info"

	logFilename=$( getLogFilename "$1" )
	logFile="$logsFolder/$logFilename"
	# Create temporal folders and files
	mkdir -p "$tempFolder" "$logsFolder"
	rm -f "$logFile"

	installNeededPackages
	echo -e "$linuxAppInstallerTitle\n========================" > "$logFile"
}

##
# This function gets all existing subscripts that matches following requisites:
# 1. Filename must be: appName.sh / appName_x64.sh / appName_i386.sh
# 2. Filename must match O.S. arquitecture (*_i386 32bits / *_x64 64bits / other all)
# 3. Must be placed in targetFolder or the subfolder that matchs your linux distro
# @since 	v1.3
# @param 	String targetFolder	Root scripts folder
# @param 	String appName			Name of an application
# @result String 							List of path/filename of found subscripts
##
function getAppSubscripts
{
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo ""			# All parameters are mandatories
	else
		local targetFolder="$1" appName="$2"
		local i386="_i386" x64="_x64" subscriptList
		# Search subscript that matches all O.S. architecture
		if [ -f "$targetFolder/$appName.sh" ]; then subscriptList+="$targetFolder/$appName.sh "; fi
		if [ -f "$targetFolder/$distro/$appName.sh" ]; then subscriptList+="$targetFolder/$distro/$appName.sh "; fi
		if [ `uname -m` == "x86_64" ]; then
			# Search subscript that matches 64 bits O.S. architecture
			if [ -f "$targetFolder/$appName$x64.sh" ]; then subscriptList+="$targetFolder/$appName$x64.sh "; fi
			if [ -f "$targetFolder/$distro/$appName$x64.sh" ]; then subscriptList+="$targetFolder/$distro/$appName$x64.sh "; fi
		else
			# Search subscript that matches 32 bits O.S. architecture
			if [ -f "$targetFolder/$appName$i386.sh" ]; then subscriptList+="$targetFolder/$appName$i386.sh "; fi
			if [ -f "$targetFolder/$distro/$appName$i386.sh" ]; then subscriptList+="$targetFolder/$distro/$appName$i386.sh "; fi
		fi
		echo "$subscriptList"
	fi
}

##
# This function generates bash commands to execute a specified subscript during
# installation process. The subscript can be referenced by an application name
# or directly by script-name.sh
# @since 	v1.3
# @param String targetFolder	Destination folder where is placed the script [mandatory]
# @param String name				 	Name of application or subscript to be executed [mandatory]
#		- if name=identifier is considered as an application name
#		- if name=identifier.sh is considered as a subscript filename
# @param String message				Message to be showed in box/window [mandatory]
# @param String argument			Argument passed to name script [optional]
# @return String 							list of bash shell commands separated by ;
##
function generateCommands
{
	if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
		echo ""			# All parameters are mandatories
	else
		# Get parameters and initialize variables
		local targetFolder="$1" message="$3" commands messageCommand
		if [[ "$2" == *.sh ]]; then			# Name is a script filename
			if [ -f "$targetFolder/$2" ]; then
				local argument="$4" msg="echo \"# $message\"; echo \"$message\" >> \"$logFile\";"
				local cmd="bash \"$targetFolder/$2\" \"$scriptRootFolder\" \"$argument\" 2>>\"$logFile\";"
			fi
		else														# Name is an application name
			local appName="$2" msg cmd
			declare -ag scriptList=( $( getAppSubscripts "$targetFolder" "$appName" ) )
			# Iterate through all subscript files
			for script in "${scriptList[@]}"; do
				cmd+="bash \"$script\" \"$scriptRootFolder\" 2>>\"$logFile\";"
				msg+="echo \"# $message $appName\"; echo \"$message $appName\" >> \"$logFile\";"
			done
		fi
		if [ -f "$eulaFolder/$argument" ] || [ -f "$eulaFolder/$appName" ]; then
			commandsPerInstallationStep[eulaApp]+="$msg $cmd"
		else
			messageCommand+="$msg"
			commands+="$cmd"
		fi
		if [ -n "$commands" ]; then echo "$messageCommand $commands"; else echo ""; fi
	fi
}

##
# This funtion executes commands to install a set of applications
# @since v1.0
# @param Map<String,String> commandsPerInstallationStep 	Shell commands per installation steps [global]
# 	Keys of installation steps are:
# 		commandsDebconf				First step. Commands to setup interface to show terms of application
# 		thirdPartyRepo				Second step. Commands to add all third-party repositories needed
# 		preInstallation				Third step. Commands to prepare installation of some applications
# 		updateRepo						Fouth step. Commands to update repositories
# 		installRepoPackages		Fifth step. Commands to install applications from repositories
# 		installNonRepoApps		Sixth step. Commands to install non-repository applications
#		  eulaApp								Seventh step (only terminal mode). Commands to install apps with eula
# 		postInstallation			Next step. Commands to setup some applications to be ready to use
# 		finalOperations				Final step. Final operations: clean packages, remove temp.files, etc
##
function executeCommands
{
	if [ -z $DISPLAY ]; then
		local totalRepoAppsToInstall = `echo "${#commandsPerInstallationStep[installRepoPackages]}" | wc -w`
		local totalNonRepoAppsToInstall = `echo "${#commandsPerInstallationStep[installNonRepoApps]}" | wc -w`
		local totalEulaAppsToInstall = `echo "${#commandsPerInstallationStep[eulaApp]}" | wc -w`

		clear; sudo bash -c "${commandsPerInstallationStep[commandsDebconf]}" | dialog --title "$settingDebconfInterface" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[thirdPartyRepo]}" | dialog --title "$addingThirdPartyRepos" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[preInstallation]}" | dialog --title "$preparingInstallationApps" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[updateRepo]}" | dialog --title "$updatingRepositories" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[installRepoPackages]}" | dialog --title "$installingApplications $totalRepoAppsToInstall" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[installNonRepoApps]}" | dialog --title "$installingNonRepoApps $totalNonRepoAppsToInstall" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; echo "\n### $installingEulaApps $totalEulaAppsToInstall ###\n\n"; sudo bash -c "${commandsPerInstallationStep[eulaApp]}"
		clear; sudo bash -c "${commandsPerInstallationStep[postInstallation]}" | dialog --title "$settingUpApplications" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[finalOperations]}" | dialog --title "$cleaningTempFiles" --backtitle "$linuxAppInstallerTitle" --progressbox $dialogHeight $dialogWidth
		echo -e "$installationFinished\n========================" >> "$logFile"
		dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $dialogHeight $dialogWidth
	else
		local commands="${commandsPerInstallationStep[commandsDebconf]} ${commandsPerInstallationStep[thirdPartyRepo]}"
		commands+="${commandsPerInstallationStep[preInstallation]} ${commandsPerInstallationStep[updateRepo]}"
		commands+="${commandsPerInstallationStep[installRepoPackages]} ${commandsPerInstallationStep[installNonRepoApps]}"
		commands+="${commandsPerInstallationStep[eulaApp]}"
		commands+="${commandsPerInstallationStep[postInstallation]} ${commandsPerInstallationStep[finalOperations]}"
		commands+="echo \"# $installationFinished\";"
		# debug
		echo "$commands" > /home/cesar/comandos
		# Ask for admin password to execute script like sudoer user
		( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "$commands" ) |
		zenity --progress --title="$linuxAppInstallerTitle" --no-cancel --pulsate --width=$zenityWidth --window-icon="$installerIconFolder/tux32.png"
		echo -e "$installationFinished\n========================" >> "$logFile"
		# Show notification and log
		local logMessage="$folder\n<a href='$logsFolder'>$logsFolder</a>\n$file\n<a href='$logFile'>$logFilename</a>"
		notify-send -i "$installerIconFolder/logviewer.svg" "$logNotification" "$logMessage" -t 10000
		zenity --text-info --title="$linuxAppInstallerTitle Log" --filename="$logFile" --width=$zenityWidth --height=$zenityHeight --window-icon="$installerIconFolder/tux32.png"
	fi
	chown $username:$username "$logFile"
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
		local appName appIndex=1 totalAppsToInstall=${#appsToInstall[@]} message

		if [ -n $DISPLAY ]; then notify-send -i "$installerIconFolder/applications-other.svg" "$installingSelectedApplications" "" -t 10000; fi
		for appName in ${appsToInstall[@]}; do
			commandsPerInstallationStep[thirdPartyRepo]+=$( generateCommands "$thirdPartyRepoFolder" "$appName" "$addingThirdPartyRepo" )
			commandsPerInstallationStep[preInstallation]+=$( generateCommands "$preInstallationFolder" "$appName" "$preparingInstallationApp" )
			commandsPerInstallationStep[installRepoPackages]+=$( generateCommands "$commonFolder" "installapp.sh" "$installingApplication $appIndex/$totalAppsToInstall: $appName" "$appName" )
			commandsPerInstallationStep[installNonRepoApps]+=$( generateCommands "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApp $appIndex/$totalAppsToInstall: $appName" )
			commandsPerInstallationStep[postInstallation]+=$( generateCommands "$postInstallationFolder" "$appName" "$settingUpApplication" )
			appIndex=$(($appIndex+1))
		done
		if [ -n "${commandsPerInstallationStep[installRepoPackages]}" ] || [ -n "${commandsPerInstallationStep[installNonRepoApps]}" ]; then
			commandsPerInstallationStep[commandsDebconf]=$( generateCommands "$commonFolder" "setupDebconf.sh" "$settingDebconfInterface" )
			if [ -n "${commandsPerInstallationStep[thirdPartyRepo]}" ] || [ -n  "${commandsPerInstallationStep[preInstallation]}" ]; then
				commandsPerInstallationStep[updateRepo]=$( generateCommands "$commonFolder" "updateRepositories.sh" "$updatingRepositories" )
			fi
			commandsPerInstallationStep[finalOperations]=$( generateCommands "$commonFolder" "finalOperations.sh" "$cleaningTempFiles" )
			executeCommands
		fi
	fi
	if [ -n $DISPLAY ]; then notify-send -i "$installerIconFolder/octocat96.png" "$githubProject" "$githubProjectLink\n$linuxAppInstallerAuthor" -t 10000; fi
}
