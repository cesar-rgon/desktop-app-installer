#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
# @author 	César Rodríguez González
# @since 		1.3, 2016-07-31
# @version 	1.3, 2016-10-11
# @license 	MIT
##########################################################################


# IMPORT GLOBAL VARIABLES
. $scriptRootFolder/menu/menuVariables.properties
if [ -z "$DISPLAY" ]; then
	. $scriptRootFolder/menu/dialogFunctions.sh
else
	if [ -n "`dpkg -s yad 2>&1 | grep "Status: install ok installed"`" ]; then
		. $scriptRootFolder/menu/yadFunctions.sh
	else
		. $scriptRootFolder/menu/zenityFunctions.sh
	fi
fi


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
