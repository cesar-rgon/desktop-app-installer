#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 01/06/2014
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
#	preInstallationCommands: commands to execute before installing an
#				 application.
#	postInstallationCommands: commands to execute after installing an
#				  application.
#	debconfInterface: Interface used for Debconf (Dialog/Zenity).
#       distro: Distribution name (ubuntu/debian)
##########################################################################
function initCommonVariables
{
	linuxAppInstallerTitle="Linux app installer v1.3 (Ubuntu-Debian-Mint-LMDE)"
	distro="`lsb_release -i | awk '{print $3}' | tr '[:upper:]' '[:lower:]'`"
	if [ "$distro" == "linuxmint" ]; then
		declare codename="`lsb_release -c | awk '{print $2}'`"
		if [ "$codename" == "debian" ]; then
			distro="lmde"
		fi
	fi

	username=`whoami`
	homeFolder=`sudo -u $username -i eval 'echo $HOME'`
	if [ "$1" != "" ]; then
		scriptRootFolder="${1}"
	fi
	if [ "$2" != "" ]; then
		logsFolder="$homeFolder/logs"
		logFile="$logsFolder/${2}"
	fi
	tempFolder="/tmp/linux-app-installer-`date +\"%D-%T\" | tr '/' '.'`"
	thirdPartyRepoFolder="$scriptRootFolder/third-party-repo"
	eulaFolder="$scriptRootFolder/eula"
	preInstallationFolder="$scriptRootFolder/pre-installation"
	postInstallationFolder="$scriptRootFolder/post-installation"
	nonRepositoryAppsFolder="$scriptRootFolder/non-repository-apps"
	installerIconFolder="$scriptRootFolder/icons/installer"

	appListFile="$scriptRootFolder/etc/applicationList.$distro"
	askpass="$tempFolder/askpass.sh"
	
	dialogWidth=$((`tput cols` - 4))
	dialogHeight=$((`tput lines` - 6))
	zenityWidth=770
	zenityHeight=400

	repoCommands=""
	preInstallationCommands=""
	packageCommands=""
	nonRepoAppCommands=""
	postInstallationCommands=""
	targetFolder=""

	# Set debconf interface
	if [ -z $DISPLAY ]; then
		debconfInterface="Dialog"
	else
		if [ "$KDE_FULL_SESSION" != "true" ]; then
			debconfInterface="Gnome"
		else
			debconfInterface="Kde"
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
function selectLanguage
{
	declare ISO639_1=${LANG:0:2}
	declare LANGUAGE_FILE="$scriptRootFolder/languages/"$ISO639_1".properties"

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
		if [ "$KDE_FULL_SESSION" != "true" ]; then
			sudoHundler="gksudo"; sudoOption="-S"; sudoPackage="gksu"
		else
			sudoHundler="kdesudo"; sudoOption="-c"; sudoPackage="kdesudo"
		fi
		if [ "`dpkg -s $sudoPackage 2>&1 | grep "installed"`" == "" ]; then
			echo "$needToInstallPackage $sudoPackage" > "$logFile"; echo "$needToInstallPackage $sudoPackage"
			notify-send -i "$installerIconFolder/applications-other.svg" "$linuxAppInstallerTitle" "$needToInstallPackage $sudoPackage" 2>>"$logFile";
			zenity --error --text="$needToInstallPackage $sudoPackage" --window-icon="$installerIconFolder/tux32.png" 2>>"$logFile"
			exit 1
		fi			
		
		declare neededPackages
		if [ "`dpkg -s zenity 2>&1 | grep "installed"`" == "" ]; then
			neededPackages+="zenity"
		fi
		if [ "`dpkg -s libnotify-bin 2>&1 | grep "installed"`" == "" ]; then
			if [ "$neededPackages" != "" ]; then neededPackages+=" "; fi
			neededPackages+="libnotify-bin"
		fi
		if [ "$distro" == "ubuntu" ] && [ "$KDE_FULL_SESSION" == "true" ]; then
			# KDE needs to install Debconf dependencies.
			if [ "`dpkg -s libqtgui4-perl 2>&1 | grep "installed"`" == "" ]; then
				if [ "$neededPackages" != "" ]; then neededPackages+=" "; fi
				neededPackages+="libqtgui4-perl"
			fi
		fi
		if [ "$neededPackages" != "" ]; then
			`$sudoHundler $sudoOption "apt-get -y install $neededPackages" 1>/dev/null 2>>"$logFile"`
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
function prepareScript
{
	initCommonVariables "${1}" "${2}"
	selectLanguage
	
	# Create temporal folders and files
	mkdir -p "$tempFolder"
	if [ -n "$DISPLAY" ]; then
		echo -e "#!/bin/bash\nzenity --password --title \"$askAdminPassword\"" > "$askpass"
		chmod +x "$askpass"
	fi
	mkdir -p "$logsFolder"
	rm -f "$logFile"

	installNeededPackages
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
	declare eulaFilename="$1" line lineWithoutSpaces
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
# This funtion checks if exist an application subscript file in a distro
# subfolder or in a root folder specified by parameter.
#
# Parameters: 
#	rootFolder: root folder where to check if the file exits.
#	appName: application name
# Return: none
##########################################################################
function checkFolderThatContainsFile
{
	if [ "$1" != "" ] && [ "$2" != "" ]; then
		declare rootFolder="$1" appFile=$2".sh"

		if [ -f "$rootFolder/$distro/$appFile" ]; then
			targetFolder="$rootFolder/$distro"
		else
			if [ -f "$rootFolder/$appFile" ]; then
				targetFolder="$rootFolder"
			else
				targetFolder=""
			fi
		fi
	fi
}

##########################################################################
# This funtion sets commands to be executed to add the third-party
# repository of an application specified by parameter.
#
# Parameters: 
#	appName: application name
# Return: 
#	repoCommands: complete list of commands to add third-party-repos
##########################################################################
function prepareThirdPartyRepository
{
	if [ "$1" != "" ]; then
		declare appName="$1" appFile="$1.sh"
		repoCommands+="echo \"# $addingThirdPartyRepo $appName\"; echo \"$addingThirdPartyRepo $appName ...\" >> \"$logFile\";"
		dialogBoxFunction "$addingThirdPartyRepo $appName ..."
		repoCommands+="bash \"$targetFolder/$appFile\" $scriptRootFolder $username 2>>\"$logFile\" $dialogBox;"
	fi
}


##########################################################################
# This funtion sets commands to be executed before the installation of an
# application specified by parameter.
#
# Parameters: 
#	appName: application name.
# Return: 
#	preInstallationCommands: pre-installation commands.
##########################################################################
function preparePreInstallationCommands
{
	if [ "$1" != "" ]; then
		declare appName="$1" appFile="$1.sh"
		preInstallationCommands+="echo \"# $preparingInstallationOf $appName\"; echo \"$preparingInstallationOf $appName ...\" >> \"$logFile\";"
		dialogBoxFunction "$preparingInstallationOf $appName ..."
		preInstallationCommands+="bash \"$targetFolder/$appFile\" $scriptRootFolder $username 2>>\"$logFile\" $dialogBox;"
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
		declare -a packagesToInstall=($1)
		declare -i totalPackagesToInstall=${#packagesToInstall[@]} index=1
		declare package

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
		declare appName="$1" appFile="$1.sh"
		if [ -z $DISPLAY ]; then
			nonRepoAppCommands+="clear;"
		fi
		nonRepoAppCommands+="echo \"# $installingNonRepoApp $appName\"; echo \"$installingNonRepoApp $appName ...\" >> \"$logFile\";"
		nonRepoAppCommands+="bash \"$targetFolder/$appFile\" $scriptRootFolder $username 2>>\"$logFile\";"
	fi
}


##########################################################################
# This funtion sets commands to be executed after the installation of an 
# application specified by parameter.
#
# Parameters: 
#	appName: application name.
# Return: 
#	postInstallationCommands: post-installation commands.
##########################################################################
function preparePostInstallationCommands
{
	if [ "$1" != "" ]; then
		declare appName="$1" appFile="$1.sh"
		postInstallationCommands+="echo \"# $settingUpApplication $appName\"; echo \"$settingUpApplication $appName ...\" >> \"$logFile\";"
		dialogBoxFunction "$settingUpApplication $appName ..."
		postInstallationCommands+="bash \"$targetFolder/$appFile\" $scriptRootFolder $username 2>>\"$logFile\" $dialogBox;"
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
	if [ "$repoCommands" != "" ] || [ "$preInstallationCommands" != "" ] || [ "$packageCommands" != "" ] || [ "$nonRepoAppCommands" != "" ] || [ "$postInstallationCommands" != "" ]; then
		# Set default Debconf interface to use	
		declare commands="echo \"# $settingDebconfInterface\"; echo \"$settingDebconfInterface ...\" >> \"$logFile\";"
		dialogBoxFunction "$settingDebconfInterface"
		commands+="echo debconf debconf/frontend select $debconfInterface | debconf-set-selections 2>>\"$logFile\" $dialogBox;"

		if [ "$repoCommands" != "" ] || [ "$preInstallationCommands" != "" ]; then
			commands+="$repoCommands $preInstallationCommands "
			# Update repositories
			commands+="echo \"# $updatingRepositories\"; echo \"$updatingRepositories ...\" >> \"$logFile\";"
			dialogBoxFunction "$updatingRepositories"
			commands+="apt-get update --fix-missing 2>>\"$logFile\" $dialogBox;"
		fi

		# Install repositories and packages
		commands+="$packageCommands $nonRepoAppCommands $postInstallationCommands"

		commands+="echo \"# $cleaningTempFiles\"; echo \"$cleaningTempFiles ...\" >> \"$logFile\";"
		declare cleanTempFilesCommands="apt-get -y autoremove 2>>\"$logFile\"; apt-get clean 2>>\"$logFile\"; rm -rf \"$tempFolder\";"
		dialogBoxFunction "$cleaningTempFiles ..."
		commands+="bash -c \"$cleanTempFilesCommands\" $dialogBox;"

		commands+="echo \"# $installationFinished\"; echo \"$installationFinished\" >> \"$logFile\";"
		commands+="chown $username:$username \"$logFile\" 2>>\"$logFile\""

		if [ -z $DISPLAY ]; then
			clear; sudo bash -c "$commands"
			# Show log
			dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $dialogHeight $dialogWidth
		else
			declare autoclose
			if [ "$nonRepoAppCommands" == "" ]; then
				autoclose="--auto-close"
			fi

			( SUDO_ASKPASS="$askpass" sudo -A bash -c "$commands" ) |
			zenity --progress --title="$linuxAppInstallerTitle" --no-cancel --pulsate $autoclose --width=$zenityWidth --window-icon="$installerIconFolder/tux32.png"
			# Show notification and log
			notify-send -i "$installerIconFolder/logviewer.svg" "$linuxAppInstallerTitle" "$logFileLocation\n$logFile"
			zenity --text-info --title="$linuxAppInstallerTitle Log" --filename="$logFile" --width=$zenityWidth --height=$zenityHeight --window-icon="$installerIconFolder/tux32.png"
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
		declare -a appsToInstall=(${1})
		declare appName packagesToInstall

		for appName in "${appsToInstall[@]}"; do
			# Check if exists subscript to add third-party repository
			checkFolderThatContainsFile "$thirdPartyRepoFolder" "$appName"
			if [ "$targetFolder" != "" ]; then
				prepareThirdPartyRepository "$appName"
			fi

			# Check if exists subscript to execute pre-installation commands
			checkFolderThatContainsFile "$preInstallationFolder" "$appName"
			if [ "$targetFolder" != "" ]; then
				preparePreInstallationCommands "$appName"
			fi

			# Delete blank and comment lines,then filter by application name and take package list (third column forward to the end)
			packagesToInstall+="`cat \"$appListFile\" | awk -v app=$appName '!/^($|#)/{if ($2 == app) for(i=3;i<=NF;i++)printf \"%s\",$i (i==NF?ORS:OFS)}'` "

			# Check if exists subscript to install a non-repository application
			checkFolderThatContainsFile "$nonRepositoryAppsFolder" "$appName"
			if [ "$targetFolder" != "" ]; then
				prepareNonRepositoryApplication "$appName"
			fi

			# Check if exists subscript to execute post-installation commands
			checkFolderThatContainsFile "$postInstallationFolder" "$appName"
			if [ "$targetFolder" != "" ]; then
				preparePostInstallationCommands "$appName"
			fi
		done

		prepareRepositoryPackages "$packagesToInstall"
		executeCommands
	fi
}

