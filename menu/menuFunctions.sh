#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 02/08/2016
# Licence: MIT
##########################################################################


##########################################################################
# This function shows a box / window to let the user selects
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
	declare -ag applicationArray=("${!1}")
	local categoryName="$2" categoryDescription="$3" categoryNumber="$4" totalSelectedCategories="$5"

	selection=`eval "$( getApplicationsWindow applicationArray[@] "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCategories")"`
	# Check if exit category menu
	if [[ $? -ne 0 ]]; then
		echo "$CANCEL_CODE"
	else
		if [ ! -z "$selection" ]; then
			declare -ag selectionArray
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
	if [ -z $DISPLAY ]; then
		. $scriptRootFolder/menu/dialogFunctions.sh
	else
		. $scriptRootFolder/menu/zenityFunctions.sh
	fi

	# Array of selected Categories
	declare -ag selectedCategories
	local firstTime="true" selcat

	# Repeat select categories and applications windows until not selected categories
	while [ "$selcat" != "" ] || [ "$firstTime" == "true" ]; do
		local categoryNumber=1
		selcat="$( selectCategoriesToBrowse $firstTime )"
		if [ "$selcat" == "$CANCEL_CODE" ]; then exit 0; fi
		if [ -z "$selcat" ]; then break; fi

		IFS='|' read -ra selectedCategories <<< "$selcat"
		if [ ${#selectedCategories[@]} -gt 0 ]; then
			local totalSelectedCategories=${#selectedCategories[@]} categoryName

			for categoryName in "${selectedCategories[@]}"; do
				# Backup of selected applications of the category
				local oldSelectedApps=`echo ${selectedAppsMap[$categoryName]}`

				# Each category has it's own screen
				local categoryDescription
				eval categoryDescription=\$$categoryName"Description"

				# Delete blank and comment lines,then filter by category name and take application list (second column)
				declare -ag applicationArray=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)
				selectedAppsMap[$categoryName]=$( selectAppsToInstallByCategory applicationArray[@] "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCategories" )

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
		local seledtedAppsFormatted

		for categoryName in "${!selectedAppsMap[@]}"; do
			seledtedAppsFormatted+="`echo ${selectedAppsMap[$categoryName]//. /|} | tr -d '.' | tr ' ' '_' | tr '|' ' '` "
		done
		echo "$seledtedAppsFormatted"
	else
		echo ""
	fi
}
