#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 10/05/2014
# Licence: MIT
##########################################################################

##########################################################################
# This funtion initialize common variables used by other functions
#
# Parameters: 
#	scriptRootFolder: main script root folder
#	logFilename: log filename where the script will report errors or
# 		     steps of installation process.
# Return:
#	username: that executes the installation script.
#	scriptRootFolder: main script root folder.
#	logsFolder: folder that will contain the script's log file.
#	logFile: log file where the script will report steps and errors.
#	tempFolder: temporal folder used by installation script.
#	thirdPartyRepoFolder: where are placed files which contain
#			      commands to add third-party repositories.
#	eulaFolder: where are placed files which contain commands to set
#		    debconf for EULA support.
#	configFolder: where are placed files which contain commands to
#		      setup applications.
#	nonRepositoryAppsFolder: where are placed files which contain
#				 commands to install non-repo apps.
# 	installerIconFolder: where are placed icons for the installer.
#	appListFile: it contains categories, applications and packages
#		     used by main menu and the installation proccess.
#	askpass: script that launchs a zenity to ask por admin password.
#	dialogWidth: width in pixels of dialog box.
#	dialogHeight: height in pixels of dialog box.
#	zenityWidth: width in pixels of zenity box.
#	zenityHeight: height in pixels of zenity box.
#	repoCommands: commands to add third-party repotitories.
#	packageCommands: commands to install repository packages.
#	nonRepoAppCommands: commands to install non-repository apps.
#	setupCommands: commands to setup applications.
#	debconfInterface: Interface used for Debconf (Dialog/Zenity).
#	desktop: Current user session desktop .
##########################################################################
function initCommonVariables()
{
	username=`whoami`
	if [ "$1" != "" ]; then
		scriptRootFolder="${1}"
	fi
	if [ "$2" != "" ]; then
		# $HOME variable not match to `whoami` if executed on desktop mode with root priviledges. So skipped to use $HOME
		if [ "$username" == "root" ]; then
			logsFolder="/root/logs"
		else
			logsFolder="/home/$username/logs"
		fi
		logFile="$logsFolder/${2}"
	fi
	tempFolder="/tmp/linux-app-installer-`date +\"%D-%T\" | tr '/' '.'`"
	thirdPartyRepoFolder="$scriptRootFolder/third-party-repo"
	eulaFolder="$scriptRootFolder/eula"
	configFolder="$scriptRootFolder/config-apps"
	nonRepositoryAppsFolder="$scriptRootFolder/non-repository-apps"
	installerIconFolder="$scriptRootFolder/icons/installer"

	appListFile="$scriptRootFolder/etc/applicationList"
	askpass="$tempFolder/askpass.sh"
	
	dialogWidth=$((`tput cols` - 4))
	dialogHeight=$((`tput lines` - 6))
	zenityWidth=770
	zenityHeight=400

	repoCommands=""
	packageCommands=""
	nonRepoAppCommands=""
	setupCommands=""

	# Set debconf interface
	if [ -z $DISPLAY ]; then
		debconfInterface="Dialog"
		desktop="none"
	else
		if [ "$KDE_FULL_SESSION" == "true" ]; then
			debconfInterface="Kde"
			desktop="KDE"
		else
			debconfInterface="Gnome"
			desktop="$XDG_CURRENT_DESKTOP"
		fi
	fi
}

##########################################################################
# This funtion imports a translation file according to system's language.
# If no exists translation file, by default, it takes english translation. 
#
# Parameters: none
# Return: none
##########################################################################
function selectLanguage()
{
	local ISO639_1=${LANG:0:2}
	local LANGUAGE_FILE="$scriptRootFolder/languages/"$ISO639_1".properties"

	if [ -f "$LANGUAGE_FILE" ]; then
		. $LANGUAGE_FILE
	else
		. $scriptRootFolder/languages/en.properties
	fi
}

