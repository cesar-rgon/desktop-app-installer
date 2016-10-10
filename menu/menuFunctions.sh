#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
# @author 	César Rodríguez González
# @since 		1.3, 2016-07-31
# @version 	1.3, 2016-10-10
# @license 	MIT
##########################################################################


# IMPORT GLOBAL VARIABLES
. $scriptRootFolder/menu/menuVariables.properties
if [ -z "$DISPLAY" ]; then . $scriptRootFolder/menu/dialogFunctions.sh; else . $scriptRootFolder/menu/zenityFunctions.sh; fi


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
	selection=`eval "$( getApplicationsWindow applicationArray[@] "$categoryName" "$categoryDescription" "$categoryNumber" "$totalSelectedCat")"`
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

	# If uninstall applications, filter only thouse that are installed
	if [ "$2" == "--uninstall" ]; then
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

	# Repeat select categories and applications windows until not selected categories
	while [ "$selcat" != "" ] || [ "$firstTime" == "true" ]; do
		# Array of categories from appListFile of your distro. Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
		local categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | uniq | sort`) categoryNumber=1

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
		local seledtedAppsFormatted

		for categoryName in "${!selectedAppsMap[@]}"; do
			seledtedAppsFormatted+="`echo ${selectedAppsMap[$categoryName]//. /|} | tr -d '.' | tr ' ' '_' | tr '|' ' '` "
		done
		echo "$seledtedAppsFormatted"
	else
		echo ""
	fi
}
