#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Terminal Mode. The application to manage windows is Dialog.
# @author 	César Rodríguez González
# @since 	1.3, 2016-08-01
# @version 	1.3, 2016-08-11
# @license 	MIT
##########################################################################

##
# This function show a initial credits dialog box
# @since 	v1.3
##
function credits
{
	local whiteSpaces="                  "
	printf "\n%.21s%s\n" "$scriptNameLabel:$whiteSpaces" "$linuxAppInstallerTitle" > $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$scriptDescriptionLabel:$whiteSpaces" "$scriptDescription" >> $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$testedOnLabel:$whiteSpaces" "$testedOnDistros" >> $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$githubProjectLabel:$whiteSpaces" "$githubProjectUrl" >> $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$authorLabel:$whiteSpaces" "$author" >> $tempFolder/linux-app-installer.credits
	dialog --title "$creditsLabel" --backtitle "$linuxAppInstallerTitle" --stdout --textbox $tempFolder/linux-app-installer.credits 11 100
}


##
# This function get the height of a Dialog box
# @since 	v1.3
# @param 	int 	rowsNumber 	Number of rows (categories or applications)
# @return int 							Height for current Dialog box
##
function getHeight
{
	local rowsNumber=$1 height

	height=$(($rowsNumber+8))
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
	echo $height
}


##
# This function gets option parameters of each row of Dialog box.
# One row per category
# @since 	v1.3
# @param	String[] categoryArray	List of categories
# @return String 									Parameters of category selectable in box
##
function getCategoryOptions
{
	local categoryArray=(${!1})
	local categoryName categoryDescription options=""
	for categoryName in "${categoryArray[@]}"; do
		eval categoryDescription=\$$categoryName"Description"
		options+="\"$categoryDescription\" \"${selectedAppsMap[$categoryName]}\" off "
	done
	echo "$options"
}


##
# This function gets a category list for Dialog box.
# First row: all categories. Rest of rows: one per category.
# @since 	v1.3
# @param	String[] categoryArray	List of categories
# @param 	boolean	firstTime 	if is the first access to categories box
# @return String 							commands to create categories Dialog box
##
function getCategoriesWindow
{
	local categoryArray=(${!1}) firstTime="$2"
	local totalCategoriesNumber=$((${#categoryArray[@]}+1))
	local rows window checked text="$selectCategories" height=$( getHeight $totalCategoriesNumber)

	if [ ${#selectedAppsMap[@]} -gt 0 ]; then
		text+="\n$noSelectCategories"
	fi
	if [ "$firstTime" == "true" ]; then checked="on"; else checked="off"; fi
	# Set first row: ALL categories
	rows="\"[$all]\" \"\" $checked "
	# Set rest of rows. One per category
	rows+=$( getCategoryOptions categoryArray[@] )
	# Create dialog box (terminal mode)
	window="dialog --title \"$mainMenuLabel\" --backtitle \"$linuxAppInstallerTitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$text\" $height $width $totalCategoriesNumber $rows"
	echo "$window"
}


##
# This function shows a Dialog box to let the user selects
# categories to browse.
# First row: all categories. Rest of rows: one per category.
# @since 	v1.3
# @param	String[] categoryArray	List of categories
# @param 	boolean	firstTime 	if is the first access to categories box
# @return String 							list of selected categories with character
# 	separator '|'
##
function selectCategoriesToBrowse
{
	local categoryArray=(${!1}) firstTime="$2" selection

	# Get selected categories from Dialog box / Zenity window
	selection=`eval $( getCategoriesWindow categoryArray[@] "$firstTime" )`
	if [[ $? -ne 0 ]]; then
		echo "$CANCEL_CODE"
	else
		if [ ! -z "$selection" ]; then
			local selectionArray
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


##
# This function gets option parameters of each row of Dialog box.
# One row per application of a specified category
# @since 	v1.3
# @param 	String[]	applicationArray 	List of category applications
# @param 	String		categoryName 			Name of the actual category
# @return String 											Parameters of application selectable in box
##
function getApplicationOptions
{
	local applicationArray=("${!1}") categoryName="$2"
	local selectedApps=${selectedAppsMap[$categoryName]} appName appDescription appObservation options appNameForMenu  enabled

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


##
# This function gets a application list box of a specified category
# First row: all applications. Rest of rows: one per application.
# @since 	v1.3
# @param 	String[]	applicationArray 		list of applications
# @param 	String		categoryName 				name of category
# @param 	String		categoryDescription description of category
# @param 	int				categoryNumber 	    index of category order
# @param 	int				totalSelectedCat		number of selected categories
# @return String 												commands to create application box
##
function getApplicationsWindow
{
	local applicationArray=(${!1}) categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCat="$5"
	local totalApplicationNumber=$((${#applicationArray[@]}+1))
	local height=$( getHeight $totalApplicationNumber)
	local checklistText="$categoryLabel $categoryNumber/$totalSelectedCat: $categoryDescription" appRows

 	# Set first row: ALL applications
 	appRows="\"[$all]\" \"\" off "
 	# Set rest of rows. One per aplication
 	appRows+=$( getApplicationOptions applicationArray[@] "$categoryName" )
 	# Create dialog box (terminal mode)
 	window="dialog --title \"$mainMenuLabel\" --backtitle \"$linuxAppInstallerTitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $width $totalApplicationNumber $appRows"
 	echo "$window"
}