##########################################################################
# This funtion installs dialog or zenity packages, if not installed yet,
# according to detected enviroment (desktop or terminal).
#
# Parameters: none
# Return: none
##########################################################################
function installNeededPackages
{
	if [ -z $DISPLAY ]; then
		if [ "`dpkg -s dialog 2>&1 | grep "installed"`" == "" ]; then
			echo "$installingPackage dialog"
			sudo apt-get -y install dialog --fix-missing
		fi
	else
		local neededPackages=""
		if [ "`dpkg -s zenity 2>&1 | grep "installed"`" == "" ]; then
			neededPackages+="zenity"
		fi
		if [ "`dpkg -s libnotify-bin 2>&1 | grep "installed"`" == "" ]; then
			neededPackages+=" libnotify-bin"
		fi
		if [ "$desktop" == "GNOME" ]; then
			# Gnome-shell needs to install unity-gtk2-module package.
			if [ "`dpkg -s unity-gtk2-module 2>&1 | grep "installed"`" == "" ]; then
				neededPackages+=" unity-gtk2-module"
			fi
		else
			# KDE needs to install Debconf dependencies.
			if [ "$desktop" == "KDE" ]; then
				if [ "`dpkg -s libqtgui4-perl 2>&1 | grep "installed"`" == "" ]; then
					neededPackages+=" libqtgui4-perl"
				fi
			fi
		fi
		if [ "$neededPackages" != "" ]; then
			gksudo -S "apt-get -y install $neededPackages --fix-missing"
		fi
	fi
}

##########################################################################
# This funtion calls previous functions and creates needed folders and
# files used by installation script.
#
# Parameters: 
#	scriptRootFolder: main script root folder
#	logFilename: log filename where the script will report errors or
# 		     steps of installation process.
# Return: same result variables than initCommonVariables function
##########################################################################
function prepareScript()
{
	initCommonVariables "${1}" "${2}"
	selectLanguage
	installNeededPackages
	
	if [ -z $DISPLAY ] || [ `id -u` -ne 0 ]; then
		# Create temporal folders and files
		mkdir -p "$tempFolder"
		echo "#!/bin/bash
		zenity --password --title \"$askAdminPassword\"" > "$askpass"
		chmod +x "$askpass"

		mkdir -p "$logsFolder"
		echo "" > "$logFile"
	else
		# Running as root user on desktop session
		zenity --error --text="$mustBeExecutedByNoRootUser"
		exit 1
	fi
}

##########################################################################
# This funtion setup debconf from parameters read from an EULA file
#
# Parameters: 
#	eulaFilename: EULA file wich contains parameters to setup debconf
# Return: 
#	debconfCommands: commands to setup debconf-set-selections
##########################################################################
function setDebconfFromFile
{
	local eulaFilename="$1"
	local line=""
	local lineWithoutSpaces=""
	# Result of the function
	debconfCommands=""	

	# Read eula file ignoring comment and blank lines
	while read line; do
		lineWithoutSpaces=`echo $line | tr -d ' '`
		if [ "$lineWithoutSpaces" != "" ] && [[ "$line" != "#"* ]]; then
			debconfCommands+="echo $line | debconf-set-selections 2>>\"$logFile\";"
		fi
	done < "$eulaFolder/$eulaFilename"	
}

##########################################################################
# This funtion sets dialogBox variable to use a dialog progressbox if 
# detected enviroment is terminal.
#
# Parameters:
#	title: used by dialog box 
# Return: 
#	dialogBox: it contains the command to lauch dialog progressbox
##########################################################################
function dialogBoxFunction
{
	if [ -z $DISPLAY ]; then
		dialogBox="| dialog --title \"$1\" --backtitle \"$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor\" --progressbox $dialogHeight $dialogWidth"
	else
		dialogBox=""
	fi
}

##########################################################################
# This funtion sets commands to be executed to add all needed third-party
# repositories.
#
# Parameters: 
#	addThirdPartyPPACommands: basic commands to add third-party-repos
# Return: 
#	repoCommands: complete list of commands to add third-party-repos
##########################################################################
function prepareThirdPartyRepository
{
	if [ "$1" != "" ]; then
		local appName="$1"
		local appFile=$appName".sh"
		repoCommands+="echo \"# $addingThirdPartyRepo $appName\"; echo \"$addingThirdPartyRepo $appName ...\" >> \"$logFile\";"
		dialogBoxFunction "$addingThirdPartyRepo $appName ..."
		repoCommands+="bash \"$thirdPartyRepoFolder/$appFile\" $scriptRootFolder $username $desktop 2>>\"$logFile\" $dialogBox;"
	fi
}

