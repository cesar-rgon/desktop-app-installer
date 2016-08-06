#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts
# @author 	César Rodríguez González
# @since 		1.0, 2014-05-10
# @version 	1.3, 2016-08-06
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
# This function generates commands to execute subscripts during installation
# process
# @since 	v1.3
# @param Map<String,String> parameters 	Generic parameters used by this function [global]
# 	Keys of accepted parameters are:
# 		fileScripts		Set of subscript files from where extract commands [mandatory]
# 		appName				Application name refered if that's the case [optional]
# 		message				Message to be showed in box/window [optional]
# @return String 												list of bash shell commands separated by ;
##
function generateCommands
{
	declare -ag fileScripts=(${parameters[fileScript]})
	local appName="${parameters[appName]}" message="${parameters[message]}"
	local commands messageCommand

	# Iterate through all subscript files
	for fileScript in "${fileScripts[@]}"; do
		if [ -f "$fileScript" ]; then
			local commands messageCommand
			commands+="bash \"$fileScript\" \"$scriptRootFolder\" \"$appName\" 2>>\"$logFile\";"
			# Specific application message to show in box/window and log
			if [ -n "$message" ] && [ -n "$appName" ]; then
				messageCommand+="echo \"# $message $appName\"; echo \"$message $appName\" >> \"$logFile\";"
			fi
		fi
	done
	# Generic message to show in box/window and log
	if [ -n "$message" ]; then
		messageCommand+="echo \"# $message\"; echo \"$message\" >> \"$logFile\";"
	fi
	if [ -n "$commands" ]; then echo "$messageCommand $commands"; else echo ""; fi
}

# TODO:
# OPCION 1: SEGUIR CON MÉTODO GENÉRICO. SE DEBE IMPLEMENTAR MÉTODO QUE PREPARE PARÁMETROS.
# EL MÉTODO DE GENERAR COMANDOS POR APLICACION SE ACABARÍA POR ELIMINAR
# OPCION 2: DEJAR VARIOS GENERATECOMMANDS. ESTE ME GUSTA MENOS

