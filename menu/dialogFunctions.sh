#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Terminal Mode. The application to manage windows is Dialog.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 01/08/2016
# Licence: MIT
##########################################################################


##########################################################################
# This function get the height of a Dialog box window.
#
# Parameters: 
#	rowsNumber: Number of rows (elements) of the list
# Return:
#	height: height of Dialog box
##########################################################################
function getHeight
{
	local rowsNumber=$1

	height=$(($rowsNumber+8))
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
	echo $height
}


##########################################################################
# This function gets option parameters of each row of Dialog box.
# One row per category
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
		options+="\"$categoryDescription\" \"${selectedAppsMap[$categoryName]}\" off "
	done
	echo "$options"
}


##########################################################################
# This function gets a category list for Dialog box.
# First row: all categories. Rest of rows: one per category.
#
# Parameters: 
# 	firstTime: true if is the first time to access this method.
#   		   That means, show categories without any selection.
# Return:
#	window: Dialog box that shows the category list.
##########################################################################
function getCategoriesWindow
{
	local firstTime="$1" totalCategoriesNumber=$((${#categoryArray[@]}+1))
	local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
	local rows window checked text="$selectCategories" height=$( getHeight $totalCategoriesNumber)

	if [ ${#selectedAppsMap[@]} -gt 0 ]; then
		text+="\n$noSelectCategories"
	fi
	if [ "$firstTime" == "true" ]; then checked="on"; else checked="off"; fi
	# Set first row: ALL categories
	rows="\"[$all]\" \"\" $checked "
	# Set rest of rows. One per category
	rows+="$( getCategoryOptions )"
	# Create dialog box (terminal mode)
	window="dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$text\" $height $width $totalCategoriesNumber $rows"
	echo "$window"
}


##########################################################################
# This function shows a Dialog box to let the user selects
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
	if [[ $? -ne 0 ]]; then	
		echo "$CANCEL_CODE"
	else
		if [ ! -z "$selection" ]; then
			declare -ag selectionArray
			IFS='|' read -ra selectionArray <<< "$selection"

			if [ "${selectionArray[0]}" == "[$all]" ]; then
				local allCategories=`echo "${categoryArray[@]}"`
				echo "${allCategories// /|}"
			else
				local categoryDescription assignment supress selectedCategories=""
				for categoryDescription in "${selectionArray[@]}"; do
					assignment=`cat "$languageFile" | grep -w "\"$categoryDescription\"" | head -n 1`
					supress="Description=\"$categoryDescription\""
					selectedCategories+="`echo "${assignment%$supress}|"`"
				done
				echo "$selectedCategories"
			fi
		else
			echo ""
		fi		
	fi
}


##########################################################################
# This function gets option parameters of each row of Dialog box.
# One row per application of a specified category
#
# Parameters:
#	categoryName: Category name
# 	applicationArray: application list of a specified category
# Return:
#	options: parameters of the row 
##########################################################################
function getApplicationOptions
{
	local categoryName="$1" appName appDescription appObservation options="" appNameForMenu  enabled
	declare -ag applicationArray=("${!2}") selectedAppsArray
	local selectedApps=${selectedAppsMap[$categoryName]}

	for appName in "${applicationArray[@]}"; do
		# application name without '_' character as showed in window
		appNameForMenu="`echo $appName | tr '_' ' '`"
		eval appDescription=\$$appName"Description"
		eval appObservation=\$$appName"Observation"
		local isSelected="`echo $selectedApps | grep -w "$appNameForMenu"`"
		if [ -z "$isSelected" ]; then enabled="off"; else enabled="on"; fi
		options+="\"$appNameForMenu\" \"$appDescription. $appObservation\" $enabled "		
	done
	echo "$options"
}


##########################################################################
# This function gets a category list window for Dialog box.
# First row: all categories. Rest of rows: one per category.
#
# Parameters: 
# 	applicationArray: application list of a specified category
#	categoryName: Category name
#	categoryDescription: Category description
#	categoryNumber: Number of category in same order as showed in window
#	totalSelectedCategories: Number of total selected categories
# Return:
#	window: Dialog box that shows the application list.
##########################################################################
function getApplicationsWindow
{
	declare -ag applicationArray=("${!1}")
	local categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCategories="$5"
	local appsNumber=$((${#applicationArray[@]}+1)) 
	local height=$( getHeight $appsNumber) appRows
	local checklistText="$categoryLabel $categoryNumber/$totalSelectedCategories: $categoryDescription"
	local backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"

 	# Set first row: ALL applications
 	appRows="\"[$all]\" \"\" off "
 	# Set rest of rows. One per aplication
 	appRows+=$( getApplicationOptions "$categoryName" applicationArray[@] )
 	# Create dialog box (terminal mode)
 	window="dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $width $appsNumber $appRows"
 	echo "$window"
}
