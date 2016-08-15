#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts
# @author 	César Rodríguez González
# @since 	1.0, 2014-05-10
# @version 	1.3, 2016-08-14
# @license 	MIT
##########################################################################

##
# This function show a initial credits dialog box or popup message
# @since 	v1.3
##
function credits
{
	if [ -z $DISPLAY ]; then
		local whiteSpaces="                  "
		printf "\n%.21s%s\n" "$scriptNameLabel:$whiteSpaces" "$linuxAppInstallerTitle" > $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$scriptDescriptionLabel:$whiteSpaces" "$scriptDescription" >> $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$testedOnLabel:$whiteSpaces" "$testedOnDistros" >> $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$githubProjectLabel:$whiteSpaces" "$githubProjectUrl" >> $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$authorLabel:$whiteSpaces" "$author" >> $tempFolder/linux-app-installer.credits
		dialog --title "$creditsLabel" --backtitle "$linuxAppInstallerTitle" --stdout --textbox $tempFolder/linux-app-installer.credits 11 100
	else
			notify-send -i "$installerIconFolder/tux96.png" "$linuxAppInstallerTitle" "$scriptDescription\n$testedOnLabel\n$testedOnDistrosLinks" -t 10000
	fi
}


##
# This funtion installs dialog or zenity packages, if not installed yet,
# according to detected enviroment: desktop or terminal
# @since v1.0
##
function installNeededPackages
{
	local neededPackages
	if [ -z $DISPLAY ]; then
		neededPackages="dialog tmux"
	else
		neededPackages="zenity libnotify-bin"
		if [ "$KDE_FULL_SESSION" != "true" ]; then
			neededPackages+=" gksu";
		else
			neededPackages+=" kdesudo";
			if [ "$distro" == "ubuntu" ]; then neededPackages+=" libqtgui4-perl"; fi
		fi
	fi
	if [ -n "$neededPackages" ]; then
		for package in "$neededPackages"; do
			if [ -z "`dpkg -s $package 2>&1 | grep "installed"`" ]; then
				echo "$installingRepoApplication $package"
				if [ -z $DISPLAY ]; then
					sudo apt-get -y install $package --fix-missing
				else
					if [ "$KDE_FULL_SESSION" != "true" ]; then
						`gksudo -S "apt-get -y install $package" 1>/dev/null 2>>"$logFile"`
					else
						`kdesudo -c "apt-get -y install $package" 1>/dev/null 2>>"$logFile"`
					fi
				fi
			fi
		done
	fi
}

