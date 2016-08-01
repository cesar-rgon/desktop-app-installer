#!/bin/bash
##########################################################################
# This script contains common functions used by installation scripts.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 01/08/2016
# Licence: MIT
##########################################################################


##########################################################################
# This funtion imports a translation file according to system's language.
# If no exists translation file, by default, it takes english translation. 
#
# Parameters: none
# Return: none
##########################################################################
function selectLanguage
{
	if [ -f "$languageFile" ]; then
		. $languageFile
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
		
		local neededPackages
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
	# Store current username, script root folder and log filename in temporal file
	echo "`whoami`" > /tmp/linux-app-installer-username
	local scriptRootFolder="${1}"
	echo "$scriptRootFolder" > /tmp/linux-app-installer-scriptRootFolder
	echo "${2}" > /tmp/linux-app-installer-logFilename

	# Initialize variables
	linuxAppInstallerTitle="Linux app installer v$(cat $scriptRootFolder/etc/version)"
	. $scriptRootFolder/common/commonVariables.sh

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

	echo "Linux App Installer Logs" > "$logFile"
	echo "========================" >> "$logFile"
	echo "" >> "$logFile"
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
	local eulaFilename="$1" line lineWithoutSpaces
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
# Parameters:
#	targetFolder: root folder that contains file script
#	appName: application name
#   message: message about operation showed in logs
# Return: 
#	scriptCommands: complete list of commands to execute
##########################################################################
function generateCommands
{
	local targetFolder="$1" appName="$2" message="$3" scriptCommands=""
	if [ "$appName" != "" ] && [ "$targetFolder" != "" ]; then
		if [ "$message" != "" ]; then
			dialogBoxFunction "$message $appName ..."
			local messageCommand="echo \"# $message $appName\"; echo \"$message $appName ...\" >> \"$logFile\";"
		fi
		local i386="_i386" x64="_x64"
	
		if [ `uname -m` == "x86_64" ]; then	
			# For 64 bits OS
			if [ -f "$targetFolder/$distro/$appName$x64.sh" ]; then
				scriptCommands+="bash \"$targetFolder/$distro/$appName$x64.sh\" 2>>\"$logFile\" $dialogBox;"
			fi
			if [ -f "$targetFolder/$appName$x64.sh" ]; then
				scriptCommands+="bash \"$targetFolder/$appName$x64.sh\" 2>>\"$logFile\" $dialogBox;"
			fi
		else
			# For 32 bits OS
			if [ -f "$targetFolder/$distro/$appName$i386.sh" ]; then
				scriptCommands+="bash \"$targetFolder/$distro/$appName$i386.sh\" 2>>\"$logFile\" $dialogBox;"
			fi
			if [ -f "$targetFolder/$appName$i386.sh" ]; then
				scriptCommands+="bash \"$targetFolder/$appName$i386.sh\" 2>>\"$logFile\" $dialogBox;"
			fi
		fi
		# For all CPU arquitectures
		if [ -f "$targetFolder/$distro/$appName.sh" ]; then
			scriptCommands+="bash \"$targetFolder/$distro/$appName.sh\" 2>>\"$logFile\" $dialogBox;"
		fi
		if [ -f "$targetFolder/$appName.sh" ]; then
			scriptCommands+="bash \"$targetFolder/$appName.sh\" 2>>\"$logFile\" $dialogBox;"
		fi
	fi
	if [ "$scriptCommands" != "" ]; then
		echo "$messageCommand $scriptCommands"
	else
		echo ""
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
		declare -ag packagesToInstall=($1)
		declare -ig totalPackagesToInstall=${#packagesToInstall[@]} index=1
		local package

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
			packageCommands+="bash \"$scriptRootFolder/common/installapp.sh\" \"$package\" 2>>\"$logFile\" $dialogBox;"

			index=$(($index+1))
		done
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
		local commands="echo \"# $settingDebconfInterface\"; echo \"$settingDebconfInterface ...\" >> \"$logFile\";"
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

		# Delete temp files and packages
		commands+="echo \"# $cleaningTempFiles\"; echo \"$cleaningTempFiles ...\" >> \"$logFile\";"
		local cleanTempFilesCommands="apt-get -y autoremove 2>>\"$logFile\"; apt-get clean 2>>\"$logFile\"; rm -rf \"$tempFolder\";"
		dialogBoxFunction "$cleaningTempFiles ..."
		commands+="bash -c \"$cleanTempFilesCommands\" $dialogBox;"

		commands+="echo \"# $installationFinished\"; echo \"$installationFinished\" >> \"$logFile\";"
		commands+="chown $username:$username \"$logFile\" 2>>\"$logFile\""

		if [ -z $DISPLAY ]; then
			clear; sudo bash -c "$commands"
			# Show log
			dialog --title "Log. $pathLabel: $logFile" --backtitle "$linuxAppInstallerTitle" --textbox "$logFile" $dialogHeight $dialogWidth
		else
			local autoclose
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
		declare -ag appsToInstall=(${1})
		local appName packagesToInstall i386="_i386" x64="_x64"
		for appName in "${appsToInstall[@]}"; do
			repoCommands+=$( generateCommands "$thirdPartyRepoFolder" "$appName" "$addingThirdPartyRepo" )		
			preInstallationCommands+=$( generateCommands "$preInstallationFolder" "$appName" "$preparingInstallationOf" )
			if [ -z $DISPLAY ]; then nonRepoAppCommands+="clear;"; fi
			nonRepoAppCommands+=$( generateCommands "$nonRepositoryAppsFolder" "$appName" "$installingNonRepoApp" )		
			postInstallationCommands+=$( generateCommands "$postInstallationFolder" "$appName" "$settingUpApplication" )		

			# Delete blank and comment lines,then filter by application name and take package list (third column forward to the end)
			packagesToInstall+="`cat \"$appListFile\" | awk -v app=$appName '!/^($|#)/{if ($2 == app) for(i=3;i<=NF;i++)printf \"%s\",$i (i==NF?ORS:OFS)}'` "
		done

		prepareRepositoryPackages "$packagesToInstall"
		executeCommands
	fi
}

