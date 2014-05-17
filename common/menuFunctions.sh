#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
#
# Author: César Rodríguez González
# Version: 1.1
# Last modified date (dd/mm/yyyy): 17/05/2014
# Licence: MIT
##########################################################################

function menuWidthHeight {
	if [ -z $DISPLAY ]; then
		maxDialogHeight=$((`tput lines` - 5))
	else
		maxZenityHeight=$((`xdpyinfo | grep dimensions | awk '{print $2}' | awk -F "x" '{print $2}'` - 100))
		case "$desktop" in
		"unity" )
			zenityWidth=780
			zenityBaseHeight=162
			zenityRowHeight=23;;
		"gnome" )
			zenityWidth=770
			zenityBaseHeight=177
			zenityRowHeight=27;;
		"xfce" )
			zenityWidth=680
			zenityBaseHeight=162
			zenityRowHeight=23;;
		"lxde" )
			zenityWidth=790
			zenityBaseHeight=165
			zenityRowHeight=23;;
		"kde" )
			zenityWidth=680
			zenityBaseHeight=162
			zenityRowHeight=24;;			
		* )
			zenityWidth=790
			zenityBaseHeight=177
			zenityRowHeight=27
		esac
	fi
}

function menu {
	local appsToInstall=""
	local box=""	
	if [ -z $DISPLAY ]; then
		box="dialog"
	else
		box="zenity"
	fi
	menuWidthHeight
	# Check if dialog or zenity has been installed
	if [ "`dpkg -s $box 2>&1 | grep "installed"`" != "" ]; then
		# Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
		local categoryArray=(`cat "$appListFile" | awk '!/^($|[:space:]*#)/{ print $1; }' | awk '!x[$0]++'`)
		local categoryName=""
		local categoryDescription=""
		local categoryNumber=1
		local totalCategoriesNumber=${#categoryArray[@]}
		local appsToInstall=""
		local selectedOptionsFile="$tempFolder/selectedOptions"
		local appNameArray=()
		local appNumber=0
		local command=""
		local appName=""
		local appDescription=""
		local selectedApps=""
		local index=1
		local zenityHeight=0
		local dialogHeight=0

		for categoryName in "${categoryArray[@]}"; do
			# Each category has it's own screen
			eval categoryDescription=\$$categoryName"Description"
			# Delete blank and comment lines,then filter by category name and take application list (second column)
			appNameArray=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|[:space:]*#)/{ if ($1 == category) print $2; }'`)
			appNumber=${#appNameArray[@]}
			index=1
	
			if [ -z $DISPLAY ]; then
				dialogHeight=$(($appNumber+8))
				if [ $dialogHeight -gt $maxDialogHeight ]; then
					dialogHeight=$maxDialogHeight
				fi
				command="dialog --title \"$mainMenuLabel\" --backtitle \"$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor\" --stdout --separate-output --checklist \"\n$categoryLabel $categoryNumber/$totalCategoriesNumber: $categoryDescription\" $dialogHeight $dialogWidth $appNumber "
			else
				if [ $appNumber -gt 2 ]; then
					zenityHeight=$(($zenityBaseHeight+$(($(($appNumber-2))*$zenityRowHeight))))
					if [ $zenityHeight -gt $maxZenityHeight ]; then
						zenityHeight=$maxZenityHeight
					fi
				else
					zenityHeight=$zenityBaseHeight
				fi
				command="zenity --list --checklist --width=$zenityWidth --height=$zenityHeight --title=\"$linuxAppInstallerTitle\" --text \"$categoryLabel $categoryNumber/$totalCategoriesNumber: $categoryDescription\" --column \"$selection\" --column \"#\" --column=\"$value\" "
			fi
		
			for appName in "${appNameArray[@]}"; do
				# Indirect variable reference. Take value from variable <appName>Description
				eval appDescription=\$$appName"Description"
				if [ -z $DISPLAY ]; then
					command+="$index \"$appDescription\" off "
				else
					command+="off $index \"$appDescription\" "		
				fi
				index=$(($index+1))
			done
			eval "$command" > "$selectedOptionsFile"
			if [[ $? -ne 0 ]]; then
				# Exit the script
				exit 0
			fi
	
			if [ -z $DISPLAY ]; then
				selectedApps=`cat "$selectedOptionsFile"`	
			else
			selectedApps=`cat "$selectedOptionsFile" | tr '|' ' '`
			fi
		
			for option in $selectedApps; do
				index=$(($option-1))
				appsToInstall+="${appNameArray[$index]} "
			done
	
			categoryNumber=$(($categoryNumber+1))
		done
	fi
	echo "$appsToInstall"
}
