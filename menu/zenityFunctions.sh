#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Desktop Mode. The application to manage windows is Zenity.
# @author 	César Rodríguez González
# @since 		1.3, 2016-08-01
# @version 	1.3, 2016-08-08
# @license 	MIT
##########################################################################

##
# This function show a initial credits popup message
# @since 	v1.3
##
function credits
{
	notify-send -i "$installerIconFolder/tux96.png" "$linuxAppInstallerTitle" "$scriptDescription\n$testedOnLabel\n$testedOnDistrosLinks" -t 10000
}

###
# This function get the height of a Zenity window
# @since 	v1.3
# @param 	int 	rowsNumber 	Number of rows (categories or applications)
# @return int 							Height for current Zenity window
##
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


##
# This function gets option parameters of each row of Zenity window.
# One row per category
# @since 	v1.3
# @return String 					Parameters of category selectable in box
##
function getCategoryOptions
{
	local categoryName categoryDescription options=""
	for categoryName in "${categoryArray[@]}"; do
		eval categoryDescription=\$$categoryName"Description"
		options+="false \"$categoryName\" \"$categoryDescription\" \"${selectedAppsMap[$categoryName]}\" "
	done
	echo "$options"
}


##
# This function gets a category list for Zenity window.
# First row: all categories. Rest of rows: one per category.
# @since 	v1.3
# @param 	boolean	firstTime 	if is the first access to categories window
# @return String 							commands to create categories Zenity window
##
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


##
# This function shows a Zenity window to let the user selects
# categories to browse.
# First row: all categories. Rest of rows: one per category.
# @since 	v1.3
# @param 	boolean	firstTime 	if is the first access to categories box
# @return String 							list of selected categories with character
# 	separator '|'
##
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


##
# This function gets option parameters of each row of Zenity window.
# One row per application of a specified category
# @since 	v1.3
# @param 	String		categoryName 			Name of the actual category
# @param 	String[]	applicationArray 	List of category applications
# @return String 											Parameters of application selectable in box
##
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


##
# This function gets a application list window of a specified category
# First row: all applications. Rest of rows: one per application.
# @since 	v1.3
# @param 	String[]	applicationArray 		list of applications
# @param 	String		categoryName 				name of category
# @param 	String		categoryDescription description of category
# @param 	int				categoryNumber 	    index of category order
# @param 	int				totalSelectedCat		number of selected categories
# @return String 												commands to create app. window
##
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
