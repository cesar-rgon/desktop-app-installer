#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Desktop Mode. The application to manage windows is Zenity.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 01/08/2016
# Licence: MIT
##########################################################################


##########################################################################
# This function get the height of a Zenity window.
#
# Parameters: 
#	rowsNumber: Number of rows (elements) of the list
# Return:
#	height: height of Zenity window
##########################################################################
function getHeight
{
	local rowsNumber=$1

	if [ $rowsNumber -gt 2 ]; then
		height=$(($baseHeight+$(($(($rowsNumber-2))*$rowHeight))))
	else
		height=$baseHeight
	fi
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
	echo $height
}


##########################################################################
# This function gets option parameters of each row of Zenity window.
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
		options+="false \"$categoryName\" \"$categoryDescription\" \"${selectedAppsMap[$categoryName]}\" "
	done
	echo "$options"
}


##########################################################################
# This function gets a category list for Zenity window.
# First row: all categories. Rest of rows: one per category.
#
# Parameters: 
# 	firstTime: true if is the first time to access this method.
#   		   That means, show categories without any selection.
# Return:
#	window: Zenity window that shows the category list.
##########################################################################
function getCategoriesWindow
{
	local firstTime="$1" totalCategoriesNumber=$((${#categoryArray[@]}+1))
	local rows window text="$selectCategories" height=$( getHeight $totalCategoriesNumber)
	local hideColumns="--hide-column=2" zenityWidth=0
	local formattedText="<span font='$fontFamilyText $fontSizeCategory'>$text</span>"

	if [ ${#selectedAppsMap[@]} -gt 0 ]; then
		text+="\n$noSelectCategories"
	fi
	if [ ${#selectedAppsMap[@]} -gt 0 ]; then zenityWidth=$width; else hideColumns+=",4"; fi
	# Set first row: ALL categories
	rows="$firstTime \"[$all]\" \"[$all]\" \"\" "
	# Set rest of rows. One per category
	rows+="$( getCategoryOptions )"
	# Create zenity window (desktop mode)
	window="zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$zenityWidth --height=$height --column \"\" --column \"$categoryLabel\" --column \"$categoryLabel\" --column \"$selecteAppsLabel\" $rows $hideColumns --window-icon=\"$installerIconFolder/tux32.png\""
	echo "$window"
}


##########################################################################
# This function shows a Zenity window to let the user selects
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
				echo "$selection"
			fi
		else
			echo ""
		fi		
	fi
}


##########################################################################
# This function gets option parameters of each row of Zenity window.
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
		if [ -z "$isSelected" ]; then enabled="false"; else enabled="true"; fi			
		options+="$enabled \"$appNameForMenu\" \"$appDescription\" \"$appObservation\" "					
	done
	echo "$options"
}


##########################################################################
# This function gets a category list window for Zenity.
# First row: all categories. Rest of rows: one per category.
#
# Parameters: 
# 	applicationArray: application list of a specified category
#	categoryName: Category name
#	categoryDescription: Category description
#	categoryNumber: Number of category in same order as showed in window
#	totalSelectedCategories: Number of total selected categories
# Return:
#	window: Zenity window that shows the application list.
##########################################################################
function getApplicationsWindow
{
	declare -ag applicationArray=("${!1}")
	local categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCategories="$5"
	local appsNumber=$((${#applicationArray[@]}+1)) 
	local height=$( getHeight $appsNumber) appRows
	local checklistText="$categoryLabel $categoryNumber/$totalSelectedCategories: $categoryDescription"
 	local formattedText="<span font='$fontFamilyText $fontSizeApps'>$checklistText</span>"

	# Set first row: ALL applications
	appRows+="false \"[$all]\" \"\" \"\" "
	# Set rest of rows. One per aplication
	appRows+=$( getApplicationOptions "$categoryName" applicationArray[@] )
	# Create zenity window (desktop mode)
	window="zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows --window-icon=\"$installerIconFolder/tux32.png\""
 	echo "$window"
}
