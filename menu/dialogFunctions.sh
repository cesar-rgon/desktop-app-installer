#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Terminal Mode. The application to manage windows is Dialog.
# @author 	César Rodríguez González
# @since 	1.3, 2016-08-01
# @version 	1.3.3, 2017-03-25
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
	local whiteSpaces="                  "
	printf "\n%.21s%s\n" "$scriptNameLabel:$whiteSpaces" "$installerTitle" > $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$scriptDescriptionLabel:$whiteSpaces" "$scriptDescription" >> $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$testedOnLabel:$whiteSpaces" "$testedOnDistros" >> $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$githubProjectLabel:$whiteSpaces" "$githubProjectUrl" >> $tempFolder/linux-app-installer.credits
	printf "%.21s%s\n" "$authorLabel:$whiteSpaces" "$author" >> $tempFolder/linux-app-installer.credits
	dialog --title "$creditsLabel" --backtitle "$installerTitle" --stdout --textbox $tempFolder/linux-app-installer.credits 11 100
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
	window="dialog --title \"$mainMenuLabel\" --backtitle \"$installerTitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$text\" $height $(($width - 4)) $totalCategoriesNumber $rows"
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
		if [ -n "$selection" ]; then
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
 	window="dialog --title \"$mainMenuLabel\" --backtitle \"$installerTitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $(($width - 4)) $totalApplicationNumber $appRows"
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
		if [ -n "$selection" ]; then
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
	local applicationList=(`cat "$appListFile" | awk -F ',' -v category=$categoryName '!/^($|#|,)/{ if ($1 == category) print $2; }'`)

	if [ "$uninstaller" == "true" ]; then
		local installedAppList=""
		for application in "${applicationList[@]}"; do
			# Delete blank and comment lines,then filter by application name and take package list (third column)
			local packageList="`cat "$appListFile" | awk -F ',' -v app=$application '!/^($|#|,)/{ if ($2 == app) print $3; }' | tr '|' ' '`"
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
# This function creates a window to allow change username/password of
# thouse applications which need credentials to authenticate
# @since 	v1.3.3
# @return String credential window
##
function getCredentialsWindow
{
	# Set first row: Continue installation
 	local appRows="\"[$continue]\" \"$proceedToInstall\" on "
	# Array of applications which requires authentication
	local credentialArray=(`ls $credentialFolder/`) credentialFile totalApplicationNumber=1
	for credentialFile in "${credentialArray[@]}"; do
		if [[ $credentialFile != template* ]] && [ -f $credentialFolder/$credentialFile ]; then
			local appName="${credentialFile%.*}"
			local appNameForMenu="`echo $appName | tr '_' ' '`"
			. $credentialFolder/$appName.properties
			appRows+="\"$appNameForMenu\" \"$usernameLabel: $appUsername / $passwordLabel: $appPassword\" off "
			totalApplicationNumber=$(($totalApplicationNumber+1))
		fi
	done
	local height=$( getHeight $totalApplicationNumber)
	window="dialog --title \"$credentialsTitle\" --backtitle \"$installerTitle\" --stdout --no-cancel --radiolist \"$credentialSelection\" $height $(($width - 4)) $totalApplicationNumber $appRows"
	echo "$window"
}

##
# This function allows to select an application which requires
# credential authentication for editing username/password
# @since 	v1.3.3
##
function selectCredentialApplication
{
	local selection=""
	while [ "$selection" != "[$continue]" ] ; do
		selection=`eval $( getCredentialsWindow )`
		if [ "$selection" != "[$continue]" ]; then
			local appName="`echo $selection | tr ' ' '_'`" usernameLong passwordLong
			. $credentialFolder/$appName.properties
			if [ "$usernameCanBeEdited" == "true" ]; then usernameLong=25; else usernameLong=0; fi
			if [ "$passwordCanBeEdited" == "true" ]; then passwordLong=25; else passwordLong=0; fi

			newCredentials=`dialog --title "$appCredentials $selection" --backtitle "$installerTitle" --stdout --output-separator "|" \
			--form "$credentialWarning" 13 $(($width - 4)) 5 \
			"$usernameLabel" 2 $(($(($width/2))-25)) "$appUsername" 2 $(($width/2)) $usernameLong 25 \
			"$passwordLabel" 4 $(($(($width/2))-25)) "$appPassword" 4 $(($width/2)) $passwordLong 25`

			if [[ $? -eq 0 ]] && [ -n "$newCredentials" ]; then
				local credentialsArray newUsername="" newPassword="" index=0
				IFS='|' read -ra credentialsArray <<< "$newCredentials"
				if [ "$usernameCanBeEdited" == "true" ]; then
					newUsername=${credentialsArray[$index]}
					index=$(($index+1))
				else
					newUsername=$appUsername
				fi
				if [ "$passwordCanBeEdited" == "true" ]; then
					newPassword=${credentialsArray[$index]}
				else
					newPassword=$appPassword
				fi
				# Save credentials to file
				sed -i "s/^appUsername=.*/appUsername=$newUsername/g" $credentialFolder/$appName.properties
				sed -i "s/^appPassword=.*/appPassword=$newPassword/g" $credentialFolder/$appName.properties
			fi
		fi
	done
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
	while [ -n "$selcat" ] || [ "$firstTime" == "true" ]; do
		# Array of categories from appListFile of your distro. Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
		local categoryArray=(`cat "$appListFile" | awk -F ',' '!/^($|#|,)/{ print $1; }' | uniq | sort`)
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

				local applicationArray=$( getApplicationList "$categoryName" )
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
		echo "$seledtedAppsFormatted" > "$tempFolder/selectedAppsFile"
		selectCredentialApplication
	else
		rm -f "$tempFolder/selectedAppsFile"
	fi
}
