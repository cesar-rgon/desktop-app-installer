#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts
# @author 	César Rodríguez González
# @since 		1.0, 2014-05-10
# @version 	1.3, 2016-09-26
# @license 	MIT
##########################################################################

##
# This function show a initial credits dialog box or popup message
# @since 	v1.3
##
function credits
{
	if [ -z "$DISPLAY" ]; then
		local whiteSpaces="                  "
		printf "\n%.21s%s\n" "$scriptNameLabel:$whiteSpaces" "$installerTitle" > $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$scriptDescriptionLabel:$whiteSpaces" "$scriptDescription" >> $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$testedOnLabel:$whiteSpaces" "$testedOnDistros" >> $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$githubProjectLabel:$whiteSpaces" "$githubProjectUrl" >> $tempFolder/linux-app-installer.credits
		printf "%.21s%s\n" "$authorLabel:$whiteSpaces" "$author" >> $tempFolder/linux-app-installer.credits
		dialog --title "$creditsLabel" --backtitle "$installerTitle" --stdout --textbox $tempFolder/linux-app-installer.credits 11 100
	else
			notify-send -i "$installerIconFolder/tux-shell-console96.png" "$installerTitle" "$scriptDescription\n$testedOnLabel\n$testedOnDistrosLinks" -t 10000
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
	if [ -z "$DISPLAY" ]; then
		neededPackages=( dialog tmux )
	else
		neededPackages=( zenity libnotify-bin xterm )
		if [ "$KDE_FULL_SESSION" != "true" ]; then
			neededPackages+=( gksu );
		else
			neededPackages+=( kdesudo );
			if [ "$distro" == "ubuntu" ]; then neededPackages+=( libqtgui4-perl ); fi
		fi
	fi
	if [ ${#neededPackages[@]} -gt 0 ]; then
		for package in "${neededPackages[@]}"; do
			if [ -z "`dpkg -s $package 2>&1 | grep "installed"`" ]; then
				echo "$installingRepoApplication $package"
				if [ -z "$DISPLAY" ]; then
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
	rm -f "$tempFolder/credentials"
	installNeededPackages
	cp -f "$scriptRootFolder/etc/tmux.conf" "$homeFolder/.tmux.conf"
	sed -i "s/LEFT-LENGHT/$(($width - 10))/g" "$homeFolder/.tmux.conf"
	sed -i "s/RIGHT-LENGHT/10/g" "$homeFolder/.tmux.conf"
	echo -e "$logFile\n$boxSeparator" > "$logFile"
	credits
}

##
# This function gets all existing files that matches following requisites:
# 1. Pattern filename: appName* / appName_x64* / appName_i386*
# 2. Filename must match O.S. arquitecture (*_i386 32bits / *_x64 64bits / other all)
# 3. Must be placed in targetFolder or the subfolder that matchs your linux distro
# @since 	v1.3
# @param 	String targetFolder		Root scripts folder
# @param 	String fullFilename		Filename[.extension] where filename starts
#																	with application name
# @result String 								List of path/filename of found files
##
function getAppFiles
{
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo ""			# All parameters are mandatories
	else
		local targetFolder="$1"
		local fileNameArray filename="" extension=""
		IFS='.' read -ra fileNameArray <<< "$2"
		if [ ${#fileNameArray[@]} -gt 1 ]; then
			# The filename has extension
			local lastItem="${fileNameArray[((${#fileNameArray[@]}-1))]}"
			filename="`echo ${fileNameArray[@]/$lastItem/} | tr ' ' '.'`"
			extension=".$lastItem"
		else
			# Filename without extension
			filename="`echo ${fileNameArray[@]} | tr ' ' '.'`"
		fi

		local i386="_i386" x64="_x64" fileList=""
		# Search subscript that matches all O.S. architecture
		if [ -f "$targetFolder/$distro/$filename$extension" ]; then fileList+="$targetFolder/$distro/$filename$extension "; fi
		if [ -f "$targetFolder/$filename$extension" ]; then fileList+="$targetFolder/$filename$extension "; fi
		if [ `uname -m` == "x86_64" ]; then
			# Search subscript that matches 64 bits O.S. architecture
			if [ -f "$targetFolder/$distro/$filename$x64$extension" ]; then fileList+="$targetFolder/$distro/$filename$x64$extension "; fi
			if [ -f "$targetFolder/$filename$x64$extension" ]; then fileList+="$targetFolder/$filename$x64$extension "; fi
		else
			# Search subscript that matches 32 bits O.S. architecture
			if [ -f "$targetFolder/$distro/$filename$i386$extension" ]; then fileList+="$targetFolder/$distro/$filename$i386$extension "; fi
			if [ -f "$targetFolder/$filename$i386$extension" ]; then fileList+="$targetFolder/$filename$i386$extension "; fi
		fi
		echo "$fileList"
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
				messageCommand="echo -e \"\n# $  $message $argument\"; echo \"$  $message $argument\" >> \"$logFile\";"
				commands="bash \"$targetFolder/$2\" \"$scriptRootFolder\" \"$username\" \"$homeFolder\" \"$argument\" 2>>\"$logFile\";"
			fi
		else														# Name is an application name
			appName="$2"
			local scriptList=( $( getAppFiles "$targetFolder" "$appName.sh" ) )
			# Iterate through all subscript files
			for script in "${scriptList[@]}"; do
				commands+="bash \"$script\" \"$scriptRootFolder\" \"$username\" \"$homeFolder\" 2>>\"$logFile\";"
				messageCommand+="echo -e \"\n# $  $message: $appName\"; echo \"$  $message: $appName\" >> \"$logFile\";"
			done
		fi
		if [ -n "$commands" ]; then echo "$messageCommand $commands"; else echo ""; fi
	fi
}

##
# This function generates needed commands to prepare, install
# and setup an application. The source to get the application can be:
# 1. Official repositories. Steps are:
#		1a. Install application from repository
# 2. Third-party repositories. Steps are:
#		2a. Add third-party repository, after that, update repositories
#		2b. Install application
#		2c. Disable third-party repository, after that, update repositories again
# 3. External source. Not from repositories. Steps are:
#		3a. Download application from source (web page, ftp, etc)
#		3b. Extract and install file content
# @since v1.3
# @param String	appName	 Application name [mandatory]
##
function generateCommandsInstallApp
{
	local appName="$1" commands=""

	# STEP 1: Generate commands to prepare installation of the application
	local applicationPPAFiles=( $( getAppFiles "$ppaFolder" "$appName" ) )

	# Only use first PPA file found
	if [ ${#applicationPPAFiles[@]} -gt 0 ]; then
		local ppa=`grep -v '^$\|^\s*\#' ${applicationPPAFiles[0]}`
		commands=$( generateCommands "$commonFolder" "addPPA.sh" "$addingThirdPartyRepository" "$ppa" )
	fi
	commands+=$( generateCommands "$preInstallationFolder" "$appName" "$preparingInstallationApp" )
	if [ -n "$commands" ]; then
		notify-send "debug" "AQUI"
		# STEP 2: Generate commands to update repositories if required
		commands+=$( generateCommands "$commonFolder" "updateRepositories.sh" "$updatingRepositories" )
	fi
	# STEP 3. Generate commands to install the application
	# CASE 1. Non-repo application
	local commandsNR=$( generateCommands "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApplication $nonRepoAppIndex/totalNonRepoAppsNumber" )
	if [ -n "$commandsNR" ]; then
		commands+="$commandsNR"
	else
		# CASE 2. Repo application
		commands+=$( generateCommands "$commonFolder" "installapp.sh" "$installingRepoApplication $repoAppIndex/totalRepoAppsNumber" "$appName" )
	fi
	if [ ${#applicationPPAFiles[@]} -gt 0 ]; then
		# STEP 4. Generate commands to remove third-party repository
		commands+=$( generateCommands "$commonFolder" "removePPA.sh" "$removingThirdPartyRepository" "$ppa" )
		# STEP 5. Generate commands to update repositories again
		commands+=$( generateCommands "$commonFolder" "updateRepositories.sh" "$updatingRepositories" )
	fi
	# STEP 6. Generate commands to setup application
	commands+=$( generateCommands "$postInstallationFolder" "$appName" "$settingUpApplication" )

	if [ -z "$commandsNR" ]; then
		echo "$commands"
	else
		echo "NR#$commands"
	fi
}

##
# This function executes bash commands to install applications
# @since v1.3
# @param String	commandsRepoApp	 		Commands to install repository apps [optional]
# @param String	commandsNonRepoApp 	Commands to install non-repository apps [optional]
##
function installApplications
{
	local commandsRepoApp="$1" commandsNonRepoApp="$2"
	local totalRepoAppsNumber=$(($repoAppIndex-1))
	local totalNonRepoAppsNumber=$(($nonRepoAppIndex-1))

	if [ -z "$DISPLAY" ]; then
		if [ -n "$commandsRepoApp" ] || [ -n "$commandsNonRepoApp" ]; then
			sed -i "s/MESSAGE/$installingApplications/g" "$homeFolder/.tmux.conf"
			sed -i "s/TOTALAPPS/$total: $(($totalRepoAppsNumber+$totalNonRepoAppsNumber))/g" "$homeFolder/.tmux.conf"
			echo "$commandsRepoApp" | tr ';' '\n' > $tempFolder/commandsToInstallApps
			echo "$commandsNonRepoApp" | tr ';' '\n' >> $tempFolder/commandsToInstallApps
			tmux new-session "sudo bash $tempFolder/commandsToInstallApps"
		fi
	else
		if [ -n "$commandsRepoApp" ]; then
			( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "$commandsRepoApp" ) | zenity --progress --title="$installingRepoApplications. $total: $totalRepoAppsNumber" --no-cancel --pulsate --auto-close --width=$width --window-icon="$installerIconFolder/tux-shell-console32.png"
		fi
		if [ -n "$commandsNonRepoApp" ]; then
			( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "$commandsNonRepoApp" ) | zenity --progress --title="$installingNonRepoApplications. $total: $totalNonRepoAppsNumber" --no-cancel --pulsate --width=$width --window-icon="$installerIconFolder/tux-shell-console32.png"
		fi
	fi
}

##
# This function generates and executes commands needed to begin the installation proccess
##
function executeBeginningOperations
{
	# sudo remember always password
	local beginningOperations="cp -f "$etcFolder/desktop-app-installer-sudo" /etc/sudoers.d/;"
	# Setup debconf interface. Needed to show EULA box for terminal mode or EULA window for desktop mode
	beginningOperations+=$( generateCommands "$commonFolder" "setupDebconf.sh" "$settingDebconfInterface" )
	if [ -z "$DISPLAY" ]; then
		clear; sudo bash -c "$beginningOperations" | dialog --title "$settingDebconfInterface" --backtitle "$installerTitle" --progressbox $(($height - 6)) $(($width - 4))
	else
		( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "$beginningOperations" ) | zenity --progress --title="$installerTitle" --no-cancel --pulsate --auto-close --width=$width --window-icon="$installerIconFolder/tux-shell-console32.png"
	fi
}

##
# This function generates and executes commands needed to finish the installation proccess
# Clean packages, remove temp.files, etc
##
function executeFinalOperations
{
	local finalOperations=$( generateCommands "$commonFolder" "finalOperations.sh" "$cleaningTempFiles" )
	finalOperations+="rm -f /etc/sudoers.d/app-installer-sudo;"
	if [ -z "$DISPLAY" ]; then
		clear; sudo bash -c "$finalOperations" | dialog --title "$cleaningTempFiles" --backtitle "$installerTitle" --progressbox $(($height - 6)) $(($width - 4))
	else
		( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "$finalOperations" ) | zenity --progress --title="$installerTitle" --no-cancel --pulsate --auto-close --width=$width --window-icon="$installerIconFolder/tux-shell-console32.png"
	fi
	echo -e "\n# $installationFinished"; echo -e "\n$installationFinished\n$boxSeparator" >> "$logFile"
	showLogs
	showCredentials
}

##
# This function shows logs after installation process
##
function showLogs
{
	if [ -z "$DISPLAY" ]; then
		dialog --title "$installerLogsLabel" --backtitle "$installerTitle" --textbox "$logFile" $(($height - 6)) $(($width - 4))
	else
		local logMessage="$folder\n<a href='$logsFolder'>$logsFolder</a>\n$file\n<a href='$logFile'>$logFilename</a>"
		notify-send -i "$installerIconFolder/logviewer.svg" "$logNotification" "$logMessage" -t 10000
		zenity --text-info --title="$installerTitle Log" --filename="$logFile" --width=$width --height=$height --window-icon="$installerIconFolder/tux-shell-console32.png"
	fi
	chown $username:$username "$logFile"
}

##
# This function shows credentials needed by some of the selected applications to login
##
function showCredentials
{
	if [ -f "$tempFolder/credentials" ]; then
		if [ -z "$DISPLAY" ]; then
			dialog --title "$credentialNotification" --backtitle "$installerTitle" --textbox "$tempFolder/credentials" $(($height - 6)) $(($width - 4))
		else
			notify-send -i "$installerIconFolder/login-credentials.png" "$credentialNotification" "" -t 10000
			zenity --text-info --title="$credentialNotification" --filename="$tempFolder/credentials" --width=$width --height=$height --window-icon="$installerIconFolder/tux-shell-console32.png"
		fi
	fi
}

##
# This funtion gets username/password from application credential file
# @param String appName		Application name
##
function getAppCredentials
{
	local appName="$1"
	if [ -f "$credentialFolder/$appName.properties" ]; then
		. "$credentialFolder/$appName.properties"
		echo "$applicationLabel: $appName" >> "$tempFolder/credentials"
		if [ -n "$appUsername" ]; then
			echo "$usernameLabel: $appUsername" >> "$tempFolder/credentials"
		fi
		if [ -n "$appPassword" ]; then
			echo "$passwordLabel: $appPassword" >> "$tempFolder/credentials"
		fi
		echo -e "$boxSeparator\n" >> "$tempFolder/credentials"
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
	local appsToInstall=("${!1}")

	if [ ${#appsToInstall[@]} -gt 0 ]; then
		if [ -n "$DISPLAY" ]; then
			notify-send -i "$installerIconFolder/applications-other.svg" "$installingSelectedApplications" "" -t 10000
		fi

		# Execute initial commands to proceed with installation proccess
		executeBeginningOperations
		local appName commands commandsRepoApp commandsNonRepoApp
		for appName in ${appsToInstall[@]}; do
			# Generate and executes commands to prepare, install and setup the application
			commands=$( generateCommandsInstallApp "$appName" )
			if [[ "$commands" != NR#* ]]; then
				commandsRepoApp+="$commands"
				repoAppIndex=$(($repoAppIndex+1))
			else
				commandsNonRepoApp+=${commands/NR#/}
				nonRepoAppIndex=$(($nonRepoAppIndex+1))
			fi
			getAppCredentials "$appName"
		done

		local totalRepoAppsNumber=$(($repoAppIndex-1)) totalNonRepoAppsNumber=$(($nonRepoAppIndex-1))
		commandsRepoApp=`echo "$commandsRepoApp" | sed "s/totalRepoAppsNumber/$totalRepoAppsNumber/g"`
		commandsNonRepoApp=`echo "$commandsNonRepoApp" | sed "s/totalNonRepoAppsNumber/$totalNonRepoAppsNumber/g"`
		installApplications "$commandsRepoApp" "$commandsNonRepoApp"

		# Execute final commands to clean packages and remove temporal files/folders
		executeFinalOperations
	fi
	if [ -n "$DISPLAY" ]; then notify-send -i "$installerIconFolder/octocat96.png" "$githubProject" "$githubProjectLink\n$authorLabel $author" -t 10000; fi
}
