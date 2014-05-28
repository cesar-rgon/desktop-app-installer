#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 28/05/2014
# Licence: MIT
##########################################################################

function menuAttributes
{
	if [ -z $DISPLAY ]; then
		width=$((`tput cols` - 4))
		maxHeight=$((`tput lines` - 5))
	else
		width=900
		maxHeight=$((`xdpyinfo | grep dimensions | awk '{print $2}' | awk -F "x" '{print $2}'` - 100))
		fontFamilyText="Sans"
		fontSizeText="16"

		case "$desktop" in
		"unity" )
			baseHeight=162
			rowHeight=23;;
		"gnome" )
			baseHeight=177
			rowHeight=27;;
		"xfce" )
			baseHeight=162
			rowHeight=23;;
		"lxde" )
			baseHeight=174
			rowHeight=23;;
		"kde" )
			baseHeight=162
			rowHeight=24;;
		"x-cinnamon" )
			baseHeight=150
			rowHeight=22;;
		"mate" )
			baseHeight=150
			rowHeight=22;;
		* )
			baseHeight=177
			rowHeight=27
		esac
	fi
}

function getHeight
{
	local appNumber=$1

	if [ -z $DISPLAY ]; then
		height=$(($appNumber+8))
	else
		if [ $appNumber -gt 2 ]; then
			height=$(($baseHeight+$(($(($appNumber-2))*$rowHeight))))
		else
			height=$baseHeight
		fi
	fi
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
}


function selectAppsToInstall
{
	local appList="${1}"
	local checklistText="${2}"
	local height=$3
	local selection=""
	local command=""

	if [ -z $DISPLAY ]; then
		local appNumber=$4
		local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
		selection=`eval "dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $width $appNumber $appList"`
	else

		local formattedText="<span font='$fontFamilyText $fontSizeText'>$checklistText</span>"
		selection=`eval "zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appList --window-icon=\"$installerIconFolder/tux32.png\""`
	fi
	if [[ $? -ne 0 ]]; then
		# Exit the script
		exit 0
	fi
	if [ "$selection" != "" ]; then
		appsToInstall+="`echo \"$selection\" | tr ' ' '_' | tr '|' ' '` "
	fi
}


function menu
{
	# Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
	local categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | awk '!x[$0]++'`)
	local categoryName=""
	local totalCategoriesNumber=${#categoryArray[@]}
	local categoryDescription=""
	local categoryNumber=1
	local appNameArray=()
	local appNumber=0
	local appName=""
	local appDescription=""
	local appList=""
	local checklistText=""
	local appNameForMenu=""
	appsToInstall=""

	menuAttributes
	for categoryName in "${categoryArray[@]}"; do
		# Each category has it's own screen
		eval categoryDescription=\$$categoryName"Description"
		# Delete blank and comment lines,then filter by category name and take application list (second column)
		appNameArray=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)
		appNumber=${#appNameArray[@]}
		appList=""
		checklistText="$categoryLabel $categoryNumber/$totalCategoriesNumber: $categoryDescription"
		getHeight $appNumber

		for appName in "${appNameArray[@]}"; do
			# Indirect variable reference. Take value from variable <appName>Description
			appNameForMenu="`echo $appName | tr '_' ' '`"
			eval appDescription=\$$appName"Description"
			eval appObservation=\$$appName"Observation"
			
			if [ -z $DISPLAY ]; then
				appList+="\"$appNameForMenu\" \"$appDescription. $appObservation\" off "
			else
				appList+="off \"$appNameForMenu\" \"$appDescription\" \"$appObservation\" "		
			fi
		done
		selectAppsToInstall "$appList" "$checklistText" $height $appNumber
		categoryNumber=$(($categoryNumber+1))
	done

	echo "$appsToInstall"
}

