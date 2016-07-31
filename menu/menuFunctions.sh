#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 31/07/2016
# Licence: MIT
##########################################################################


##########################################################################
# This function get the height of a Dialog box/Zenity window.
#
# Parameters: 
#	rowsNumber: Number of rows (elements) of the list
# Return:
#	height: height of Dialog box / Zenity window
##########################################################################
function getHeight
{
	local rowsNumber=$1

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
# This function gets option parameters of each row of Dialog box / 
# Zenity window. One row per category
#
# Parameters: none
# Return:
#	options: parameters of the row 
##########################################################################
function getCategoryOptions
{
	local categoryName categoryDescription options=""
	for categoryName in "${categoryArray[@]}"; do 
		eval categoryDescription=\$$categoryName"Description"
		if [ -z $DISPLAY ]; then
			options+="\"$categoryDescription\" \"\" off "
		else
			options+="false \"$categoryName\" \"$categoryDescription\" \"\" "
		fi
	done
	echo "$options"
}


##########################################################################
# This function gets a category list window for Dialog box / Zenity.
# First row: all categories. Rest of rows: one per category.
#
# Parameters: 
# 	firstTime: true if is the first time to access this method.
#   		   That means, show categories without any selection.
# Return:
#	window: Dialog box / Zenity window that shows the category list.
##########################################################################
function getCategoriesWindow
{
	local firstTime="$1" selectedApps=${selectedAppsMap[@]} totalCategoriesNumber=$((${#categoryArray[@]}+1))
	local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
	local rows window text="$selectCategories" height=$( getHeight $totalCategoriesNumber)

	if [ "$selectedApps" != "" ]; then
		text+="\n$noSelectCategories"
	fi

	if [ -z $DISPLAY ]; then
		local checked
		if [ "$firstTime" == "true" ]; then checked="on"; else checked="off"; fi
		# Set first row: ALL categories
		rows="\"[$all]\" \"\" $checked "
		# Set rest of rows. One per category
		rows+="$( getCategoryOptions )"
		# Create dialog box (terminal mode)
		window="dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$text\" $height $width $totalCategoriesNumber $rows"
	else
		local hideColumns="--hide-column=2" zenityWidth=0
		local formattedText="<span font='$fontFamilyText $fontSizeCategory'>$text</span>"
		if [ "$selectedApps" != "" ]; then zenityWidth=$width; else hideColumns+=",4"; fi
		# Set first row: ALL categories
		rows="$firstTime \"[$all]\" \"[$all]\" \"\" "
		# Set rest of rows. One per category
		rows+="$( getCategoryOptions )"
		# Create zenity window (desktop mode)
		window="zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$zenityWidth --height=$height --column \"\" --column \"$categoryLabel\" --column \"$categoryLabel\" --column \"$selecteAppsLabel\" $rows $hideColumns --window-icon=\"$installerIconFolder/tux32.png\""
	fi
	echo "$window"
}


##########################################################################
# This function shows a Dialog/Zenity box to let the user selects
# categories to browse.
#
# Parameters: 
#	firstTime: "true" if it's the first time you access this window
# Return:
#	selected categories to browse them (| delimiter character)
##########################################################################
function selectCategoriesToBrowse
{
	local firstTime="$1" selection

	# Get selected categories from Dialog box / Zenity window
	selection=`eval $( getCategoriesWindow "$firstTime" )`
	if [[ $? -ne 0 ]]; then	exit 0; fi

	if [ "$selection" != "" ]; then
		declare -ag selectionArray
		IFS='|' read -ra selectionArray <<< "$selection"

		if [ "${selectionArray[0]}" == "[$all]" ]; then
			local allCategories=`echo "${categoryArray[@]}"`
			echo "${allCategories// /|}"
		else
			if [ -z $DISPLAY ]; then
				local categoryDescription assignment supress selectedCategories=""
				for categoryDescription in "${selectionArray[@]}"; do
					assignment=`cat "$languageFile" | grep "$categoryDescription"`
					supress="Description=\"$categoryDescription\""
					selectedCategories+="`echo "${assignment%$supress}|"`"
				done
				echo "$selectedCategories"
			else
				echo "$selection"
			fi
		fi
	else
		echo ""
	fi
}


##########################################################################
# This function gets option parameters of each row of Dialog box / 
# Zenity window. One row per application of a specified category
#
# Parameters:
#	categoryName: Category name
# 	applicationArray: application list of a specified category
# Return:
#	options: parameters of the row 
##########################################################################
function getApplicationOptions
{
	local categoryName="$1" appName appDescription appObservation options="" appNameForMenu  enabled index=0 selectedApp
	declare -ag applicationArray=(${2}) selectedAppsArray

	for appName in "${applicationArray[@]}"; do
		# application name without '_' character as showed in window
		appNameForMenu="`echo $appName | tr '_' ' '`"
		eval appDescription=\$$appName"Description"
		eval appObservation=\$$appName"Observation"

		# NO SE PQ ES NECESARIO PASAR DE MAPA A ARRAY. MIRAR ESTA PARTE MAS TARDE
		# OBTIENE LAS APLICACIONES SELECCIONADAS DE UNA CATEGORIA
			IFS='.' read -ra selectedAppsArray <<< "${selectedAppsMap[$categoryName]}"
		# DETERMINA SI LA APLICACION HA SIDO SELECCIONADA
			selectedApp="`echo ${selectedAppsArray[$index]}`"
		
		if [ -z $DISPLAY ]; then
			if [ "$appNameForMenu" == "$selectedApp" ]; then enabled="on"; else enabled="off"; fi
			options+="\"$appNameForMenu\" \"$appDescription. $appObservation\" $enabled "		
		else
			if [ "$appNameForMenu" == "$selectedApp" ]; then enabled="true"; else enabled="false"; fi
			options+="$enabled \"$appNameForMenu\" \"$appDescription\" \"$appObservation\" "					
		fi
		if [ "$enabled" == "true" ] || [ "$enabled" == "on" ]; then
			index=$(($index+1))					
		fi
	done
	echo "$options"
}


##########################################################################
# This function gets a category list window for Dialog box / Zenity.
# First row: all categories. Rest of rows: one per category.
#
# Parameters: 
# 	applicationArray: application list of a specified category
#	categoryName: Category name
#	categoryDescription: Category description
#	categoryNumber: Number of category in same order as showed in window
#	totalSelectedCategories: Number of total selected categories
# Return:
#	window: Dialog box / Zenity window that shows the application list.
##########################################################################
function getApplicationsWindow
{
	declare -ag applicationArray=(${1})
	local categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCategories="$5"
	local height=$( getHeight $appsNumber) appRows
	local checklistText="$categoryLabel $categoryNumber/$totalSelectedCategories: $categoryDescription"

 	if [ -z $DISPLAY ]; then
 		local appsNumber=$((${#applicationArray[@]}+1))
 		local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
 		# Set first row: ALL applications
 		appRows="\"[$all]\" \"\" off "
 		# Set rest of rows. One per aplication
 		appRows+=$( getApplicationOptions "$applicationArray" "categoryName" )
 		# Create dialog box (terminal mode)
 		window="dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $width $appsNumber $appRows"
 	else
		local formattedText="<span font='$fontFamilyText $fontSizeApps'>$checklistText</span>"
		# Set first row: ALL applications
		appRows+="false \"[$all]\" \"\" \"\" "
		# Set rest of rows. One per aplication
		appRows+=$( getApplicationOptions "$applicationArray" "categoryName" )
		# Create zenity window (desktop mode)
		window="zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows --window-icon=\"$installerIconFolder/tux32.png\""
 	fi
 	echo "$window"
}


##########################################################################
# This function shows a Dialog/Zenity box to let the user selects
# applications to install from a category.
#
# Parameters: 
# 	applicationArray: application list of a specified category
#	categoryName: Category name
#	categoryDescription: Category description
#	categoryNumber: Number of category in same order as showed in window
#	totalSelectedCategories: Number of total selected categories
# Return:
#	Selected apps from a specific category
##########################################################################
function selectAppsToInstallByCategory
{
	declare -ag applicationArray=(${1})
	local categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCategories="$5"
	selection=`eval "$( getApplicationsWindow "$applicationArray" "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCategories")"`
	# Check if exit category menu
	if [[ $? -ne 0 ]]; then	break; fi

	if [ "$selection" != "" ]; then
		declare -ag selectionArray
		IFS='|' read -ra selectionArray <<< "$selection"
		if [ "${selectionArray[0]}" == "[$all]" ]; then
			local allApps="`echo ${applicationArray[@]}`"
			echo "`echo ${allApps// /. } | tr '_' ' '`"
		else
			echo "${selection//|/. }"
		fi
	else
		echo ""
	fi
}


##########################################################################
# This function calls other functions to show category box and all others
# application boxes to let the user selects applications to install. 
#
# Parameters: none
# Return:
#	seledtedApps: selected applications to be installed
##########################################################################
function menu
{
	. $scriptRootFolder/menu/menuVariables.sh
	declare -ag selectedCategories
	local firstTime="true"

	# Repeat select categories and applications windows until not selected categories
	while [ "`echo ${selectedCategories[@]}`" != "" ] || [ $firstTime ]; do
		local categoryNumber=1

		IFS='|' read -ra selectedCategories <<< "$( selectCategoriesToBrowse $firstTime )"
		firstTime="false"

		if [ "`echo ${selectedCategories[@]}`" != "" ]; then
			local totalSelectedCategories=${#selectedCategories[@]} categoryName

			for categoryName in "${selectedCategories[@]}"; do
				# Each category has it's own screen
				local categoryDescription
				eval categoryDescription=\$$categoryName"Description"
				# Delete blank and comment lines,then filter by category name and take application list (second column)
				declare -ag applicationArray=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)
				selectedAppsMap[$categoryName]=$( selectAppsToInstallByCategory  "$applicationArray" "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCategories" )
				categoryNumber=$(($categoryNumber+1))
			done
		fi
	done
	# Return selected applications
	if [ "`echo ${selectedAppsMap[@]}`" != "" ]; then
		local seledtedApps seledtedAppsFormatted

		for categoryName in "${!selectedAppsMap[@]}"; do
			seledtedApps=`echo ${selectedAppsMap[$categoryName]}`
			seledtedAppsFormatted+="`echo ${seledtedApps//. /|} | tr -d '.' | tr ' ' '_' | tr '|' ' '` "
		done
		echo "$seledtedAppsFormatted"
	else
		echo ""	
	fi
}
