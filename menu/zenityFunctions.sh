#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Desktop Mode. The application to manage windows is Zenity.
# @author 	César Rodríguez González
# @since 		1.3, 2016-08-01
# @version 	1.3, 2016-11-13
# @license 	MIT
##########################################################################

# Associate map wich gets selected applications from a category name
declare -A selectedAppsMap

##
# This function show a initial credits dialog box or popup message
# @since 	v1.3
##
function credits
{
	notify-send -i "$installerIconFolder/tux-shell-console96.png" "$installerTitle"
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
	local baseHeight=180
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
# @param	String[] categoryArray	List of categories
# @return String 					Parameters of category selectable in box
##
function getCategoryOptions
{
	local categoryArray=(${!1})
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
# @param	String[] categoryArray	List of categories
# @param 	boolean	firstTime 	if is the first access to categories window
# @return String 							commands to create categories Zenity window
##
function getCategoriesWindow
{
	local categoryArray=(${!1}) firstTime="$2"
	local totalCategoriesNumber=$((${#categoryArray[@]}+1))
	local rows window text="$selectCategories" height=$( getHeight $totalCategoriesNumber)
	local hideColumns="--hide-column=2" zenityWidth=0
	local formattedText="$scriptDescription. $testedOnLabel:\n$testedOnDistrosLinks\n\n"
	formattedText+="$githubProject: $githubProjectLink\n"
	formattedText+="$documentationLabel: $githubProjectDocLink\n\n"
	formattedText+="<span font='$fontFamilyText $fontSmallSize'>$text</span>"

	if [ ${#selectedAppsMap[@]} -gt 0 ]; then
		text+="\n$noSelectCategories"
	fi
	if [ ${#selectedAppsMap[@]} -gt 0 ]; then zenityWidth=$width; else hideColumns+=",4"; fi
	# Set first row: ALL categories
	rows="$firstTime \"[$all]\" \"[$all]\" \"\" "
	# Set rest of rows. One per category
	rows+=$( getCategoryOptions categoryArray[@] )
	# Create zenity window (desktop mode)
	window="zenity --title=\"$installerTitle\" --text \"$formattedText\" --list --checklist --width=$zenityWidth --height=$((height+25)) --column \"\" --column \"$categoryLabel\" --column \"$categoryLabel\" --column \"$selecteAppsLabel\" $rows $hideColumns --window-icon=\"$installerIconFolder/tux-shell-console32.png\""
	echo "$window"
}


##
# This function shows a Zenity window to let the user selects
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
# @param 	String[]	applicationArray 	List of category applications
# @param 	String		categoryName 			Name of the actual category
# @return String 											Parameters of application selectable in box
##
function getApplicationOptions
{
	local applicationArray=(${!1}) categoryName="$2"
	local selectedApps=${selectedAppsMap[$categoryName]} appName appDescription appObservation options="" appNameForMenu  enabled

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
	local applicationArray=(${!1}) categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCategories="$5"
	local totalApplicationNumber=$((${#applicationArray[@]}+1))
	local height=$( getHeight $totalApplicationNumber ) appRows
	local checklistText="$categoryLabel $categoryNumber/$totalSelectedCategories: $categoryDescription"
 	local formattedText="<span font='$fontFamilyText $fontBigSize'>$checklistText</span>"

	# Set first row: ALL applications
	appRows+="false \"[$all]\" \"\" \"\" "
	# Set rest of rows. One per aplication
	appRows+=$( getApplicationOptions applicationArray[@] "$categoryName" )
	# Create zenity window (desktop mode)
	window="zenity --title=\"$installerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows --window-icon=\"$installerIconFolder/tux-shell-console32.png\""
 	echo "$window"
}


##
# This function shows a box / window to let the user selects
# applications to install from a category.
# @since 	v1.3
# @param 	String[] 	applicationArray 		list of applications
# @param 	String		categoryName 				name of category
# @param 	String		categoryDescription description of category
# @param 	int				categoryNumber 	    index of category order
# @param 	int				totalSelectedCat		number of selected categories
# @return String 												Selected app.list with '.' separator
##
function selectAppsToInstallByCategory
{
	local applicationArray=(${!1}) categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCat="$5"
	selection=`eval $( getApplicationsWindow applicationArray[@] "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCat")`
	# Check if exit category menu
	if [[ $? -ne 0 ]]; then
		echo "$CANCEL_CODE"
	else
		if [ ! -z "$selection" ]; then
			local selectionArray
			IFS='|' read -ra selectionArray <<< "$selection"
			if [ "${selectionArray[0]}" == "[$all]" ]; then
				local allApps="${applicationArray[@]}"
				echo "`echo ${allApps// /. } | tr '_' ' '`"
			else
				echo "${selection//|/. }"
			fi
		else
			echo ""
		fi
	fi
}


##
# This function filters applicaction list of a specific category.
# If uninstall process, then, filter thouse apps of a category that
# have been installed.
# @since 	v1.3
# @param String categoryName						Name of the category
# @param String uninstalled							If uninstall proccess
# @return String 												List of apps
##
function getApplicationList
{
	local categoryName="$1"

	# Delete blank and comment lines,then filter by category name and take application list (second column)
	local applicationList=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)

	if [ "$2" == "--only-show-installed-repo-apps" ]; then
		local installedAppList=""
		for application in "${applicationList[@]}"; do
			# Delete blank and comment lines,then filter by application name and take package list (third column)
			local packageList="`cat "$appListFile" | awk -v app=$application '!/^($|#)/{ if ($2 == app) print $3; }' | tr '|' ' '`"
			if [ -n "`dpkg -s $packageList 2>&1 | grep "Status: install ok installed"`" ]; then
				# The application is installed
				installedAppList+="$application "
			fi
		done
		echo "$installedAppList"
	else
		echo "${applicationList[@]}"
	fi
}


##
# This function calls other functions to show category box and all others
# application boxes to let the user selects applications to install.
# @since 	v1.3
# @return String 										Selected app.list with '.' separator
##
function menu
{
	# Array of selected Categories
	local firstTime="true" selcat selectedCategories

	credits
	# Repeat select categories and applications windows until not selected categories
	while [ "$selcat" != "" ] || [ "$firstTime" == "true" ]; do
		# Array of categories from appListFile of your distro. Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
		local categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | uniq | sort`)
		local categoryNumber=1

		selcat="$( selectCategoriesToBrowse categoryArray[@] $firstTime )"
		if [ "$selcat" == "$CANCEL_CODE" ]; then exit 0; fi
		if [ -z "$selcat" ]; then break; fi

		IFS='|' read -ra selectedCategories <<< "$selcat"
		if [ ${#selectedCategories[@]} -gt 0 ]; then
			local totalSelectedCat=${#selectedCategories[@]} categoryName

			for categoryName in "${selectedCategories[@]}"; do
				# Backup of selected applications of the category
				local oldSelectedApps=`echo ${selectedAppsMap[$categoryName]}`

				# Each category has it's own screen
				local categoryDescription
				eval categoryDescription=\$$categoryName"Description"

				local applicationArray=$( getApplicationList "$categoryName" "$1" )
				selectedAppsMap[$categoryName]=$( selectAppsToInstallByCategory applicationArray[@] "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCat" )

				if [ "${selectedAppsMap[$categoryName]}" == "$CANCEL_CODE" ]; then
					# Restore old selected applications of the category
					selectedAppsMap[$categoryName]=`echo $oldSelectedApps`
					break
				fi
				categoryNumber=$(($categoryNumber+1))
			done
		fi
		firstTime="false"
	done
	# Return selected applications
	if [ ${#selectedAppsMap[@]} -gt 0 ]; then
		local selectedAppsFormatted

		for categoryName in "${!selectedAppsMap[@]}"; do
			selectedAppsFormatted+="`echo ${selectedAppsMap[$categoryName]//. /|} | tr -d '.' | tr ' ' '_' | tr '|' ' '` "
		done
		echo "$selectedAppsFormatted"
	else
		echo ""
	fi
}