##
# This function generates commands to execute application subscripts during
# installation process
# @since 	v1.3
# @param  String targetFolder destination folder where subscript is placed [mandatory]
# @param  String appName 			application name refered by subscript [mandatory]
# @param  String message      optional message to be showed in box/window [optional]
# @return String 							list of bash shell commands separated by ;
##
function generateCommandsApp
{
	local targetFolder="$1" appName="$2" message="$3"
	local commands messageCommand

	if [ -n "$appName" ] && [ -n "$targetFolder" ]; then
		local i386="_i386" x64="_x64"

		if [ `uname -m` == "x86_64" ]; then
			# For 64 bits OS
			if [ -f "$targetFolder/$distro/$appName$x64.sh" ]; then
				commands+="bash \"$targetFolder/$distro/$appName$x64.sh\" \"$scriptRootFolder\" 2>>\"$logFile\";"
			fi
			if [ -f "$targetFolder/$appName$x64.sh" ]; then
				commands+="bash \"$targetFolder/$appName$x64.sh\" \"$scriptRootFolder\" 2>>\"$logFile\";"
			fi
		else
			# For 32 bits OS
			if [ -f "$targetFolder/$distro/$appName$i386.sh" ]; then
				commands+="bash \"$targetFolder/$distro/$appName$i386.sh\" \"$scriptRootFolder\" 2>>\"$logFile\";"
			fi
			if [ -f "$targetFolder/$appName$i386.sh" ]; then
				commands+="bash \"$targetFolder/$appName$i386.sh\" \"$scriptRootFolder\" 2>>\"$logFile\";"
			fi
		fi
		# For all CPU arquitectures
		if [ -f "$targetFolder/$distro/$appName.sh" ]; then
			commands+="bash \"$targetFolder/$distro/$appName.sh\" \"$scriptRootFolder\" 2>>\"$logFile\";"
		fi
		if [ -f "$targetFolder/$appName.sh" ]; then
			commands+="bash \"$targetFolder/$appName.sh\" \"$scriptRootFolder\" 2>>\"$logFile\";"
		fi
		if [ -n "$message" ]; then
			messageCommand="echo \"# $message $appName\"; echo \"$message $appName ...\" >> \"$logFile\";"
		fi
	fi
	if [ -n "$commands" ]; then echo "$messageCommand $commands"; else echo ""; fi
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
# 		postInstallation			Seventh step. Commands to setup some applications to be ready to use
# 		finalOperations				Eighth step. Final operations: clean packages, remove temp.files, etc
##
function executeCommands
{
	local commands

	if [ -z $DISPLAY ]; then
		local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"

		clear; sudo bash -c "${commandsPerInstallationStep[commandsDebconf]}" | dialog --title "$settingDebconfInterface" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[thirdPartyRepo]}" | dialog --title "$addingThirdPartyRepos" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[preInstallation]}" | dialog --title "$preparingInstallationApps" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[updateRepo]}" | dialog --title "$updatingRepositories" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[installRepoPackages]}" | dialog --title "$installingPackages" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[installNonRepoApps]}" | dialog --title "$installingNonRepoApps" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[postInstallation]}" | dialog --title "$settingUpApplications" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		clear; sudo bash -c "${commandsPerInstallationStep[finalOperations]}" | dialog --title "$cleaningTempFiles" --backtitle "$backtitle" --progressbox $dialogHeight $dialogWidth
		dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $dialogHeight $dialogWidth
	else
		local commands="${commandsPerInstallationStep[commandsDebconf]} ${commandsPerInstallationStep[thirdPartyRepo]}"
		commands+="${commandsPerInstallationStep[preInstallation]} ${commandsPerInstallationStep[updateRepo]}"
		commands+="${commandsPerInstallationStep[installRepoPackages]} ${commandsPerInstallationStep[installNonRepoApps]}"
		commands+="${commandsPerInstallationStep[postInstallation]} ${commandsPerInstallationStep[finalOperations]}"
		commands+="echo \"# $installationFinished\";"
		# Ask for admin password to execute script like sudoer user
		( SUDO_ASKPASS="$scriptRootFolder/common/askpass.sh" sudo -A bash -c "$commands" ) |
		zenity --progress --title="$linuxAppInstallerTitle" --no-cancel --pulsate --width=$zenityWidth --window-icon="$installerIconFolder/tux32.png"
		# Show notification and log
		notify-send -i "$installerIconFolder/logviewer.svg" "$linuxAppInstallerTitle" "$logFileLocation\n$logFile"
		zenity --text-info --title="$linuxAppInstallerTitle Log" --filename="$logFile" --width=$zenityWidth --height=$zenityHeight --window-icon="$installerIconFolder/tux32.png"
	fi
	echo "$installationFinished" >> "$logFile";
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
		local appName appIndex=1

		for appName in ${appsToInstall[@]}; do
			commandsPerInstallationStep[thirdPartyRepo]+=$( generateCommandsApp "$thirdPartyRepoFolder" "$appName" "$addingThirdPartyRepo" )
			commandsPerInstallationStep[preInstallation]+=$( generateCommandsApp "$preInstallationFolder" "$appName" "$preparingInstallationApp" )
			commandsPerInstallationStep[installRepoPackages]+=$( generateCommandsInstallRepoPackages "$appName" "$appIndex" "${#appsToInstall[@]}")
			local fileScript="${parameters[fileScript]}" appName="${parameters[appName]}" message="${parameters[message]}"

			#		commands+="echo -e \"# $installingApplication $appIndex/$totalAppsToInstall: $appName\n$installingPackage $packageIndex/$totalPackagesToInstall: $package\";"
			#		commands+="echo -e \"$installingApplication $appIndex/$totalAppsToInstall: $appName. $installingPackage $packageIndex/$totalPackagesToInstall: $package\" >> \"$logFile\";"
			commandsPerInstallationStep[installNonRepoApps]+=$( generateCommandsApp "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApp" )
			commandsPerInstallationStep[postInstallation]+=$( generateCommandsApp "$postInstallationFolder" "$appName" "$settingUpApplication" )
			appIndex=$(($appIndex+1))
		done

		if [ -n "${commandsPerInstallationStep[installRepoPackages]}" ] || [ -n "${commandsPerInstallationStep[installNonRepoApps]}" ]; then
			commandsPerInstallationStep[commandsDebconf]=$( generateCommands "$scriptRoolFolder/common/setupDebconf.sh" "$settingDebconfInterface" )
			if [ -n "${commandsPerInstallationStep[thirdPartyRepo]}" ] || [ -n  "${commandsPerInstallationStep[preInstallation]}" ]; then
				commandsPerInstallationStep[updateRepo]=$( generateCommands "$scriptRoolFolder/common/updateRepositories.sh" "$updatingRepositories" )
			fi
			commandsPerInstallationStep[finalOperations]=$( generateCommands "$scriptRoolFolder/common/finalOperations.sh" "$cleaningTempFiles" )
			executeCommands commandsPerInstallationStep[@]
		fi
	fi
}
