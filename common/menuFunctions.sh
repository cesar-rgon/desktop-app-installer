#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 31/05/2014
# Licence: MIT
##########################################################################

function menuAttributes
{
	if [ -z $DISPLAY ]; then
		width=$((`tput cols` - 4))
		maxHeight=$((`tput lines` - 5))
	else
		width=900
		baseHeight=180
		rowHeight=28
		maxHeight=$((`xdpyinfo | grep dimensions | awk '{print $2}' | awk -F "x" '{print $2}'` - 100))
		fontFamilyText="Sans"
		fontSizeText="16"
	fi
}

##########################################################################
# description
#
# Parameters: 
#	rowsNumber:
# Return:
#	height:
##########################################################################
function getHeight
{
	declare -i rowsNumber=$1

	if [ -z $DISPLAY ]; then
		height=$(($rowsNumber+8))
	else
		if [ $rowsNumber -gt 2 ]; then
			height=$(($baseHeight+$(($(($rowsNumber-2))*$rowHeight))))
		else
			height=$baseHeight
		fi
	fi
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
}

##########################################################################
# description
#
# Parameters: none
# Return:
#	mapCategoryRows:
#	mapCategory:
##########################################################################
function getCategoryRows
{
	declare categoryName categoryDescription

	for categoryName in "${categoryArray[@]}"; do
		eval categoryDescription=\$$categoryName"Description"
		if [ -z $DISPLAY ]; then
			mapCategoryRows[$categoryName]="\"$categoryDescription\" \"\" off"
			mapCategory[$categoryDescription]=$categoryName
		else
			mapCategoryRows[$categoryName]="false \"$categoryName\" \"$categoryDescription\" \"\" "		
		fi
	done
}