##
# This funtion get Script Name executed
# @since 	v1.3
# @param  String scriptPath Folder path to access main script root folder
# @return String 						script name
##
function getScriptName
{
	local scriptPath="$1"
	local splittedPath
	IFS='/' read -ra splittedPath <<< "$scriptPath"
	local numberItemsPath=${#splittedPath[@]}
	echo "${splittedPath[$(($numberItemsPath-1))]}"
}

##
# This funtion prepares main installer script to be executed
# Creates needed folders and files used by installation script
# @since v1.0
##
function prepareScript
{
	local scriptName=$( getScriptName "$1" )
	logFilename="${scriptName/.sh/}-$snapshot.log"
	logFile="$logsFolder/$logFilename"
	# Create temporal folders and files
	mkdir -p "$tempFolder" "$logsFolder"
	rm -f "$logFile"
	installNeededPackages
	cp -f "$scriptRootFolder/etc/tmux.conf" "$homeFolder/.tmux.conf"
	sed -i "s/SCRIPTNAME/$scriptName/g" "$homeFolder/.tmux.conf"
	sed -i "s/LEFT-LENGHT/$(($width - 15))/g" "$homeFolder/.tmux.conf"
	sed -i "s/RIGHT-LENGT/15/g" "$homeFolder/.tmux.conf"
	echo -e "$linuxAppInstallerTitle\n========================" > "$logFile"
	credits
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
		echo ""			# First three parameters are mandatories
	else
		# Get parameters and initialize variables
		local targetFolder="$1" message="$3" commands messageCommand argument appName
		if [[ "$2" == *.sh ]]; then			# Name is a script filename
			if [ -f "$targetFolder/$2" ]; then
				argument="$4"
				messageCommand="echo \"# $  $message: $argument\"; echo \"$  $message: $argument\" >> \"$logFile\";"
				commands="bash \"$targetFolder/$2\" \"$scriptRootFolder\" \"$username\" \"$homeFolder\" \"$argument\" 2>>\"$logFile\";"
			fi
		else														# Name is an application name
			appName="$2"
			local scriptList=( $( getAppSubscripts "$targetFolder" "$appName" ) )
			# Iterate through all subscript files
			for script in "${scriptList[@]}"; do
				commands+="bash \"$script\" \"$scriptRootFolder\" \"$username\" \"$homeFolder\" 2>>\"$logFile\";"
				messageCommand+="echo \"# $  $message: $appName\"; echo \"$  $message: $appName\" >> \"$logFile\";"
			done
		fi
		if [ -n "$commands" ]; then echo "$messageCommand $commands"; else echo ""; fi
	fi
}

##
# This funtion generates command to disable application third party repository
# @param  String appName 	Application name
# @return String 					Command to comment lines stating with 'deb'
##
function generateCommandToDisableAppThirdPartyRepo
{
	local appName="$1" scriptFile targetFileNameArray targetFileName
	local tprScriptList=( $( getAppSubscripts "$thirdPartyRepoFolder" "$appName" ) )

	for scriptFile in "${tprScriptList[@]}"; do
		# Extract targetFilename value from script
		targetFileNameArray
		IFS='"' read -ra targetFileNameArray <<< "`grep 'targetFilename=\"' $scriptFile`"
		targetFileName=${targetFileNameArray[1]}
		# Command to comment lines starting with 'deb'
		echo "sed -i 's/^deb/#deb/g' \"/etc/apt/sources.list.d/$targetFileName\""
	done
}

##
# This function execute all commands associated to one installation step
# @since v1.3
# @param String							stepName	Name of the Step. Key of commandsPerInstallationStep map [mandatory]
# @param String							message		Message to display on box / window [mandatory]
# @param int 								stepIndex	Index of current step during installation process [global]
# @param Map<String,String> commandsPerInstallationStep 	Shell commands per installation steps [global]
# 	Keys of installation steps are:
# 		commandsDebconf				First step. Commands to setup interface to show terms of application
# 		preInstallation				Second step. Commands for each application:
#															1. Prepare installation of application
#															2. Update repositories
# 		installRepoApps   		Third step. Commands for each application:
#															1. Add third-party repository if needed, after that, update repositories
#															2. Install application
#															3. Disable third-party repository if activated, after that, update repos again
# 		installNonRepoApps		Forth step. Commands to install non-repository applications
# 		postInstallation			Fifth step. Commands to setup some applications to be ready to use
# 		finalOperations				Final step. Final operations: clean packages, remove temp.files, etc
##
function executeStep
{
	local stepName="$1"	message="$step $stepIndex: $2"

	if [ ${#commandsPerInstallationStep[$stepName]} -gt 0 ]; then
		if [ -z $DISPLAY ]; then
			if [[ "$stepName" == install* ]]; then
				sed -i "s/STEPDESCRIPTION/$message/g" "$homeFolder/.tmux.conf"
				tmux new-session sudo bash -c "${commandsPerInstallationStep[$stepName]}"
			else
				clear; sudo bash -c "${commandsPerInstallationStep[$stepName]}" | dialog --title "$message" --backtitle "$linuxAppInstallerTitle" --progressbox $(($height - 6)) $(($width - 4))
			fi
		else
			local autoclose=""
			if [ "$stepName" != "installNonRepoApps" ]; then autoclose="--auto-close"; fi
			( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "${commandsPerInstallationStep[$stepName]}" ) | zenity --progress --title="$message" --no-cancel --pulsate $autoclose --width=$width --window-icon="$installerIconFolder/tux32.png"
		fi
		stepIndex=$(($stepIndex+1))
	fi
}

##
# This function show logs after installation process
##
function showLogs
{
	if [ -z $DISPLAY ]; then
		dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $(($height - 6)) $(($width - 4))
	else
		local logMessage="$folder\n<a href='$logsFolder'>$logsFolder</a>\n$file\n<a href='$logFile'>$logFilename</a>"
		notify-send -i "$installerIconFolder/logviewer.svg" "$logNotification" "$logMessage" -t 10000
		zenity --text-info --title="$linuxAppInstallerTitle Log" --filename="$logFile" --width=$width --height=$zenityHeight --window-icon="$installerIconFolder/tux32.png"
	fi
	chown $username:$username "$logFile"
}

##
# This funtion executes commands to install a set of applications
# @param int totalAppsNumber						Number of apps to install
# @since v1.0
##
function executeCommands
{
	local totalAppsNumber=$1
	# sudo remember always password
	sudo cp -f "$etcFolder/desktop-app-installer-sudo" /etc/sudoers.d/
	executeStep "commandsDebconf" "$settingDebconfInterface"
	executeStep "preInstallation" "$preparingInstallationApps"
	executeStep "installRepoApps" "$installingRepoApplications $totalAppsNumber"
	executeStep "installNonRepoApps" "$installingNonRepoApplications $totalAppsNumber"
	executeStep "postInstallation" "$settingUpApplications"
	executeStep "finalOperations" "$cleaningTempFiles"
	echo "# $installationFinished"; echo -e "$installationFinished\n========================" >> "$logFile"
	showLogs
	sudo rm -f /etc/sudoers.d/app-installer-sudo
}

##
# This funtion generates and executes bash commands to install a
# set of applications
# @since v1.0
# @param String[] appsToInstall	 List of applications to be installed
##
function installAndSetupApplications
{
	local appsToInstall=("${!1}")

	if [ ${#appsToInstall[@]} -gt 0 ]; then
		local totalAppsNumber=${#appsToInstall[@]} appIndex=1 appName commandsAppThirdPartyRepo
		if [ -n $DISPLAY ]; then notify-send -i "$installerIconFolder/applications-other.svg" "$installingSelectedApplications" "" -t 10000; fi

		# STEP 1. Generate commands to setup debconf interface
		commandsPerInstallationStep[commandsDebconf]=$( generateCommands "$commonFolder" "setupDebconf.sh" "$settingDebconfInterface" )

		for appName in ${appsToInstall[@]}; do
			# STEP 2. Generate commands to prepare installation of application
			commandsPerInstallationStep[preInstallation]+=$( generateCommands "$preInstallationFolder" "$appName" "$preparingInstallationApp" )
			# STEP 3. Generate commands to add application third-party repo if needed
			commandsAppThirdPartyRepo=$( generateCommands "$thirdPartyRepoFolder" "$appName" "$addingThirdPartyRepo" )
			commandsPerInstallationStep[installRepoApps]+="$commandsAppThirdPartyRepo"
			if [ -n "$commandsAppThirdPartyRepo" ]; then
				# STEP 4. Generate commands to update repositories if required
				commandsPerInstallationStep[installRepoApps]+=$( generateCommands "$commonFolder" "updateRepositories.sh" "$updatingRepositories" )
			fi
			# STEP 5. Generate commands to install application from repositories, if that's the case
			commandsPerInstallationStep[installRepoApps]+=$( generateCommands "$commonFolder" "installapp.sh" "$installingRepoApplication $appIndex/$totalAppsNumber" "$appName" )
			if [ -n "$commandsAppThirdPartyRepo" ]; then
				# STEP 6. Generate commands to disable application third-party repository if activated
				commandsPerInstallationStep[installRepoApps]+=$( generateCommandToDisableAppThirdPartyRepo "$appName" )
				# STEP 7. Generate commands to update repositories again
				commandsPerInstallationStep[installRepoApps]+=$( generateCommands "$commonFolder" "updateRepositories.sh" "$updatingRepositories" )
			fi
			# STEP 8. Generate commands to install application from external sources, if that's the case
			commandsPerInstallationStep[installNonRepoApps]+=$( generateCommands "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApplication $appIndex/$totalAppsNumber" )
			# STEP 9. Generate commands to setup application
			commandsPerInstallationStep[postInstallation]+=$( generateCommands "$postInstallationFolder" "$appName" "$settingUpApplication" )
			appIndex=$(($appIndex+1))
		done

		# STEP 10. Generate commands to execute final operations: clean, logs, etc.
		commandsPerInstallationStep[finalOperations]=$( generateCommands "$commonFolder" "finalOperations.sh" "$cleaningTempFiles" )
		if [ ${#commandsPerInstallationStep[preInstallation]} -gt 0 ]; then
			# Pre-installation commands could require update repositories
			commandsPerInstallationStep[preInstallation]+=$( generateCommands "$commonFolder" "updateRepositories.sh" "$updatingRepositories" )
		fi
		executeCommands $totalAppsNumber
	fi
	if [ -n $DISPLAY ]; then notify-send -i "$installerIconFolder/octocat96.png" "$githubProject" "$githubProjectLink\n$linuxAppInstallerAuthor" -t 10000; fi
}
