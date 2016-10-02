#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts
# @author 	César Rodríguez González
# @since 		1.0, 2014-05-10
# @version 	1.3, 2016-10-02
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

	for package in "${neededPackages[@]}"; do
		if [ -z "`dpkg -s $package 2>&1 | grep "Status: install ok installed"`" ]; then
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

function getScriptPath
{
	local scriptPath="$1"
	local scriptName=$( getScriptName "$scriptPath" )
	echo "${scriptPath/\/$scriptName/}"
}

##
# This funtion prepares main installer script to be executed
# Creates needed folders and files used by installation script
# @since v1.0
##
function prepareScript
{
	local scriptName=$( getScriptName "$1" )
	logFilename="${scriptName//.sh/}-$snapshot.log"
	logFile="$logsFolder/$logFilename"
	# Create temporal folders and files
	mkdir -p "$tempFolder" "$logsFolder"
	rm -f "$logFile"
	rm -f "$tempFolder/credentials"
	installNeededPackages
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
			filename="`echo ${fileNameArray[@]//$lastItem/} | tr ' ' '.'`"
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
# This function executes a specified subscript during installation process.
# @since 	v1.3
# @param String script				Name of subscript to be executed [mandatory]
# @param String message				Message to be showed in box/window [mandatory]
# @param String arguments			List os arguments separated by | character [optional]
# @return String 							"true" if the script has been executed, else "false"
##
function executeScript
{
	local script="$1" message="$2" arguments="$3"

	if [ -z "$script" ] || [ -z "$message" ]; then
		echo "false"			# First two parameters are mandatories
	else
		if [ -f "$script" ]; then
			# Generate commands to execute the script
			local messageCommands execScriptCommands
			if [ -n "$DISPLAY" ]; then messageCommands="echo -e \"\n# $  $message\";"; fi
			messageCommands+="echo \"$  $message\" >> \"$logFile\";"
			execScriptCommands="bash \"$script\" \"$scriptRootFolder\" \"$username\" \"$homeFolder\" \"$arguments\" 2>>\"$logFile\";"

			# Execute commands
			if [ -z "$DISPLAY" ]; then
				sudo cp -f "$scriptRootFolder/etc/tmux.conf" "/etc"
				sudo sed -i "s/LEFT-LENGHT/$width/g" "/etc/tmux.conf"
				sudo sed -i "s/MESSAGE/$message/g" "/etc/tmux.conf"
				sudo tmux new-session "$messageCommands $execScriptCommands"
			else
				local targetFolder=$( getScriptPath "$script" ) autoclose="--auto-close"
				local xtermCommand="xterm -T \"$terminalProgress. $applicationLabel: $appName\" -fa 'DejaVu Sans Mono' -fs 11 -geometry 200x15+0-0 -xrm 'XTerm.vt100.allowTitleOps: false' -e \"$execScriptCommands\";"

				if [ "$targetFolder" == "$nonRepositoryAppsFolder" ]; then autoclose=""; fi
				( SUDO_ASKPASS="$commonFolder/askpass.sh" sudo -A bash -c "$messageCommands $xtermCommand" ) \
				| zenity --progress --title="$installingApplications. $total: $totalApps" --no-cancel --pulsate $autoclose --width=$width --window-icon="$installerIconFolder/tux-shell-console32.png"
			fi
			echo "true"
		else
			echo "false"
		fi
	fi
}

##
# This function executes all the scripts asociated to an application in a targetFolder
# @since 	v1.3
# @param String targetFolder	Destination folder where is placed the script [mandatory]
# @param String appName				Application name [mandatory]
# @param String message				Message to be showed in box/window [mandatory]
# @param String arguments			List os arguments separated by | character [optional]
# @return String 							"true" if at least one script has been executed, else "false"
##
function execute
{
	local targetFolder="$1" appName="$2" message="$3"

	if [ -z "$targetFolder" ] || [ -z "$appName" ] || [ -z "$message" ]; then
		echo "false"			# First three parameters are mandatories
	else
		local scriptList=( $( getAppFiles "$targetFolder" "$appName.sh" ) )
		local executedScript executed="false"
		# Iterate through all subscript files
		local script scriptName
		for script in "${scriptList[@]}"; do
			executedScript=$( executeScript "$script" "$message" )
			if [ "$executedScript" == "true" ]; then
				executed="true"
			fi
		done
		echo "$executed"
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
#		2c. Remove third-party repository, after that, update repositories again
# @since v1.3
# @param String	appName	 		Application name [mandatory]
# @param int		index	 			Index to enumarate the installation order of the app [mandatory]
# @param int		totalApps	 	Total number of repo apps to be installed [mandatory]
##
function installRepoApplication
{
	local appName="$1" index=$2 totalApps=$3
	local executed="false"

	# STEP 1: Prepare installation of the application
	local applicationPPAFiles=( $( getAppFiles "$ppaFolder" "$appName" ) )
	if [ ${#applicationPPAFiles[@]} -gt 0 ]; then
		local ppa=`grep -v '^$\|^\s*\#' ${applicationPPAFiles[0]}`
		executeScript "$commonFolder/addPPA.sh" "$addingThirdPartyRepository: $appName" "$ppa"
	fi
	executed+=$( execute "$preInstallationFolder" "$appName" "$preparingInstallationApp: $appName" )
	if [ ${#applicationPPAFiles[@]} -gt 0 ] || [ "$executed" == "true" ]; then
		# STEP 2: Update repositories if required
		executeScript "$commonFolder/updateRepositories.sh" "$updatingRepositories"
	fi
	# STEP 3. Install the application
	executeScript "$commonFolder/installapp.sh" "$installingRepoApplication $index|$totalApps: $appName" "$appName"

	if [ ${#applicationPPAFiles[@]} -gt 0 ]; then
		# STEP 4. Remove third-party repository
		executeScript "$commonFolder/removePPA.sh" "$removingThirdPartyRepository: $appName" "$ppa"
		# STEP 5. Update repositories again
		executeScript "$commonFolder/updateRepositories.sh" "$updatingRepositories"
	fi
	# STEP 6. Setup application
	execute "$postInstallationFolder" "$appName" "$settingUpApplication: $appName"
	# STEP 7. Generate credentials to authenticate in required applications
	getAppCredentials "$appName"
}

##
# This function executes needed commands to prepare, install
# and setup an application. The source to get the application if external,
# that means, not from any repository. Steps are:
#		3a. Download application from source (web page, ftp, etc)
#		3b. Extract and install file content
# @since v1.3
# @param String	appName	 		Application name [mandatory]
# @param int		index	 			Index to enumarate the installation order of the app [mandatory]
# @param int		totalApps	 	Total number of non-repo apps to be installed [mandatory]
##
function installNonRepoApplication
{
	local appName="$1" index=$2 totalApps=$3
	local commands="" executed="false"

	# STEP 1: Prepare installation of the application
	executed=$( execute "$preInstallationFolder" "$appName" "$preparingInstallationApp: $appName" )
	if [ "$executed" == "true" ]; then
		# STEP 2: Update repositories if required
		executeScript "$commonFolder/updateRepositories.sh" "$updatingRepositories"
	fi
	# STEP 3. Install the application
	execute "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApplication $index|$totalApps: $appName"
	# STEP 4. Setup application
	execute "$postInstallationFolder" "$appName" "$settingUpApplication: $appName"
	# STEP 7. Generate credentials to authenticate in required applications
	getAppCredentials "$appName"
}

##
# This function generates and executes commands needed to begin the installation process
##
function executeBeginningOperations
{
	# sudo remember always password
	sudo cp -f "$etcFolder/desktop-app-installer-sudo" /etc/sudoers.d/
	# Setup debconf interface. Needed to show EULA box for terminal mode or EULA window for desktop mode
	executeScript "$commonFolder/beginningOperations.sh" "$settingDebconfInterface"
}

##
# This function generates and executes commands needed to finish the installation proccess
# Clean packages, remove temp.files, etc
##
function executeFinalOperations
{
	executeScript "$commonFolder/finalOperations.sh" "$cleaningTempFiles"
	sudo rm -f /etc/sudoers.d/desktop-app-installer-sudo /etc/tmux.conf
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

		# Separates repo/non-repo applications
		local repoAppsToInstall=() nonRepoAppsToInstall=() repoIndex=0 nonRepoIndex=0 appName=""
		for appName in ${appsToInstall[@]}; do
				local applicationNonRepoScripts=( $( getAppFiles "$nonRepositoryAppsFolder" "$appName.sh" ) )
				if [ -z "$applicationNonRepoScripts" ]; then   	# Repo application
					repoAppsToInstall[$repoIndex]="$appName"
					repoIndex=$(($repoIndex+1))
				else																						# Non-repo application
					nonRepoAppsToInstall[$nonRepoIndex]="$appName"
					nonRepoIndex=$(($nonRepoIndex+1))
				fi
		done
		# Generate and execute initial commands to proceed with installation proccess
		executeBeginningOperations
		# Generate and execute commands to install each repo application
		local appCount=1
		for appName in ${repoAppsToInstall[@]}; do
			installRepoApplication "$appName" $appCount ${#repoAppsToInstall[@]}
			appCount=$(($appCount+1))
		done
		# Generate and execute commands to install each non-repo application
		appCount=1
		for appName in ${nonRepoAppsToInstall[@]}; do
			installNonRepoApplication "$appName" $appCount ${#nonRepoAppsToInstall[@]}
			appCount=$(($appCount+1))
		done
		# Execute final commands to clean packages and remove temporal files/folders
		executeFinalOperations
	fi
	if [ -n "$DISPLAY" ]; then notify-send -i "$installerIconFolder/octocat96.png" "$githubProject" "$githubProjectLink\n$authorLabel $author" -t 10000; fi
}