##########################################################################
# description
#
# Parameters: 
#	firstTime:
# Return:
#	selectedCategories:
##########################################################################
function selectCategoriesToBrowse
{
	declare firstTime="$1"
	declare rows selection

	if [ -z $DISPLAY ]; then
		declare -i totalCategoriesNumber=${#categoryArray[@]}
		# Order by category descriptions
		[ "$firstTime" != "true" ] && rows="\"[$all]\" \"\" off" || rows="\"[$all]\" \"\" on"
		rows+=`echo $(for categoryName in "${!mapCategoryRows[@]}"; do echo ${mapCategoryRows[$categoryName]}; done | sort -k1)`
		selection=`eval "dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$$selectCatogories\n$noSelectCatogories\" $height $width $totalCategoriesNumber $rows"`
	else
		declare formattedText="<span font='$fontFamilyText 11'>$selectCatogories\n$noSelectCategories</span>"
		# Order by category descriptions
		rows="$firstTime \"[$all]\" \"[$all]\" \"\" "		
		rows+=`echo $(for categoryName in "${!mapCategoryRows[@]}"; do echo ${mapCategoryRows[$categoryName]}; done | sort -k3)`
		selection=`eval "zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$categoryLabel\" --column \"$categoryLabel\" --column \"$selecteAppsLabel\" $rows --hide-column=2 --window-icon=\"$installerIconFolder/tux32.png\""`
	fi
	if [[ $? -ne 0 ]]; then
		exit 0    # Exit the script
	fi
	if [ "$selection" != "" ]; then
		declare -a selectionArray
		IFS='|' read -a selectionArray <<< `echo $selection`

		if [ "${selectionArray[0]}" == "[$all]" ]; then
			selectedCategories=( "${categoryArray[@]}" )
		else
			if [ -z $DISPLAY ]; then
				declare -a selectedCategoryDescriptions=(`echo "$selection" | tr '|' ' '`)
				declare -i index=0
				selectedCategories=()
				# Get category name from category description
				for categoryDescription in "${selectedCategoryDescriptions[@]}"; do
					selectedCategories[$index]=${mapCategory[$categoryDescription]}
					index=$(($index+1))
				done
			else
				selectedCategories=(`echo "$selection" | tr '|' ' '`)
			fi
		fi
	else
		selectedCategories=()
	fi
}

##########################################################################
# description
#
# Parameters: none
# Return:
#	appRows:
##########################################################################
function getApplicationRows
{
	declare appName appNameForMenu appDescription appObservation selectedApp enabled appRows
	declare -a selectedAppsArray
	declare -i index=0

	if [ -z $DISPLAY ]; then
		appRows="\"[$all]\" \"\" off "
	else
		appRows+="false \"[$all]\" \"\" \"\" "		
	fi
	for appName in "${appNameArray[@]}"; do
		appNameForMenu="`echo $appName | tr '_' ' '`"
		# Indirect variable reference. Take value from variable <appName>Description
		eval appDescription=\$$appName"Description"
		eval appObservation=\$$appName"Observation"
		IFS='.' read -a selectedAppsArray <<< `echo ${mapSelectedApps[$categoryName]}`
		selectedApp="`echo ${selectedAppsArray[$index]}`"

		if [ -z $DISPLAY ]; then
			enabled=`[ "$appNameForMenu" == "$selectedApp" ] && echo on || echo off`
			appRows+="\"$appNameForMenu\" \"$appDescription. $appObservation\" $enabled "
		else
			enabled=`[ "$appNameForMenu" == "$selectedApp" ] && echo true || echo false`
			appRows+="$enabled \"$appNameForMenu\" \"$appDescription\" \"$appObservation\" "		
		fi
		if [ "$enabled" == "true" ] || [ "$enabled" == "on" ]; then
			index=$(($index+1))					
		fi
	done
	echo "$appRows"
}

##########################################################################
# description
#
# Parameters: 
# Return:
##########################################################################
function selectAppsToInstallByCategory
{
	declare categoryName="$1" checklistText="${2}" selection
	declare appRows=$(getApplicationRows)

	if [ -z $DISPLAY ]; then
		declare -i appsNumber=$3
		declare backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
		selection=`eval "dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $width $appsNumber $appRows"`
	else
		declare formattedText="<span font='$fontFamilyText $fontSizeText'>$checklistText</span>"
		selection=`eval "zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows --window-icon=\"$installerIconFolder/tux32.png\""`
	fi
	if [[ $? -eq 0 ]]; then
		if [ "$selection" != "" ]; then
			declare -a selectionArray
			IFS='|' read -a selectionArray <<< `echo $selection`

			if [ "${selectionArray[0]}" == "[$all]" ]; then
				declare allApps="`echo ${appNameArray[@]}`"
				mapSelectedApps[$categoryName]="`echo ${allApps// /. } | tr '_' ' '`"
			else
				mapSelectedApps[$categoryName]="${selection//|/. }"
			fi
		else
			mapSelectedApps[$categoryName]=""
		fi
	else
		break 	# Exit to category menu
	fi
}

##########################################################################
# description
#
# Parameters: none
# Return:
#	seledtedApps:
##########################################################################
function menu
{
	declare -A mapCategory		# Associatie map wich gets category name from category description
	declare -A mapSelectedApps	# Associate map wich gets selected applications from a category name
	declare -A mapCategoryRows	# Associate map wich gets category rows used by dialog and zenity
	declare -a categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | awk '!x[$0]++'`)  # Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
  	declare -a selectedCategories appNameArray
	declare -i totalCategoriesNumber=${#categoryArray[@]} categoryNumber appsNumber totalSelectedCategories
	declare categoryName categoryDescription checklistText exitWhile="false" firstTime="true"

	menuAttributes
	getCategoryRows # Get category rows for Dialog/Zenity window

	while [ "$exitWhile" == "false" ] ; do
		getHeight $totalCategoriesNumber
		categoryNumber=1
		selectCategoriesToBrowse $firstTime
		firstTime="false"
		if [ "`echo ${selectedCategories[@]}`" == "" ]; then
			exitWhile="true"
			break
		fi

		totalSelectedCategories=${#selectedCategories[@]}
		for categoryName in "${selectedCategories[@]}"; do
			# Each category has it's own screen
			eval categoryDescription=\$$categoryName"Description"
			# Delete blank and comment lines,then filter by category name and take application list (second column)
			appNameArray=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)
			appsNumber=$((${#appNameArray[@]}+1))
			checklistText="$categoryLabel $categoryNumber/$totalSelectedCategories: $categoryDescription"
			getHeight $appsNumber
			selectAppsToInstallByCategory "$categoryName" "$checklistText" $appsNumber
			categoryNumber=$(($categoryNumber+1))
			# Set selected apps in category row of main menu
			eval categoryDescription=\$$categoryName"Description"
			if [ -z $DISPLAY ]; then
				mapCategoryRows[$categoryName]="\"$categoryDescription\" \"`echo ${mapSelectedApps[$categoryName]}`\" off"
			else
				mapCategoryRows[$categoryName]="false \"$categoryName\" \"$categoryDescription\" \"`echo ${mapSelectedApps[$categoryName]}`\" "		
			fi
		done
	done
	if [ "`echo ${mapSelectedApps[@]}`" != "" ]; then
		declare seledtedApps appsFormatted
		for categoryName in "${!mapSelectedApps[@]}"; do
			appsFormatted=`echo ${mapSelectedApps[$categoryName]}`
			seledtedApps+="`echo ${appsFormatted//. /|} | tr -d '.' | tr ' ' '_' | tr '|' ' '` "
		done
		echo "$seledtedApps"
	else
		echo ""	
	fi
}