##########################################################################
# This funtion sets commands to be executed to install all needed 
# repository packages.
#
# Parameters: 
#	packagesToInstall: list of packages to be installed
# Return: 
#	packageCommands: commands to install the packages
##########################################################################
function prepareRepositoryPackages
{
	if [ "$1" != "" ]; then
		local packagesToInstall=($1)
		local totalPackagesToInstall=${#packagesToInstall[@]}
		local index=1
		local package=""

		for package in "${packagesToInstall[@]}"; do
			# If package has EULA
			if [ -f "$eulaFolder/$package" ]; then
				if [ -z $DISPLAY ]; then
					packageCommands+="clear;"
				fi
				# Delete previous Debconf configuration
				packageCommands+="echo \"# $removeOldDebconfConfiguration $package\"; echo \"$removeOldDebconfConfiguration $package...\" >> \"$logFile\";"
				packageCommands+="echo PURGE | debconf-communicate $package 2>>\"$logFile\";"

				# Set default Debconf configuration
				packageCommands+="echo \"# $setNewDebconfConfiguration $package\"; echo \"$setNewDebconfConfiguration $package...\" >> \"$logFile\";"
				setDebconfFromFile $package
				packageCommands+="bash -c \"$debconfCommands\";"	

				dialogBox=""
			else
				dialogBoxFunction "$installingPackage $index/$totalPackagesToInstall: $package"
			fi

			packageCommands+="echo \"# $installingPackage $index/$totalPackagesToInstall: $package\"; echo \"$installingPackage $package\" >> \"$logFile\";"
			packageCommands+="apt-get -y install $package --fix-missing 2>>\"$logFile\" $dialogBox;"
			index=$(($index+1))
		done
	fi
}

##########################################################################
# This funtion sets commands to be executed to install a non-repository
# applications specified by parameter.
#
# Parameters: 
#	appName: non-repository application name.
# Return: 
#	nonRepoAppCommands: commands to install the application.
##########################################################################
function prepareNonRepositoryApplication
{
	if [ "$1" != "" ]; then
		local appName="$1"
		local appFile=$appName".sh"
		if [ -z $DISPLAY ]; then
			nonRepoAppCommands+="clear;"
		fi
		nonRepoAppCommands+="echo \"# $installingNonRepoApp $appName\"; echo \"$installingNonRepoApp $appName ...\" >> \"$logFile\";"
		nonRepoAppCommands+="bash \"$nonRepositoryAppsFolder/$appFile\" $scriptRootFolder $username $desktop 2>>\"$logFile\";"
	fi
}

##########################################################################
# This funtion sets commands to be executed to setup an application 
# specified by parameter.
#
# Parameters: 
#	appName: application name.
# Return: 
#	setupCommands: commands to setup the application.
##########################################################################
function prepareSetupApplication
{
	if [ "$1" != "" ]; then
		local appName="$1"
		local appFile=$appName".sh"
		setupCommands+="echo \"# $settingUpApplication $appName\"; echo \"$settingUpApplication $appName ...\" >> \"$logFile\";"
		dialogBoxFunction "$settingUpApplication $appName ..."
		setupCommands+="bash \"$configFolder/$appFile\" $scriptRootFolder $username $desktop 2>>\"$logFile\" $dialogBox;"
	fi
}

##########################################################################
# This funtion executes all the commands taken from previous functions
# (to add third-party repositories or to install all needed repository
# packages or to install non-repository applications or to setup
# applications) and passes to dialog or zenity according to detected
# enviroment (terminal or desktop).
#
# Parameters: none 
# Return: none
##########################################################################
function executeCommands
{
	if [ "$repoCommands" != "" ] || [ "$packageCommands" != "" ] || [ "$nonRepoAppCommands" != "" ] || [ "$setupCommands" != "" ]; then
		# Set default Debconf interface to use	
		local commands="echo \"# $settingDebconfInterface\"; echo \"$settingDebconfInterface ...\" >> \"$logFile\";"
		dialogBoxFunction "$settingDebconfInterface"
		commands+="echo debconf debconf/frontend select $debconfInterface | debconf-set-selections 2>>\"$logFile\" $dialogBox;"

		if [ "$repoCommands" != "" ]; then
			# Update repositories
			repoCommands+="echo \"# $updatingRepositories\"; echo \"$updatingRepositories ...\" >> \"$logFile\";"
			dialogBoxFunction "$updatingRepositories"
			repoCommands+="apt-get update --fix-missing 2>>\"$logFile\" $dialogBox;"
		fi

		# Install repositories and packages
		commands+="$repoCommands $packageCommands $nonRepoAppCommands $setupCommands"

		commands+="echo \"# $finishingInstallation\"; echo \"$finishingInstallation ...\" >> \"$logFile\";"
		local finishingInstallationCommands="apt-get install -f 2>>\"$logFile\" 2>>\"$logFile\";"
		dialogBoxFunction "$finishingInstallation ..."
		commands+="bash -c \"$finishingInstallationCommands\" $dialogBox;"

		commands+="echo \"# $cleaningTempFiles\"; echo \"$cleaningTempFiles ...\" >> \"$logFile\";"
		local cleanTempFilesCommands="apt-get -y autoremove 2>>\"$logFile\"; apt-get clean 2>>\"$logFile\"; rm -rf \"$tempFolder\";"
		dialogBoxFunction "$cleaningTempFiles ..."
		commands+="bash -c \"$cleanTempFilesCommands\" $dialogBox;"

		if [ -z $DISPLAY ]; then
			clear; sudo bash -c "$commands"
			# Show log
			dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $dialogHeight $dialogWidth
		else
			local autoclose=""
			if [ "$nonRepoAppCommands" == "" ]; then
				autoclose="--auto-close"
			fi

			(	SUDO_ASKPASS="$askpass" sudo -A bash -c "$commands"
				echo "# $installationFinished"; echo "$installationFinished" >> "$logFile"
			) |
			zenity --progress --title="$linuxAppInstallerTitle" --no-cancel --pulsate $autoclose --width=$zenityWidth
			# Show notification and log
			notify-send -i "$installerIconFolder/logviewer.svg" "$linuxAppInstallerTitle" "$logFileLocation\n$logFile"
			zenity --text-info --title="$linuxAppInstallerTitle Log" --filename="$logFile" --width=$zenityWidth --height=$zenityHeight
		fi
	fi
}

##########################################################################
# This is the main funtion called from external scripts. Browse the list
# of applications to be installed and check, for each application, if
# exist related files: third-party repository file, setup subscript.
# After that, call previous functions to prepare and execute commands to
# carry out the installation process.
#
# Parameters:
#	appsToInstall: list of applications to install and configure
# Return: none
##########################################################################
function installAndSetupApplications
{
	if [ "$1" != "" ]; then
		local appsToInstall=(${1})
		local appName=""
		local appFile=""
		local packagesToInstall=""

		for appName in "${appsToInstall[@]}"; do
			appFile=$appName".sh"
			# Check if exists subscript to add third-party repository
			if [ -f "$thirdPartyRepoFolder/$appFile" ]; then
				prepareThirdPartyRepository $appName
			fi
			# Delete blank and comment lines,then filter by application name and take package list (third column forward to the end)
			packagesToInstall+="`cat \"$appListFile\" | awk -v app=$appName '!/^($|[:space:]*#)/{if ($2 == app) for(i=3;i<=NF;i++)printf \"%s\",$i (i==NF?ORS:OFS)}'` "

			# Check if exists subscript to install a non-repository application
			if [ -f "$nonRepositoryAppsFolder/$appFile" ]; then
				prepareNonRepositoryApplication $appName
			fi			

			# Check if exists subscript to setup the application
			if [ -f "$configFolder/$appFile" ]; then
				prepareSetupApplication $appName
			fi
		done

		prepareRepositoryPackages "$packagesToInstall"
		executeCommands
	fi
}

