#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Desktop Mode. The application to manage windows is Yad.
# @author 	César Rodríguez González
# @since 		1.3, 2016-11-14
# @version 	1.3, 2016-11-19
# @license 	MIT
##########################################################################

###
# This function get the height of a Yad window
# @since 	v1.3.2
# @param 	int 	rowsNumber 	Number of rows (categories or applications)
# @return int 							Height for current Yad window
##
function getHeight
{
	local rowsNumber=$1
	local baseHeight=352
	height=$(($baseHeight+$(($(($rowsNumber))*$rowHeight))))
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
	echo $height
}

##
# This function returns the selected application list of a specific category
# @param String 	categoryName	Name of the categoryName
# @since 1.3.2
# @return String 								List of selected applications of the category
##
function getSelectedAppsFromCategory
{
	categoryName="$1"

	if [ -f "$tempFolder/yad$categoryName" ]; then
		local selection=`cat "$tempFolder/yad$categoryName" | awk -F '|' '{print $2}' | tr '\n' '|'`
		if [ -n "$selection" ]; then
			IFS='|' read -ra selectionArray <<< "$selection"
			local selectedApps
			if [ "${selectionArray[0]}" == "[$all]" ]; then
				echo "$( getApplicationList "$categoryName" )"
			else
				echo "`echo "${selection// /_}" | tr '|' ' '`"
			fi
		else
			echo ""
		fi
  else
		echo ""
	fi
}


##
# This function gets option parameters of each row of Yad window.
# One row per application of a specified category
# @since 	v1.3.2
# @param 	String[]	applicationArray 	List of category applications
# @param 	String		categoryName 			Name of the actual category
# @return String 											Parameters of application selectable in box
##
function getApplicationOptions
{
	local applicationArray=(${!1}) categoryName="$2"
	local selectedApps=$( getSelectedAppsFromCategory $categoryName )
	local appName appDescription appObservation options="" appNameForMenu enabled

	for appName in "${applicationArray[@]}"; do
		# application name without '_' character as showed in window
		appNameForMenu="`echo $appName | tr '_' ' '`"
		eval appDescription=\$$appName"Description"
		eval appObservation=\$$appName"Observation"

		local isSelected="`echo $selectedApps | grep -w "$appName"`"
		if [ -z "$isSelected" ]; then enabled="FALSE"; else enabled="TRUE"; fi
		options+="$enabled \"$appNameForMenu\" \"<i>$appDescription</i>\" \"<i>$appObservation</i>\" "
	done
	echo "$options"
}

##
# This function gets a application list window of a specified category
# First row: all applications. Rest of rows: one per application.
# @since 	v1.3.2
# @param 	String[]	applicationArray 		list of applications
# @param 	String		categoryName 				name of category
# @param 	int				key		  						random number used to match tabs in window
# @param 	int				categoryNumber 	    index of category order
# @return String 												commands to create app. window
##
function getApplicationsWindow
{
	local applicationArray=(${!1}) categoryName="$2" key=$3 categoryNumber=$4
 	local formattedText="<span font='$fontFamilyText $fontSmallSize'>$selectAppsToInstallCurrentCategory</span>"
	# Set first row: ALL applications
	local appRows="false \"[$all]\" \"\" \"\" "
	# Set rest of rows. One per aplication
	appRows+=$( getApplicationOptions applicationArray[@] "$categoryName" )
	# Create yad window (desktop mode)
	window="yad --plug=$key --tabnum=$categoryNumber --text \"$formattedText\" --list --checklist --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows"
 	echo "$window"
}


##
# This function filters applicaction list of a specific category.
# If uninstall process, then, filter thouse apps of a category that
# have been installed.
# @since 	v1.3.2
# @param String categoryName						Name of the category
# @param String uninstalled							If uninstall proccess
# @return String 												List of apps
##
function getApplicationList
{
	local categoryName="$1"

	# Delete blank and comment lines,then filter by category name and take application list (second column)
	local applicationList=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)

	if [ "$uninstaller" == "true" ]; then
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
# This functions creates a summary window of selected applications to be installed
# @param	String[] categoryArray	List of categories
# @since 1.3.2
# @return String   		Summary window
##
function getSummaryWindow
{
	local categoryArray=(${!1})
	local totalCategoriesNumber=$((${#categoryArray[@]}+1))
	local rows height=$( getHeight $totalCategoriesNumber)
	local formattedText+="<span font='$fontFamilyText $fontBigSize'>$appsToBeInstalled</span>"

	local categoryName selectionArray selectedApplications
	for categoryName in "${categoryArray[@]}"; do
		if [ -f "$tempFolder/yad$categoryName" ]; then
			local selection=`cat "$tempFolder/yad$categoryName" | awk -F '|' '{print $2}' | tr '\n' '|'`
			if [ -n "$selection" ]; then
			 	IFS='|' read -ra selectionArray <<< "$selection"
				local selectedAppsFromCategory=$( getSelectedAppsFromCategory $categoryName )

				eval categoryDescription=\$$categoryName"Description"
				local appNameForMenu appDescription appObservation
				for appName in $selectedAppsFromCategory; do
					appNameForMenu="`echo $appName | tr '_' ' '`"
					eval appDescription=\$$appName"Description"
					eval appObservation=\$$appName"Observation"
					rows+="\"$categoryDescription\" \"$appNameForMenu\" \"$appDescription\" \"$appObservation\" "
				done
				selectedApplications+="$selectedAppsFromCategory "
			fi
 	 	fi
	done
	echo "$selectedApplications" > $tempFolder/selectedAppsFile
	local customIcon
	if [ "$uninstaller" == "true" ]; then customIcon="trash32.png"; else	customIcon="installing32.png"; fi
	echo "yad --title=\"$installerTitle\" --text \"$formattedText\" --list --width=$width --height=500 --column \"$categoryLabel\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $rows --window-icon=\"$installerIconFolder/tux-shell-console32.png\" --button=\"!/$installerIconFolder/back32.png:1\" --button=\"!/$installerIconFolder/$customIcon:0\" --image=\"$installerIconFolder/summary96.png\" --image-on-top --center"
}


##
# This function calls other functions to show category box and all others
# application boxes to let the user selects applications to install.
# @since 	v1.3.2
# @return String 										Selected app.list with '.' separator
##
function menu
{
	# Array of categories from appListFile of your distro. Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
	local categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | uniq | sort`)
	local formattedText="<span font='$fontFamilyText $fontBigSize'>$installerTitle</span>"
	formattedText+="\n\n<span font='$fontFamilyText $fontSmallSize'>$scriptDescription</span>"

	local salida="false"
	while [ "$salida" == "false" ]; do
		pkill yad*
		local categoryNumber=1 key=$RANDOM maxApplicationNumber=0 categoryDescription applicationArray totalApplicationNumber
		local window="yad --notebook --key=$key --title=\"$installerTitle\" --text=\"$formattedText\""
		window+=" --image=\"$installerIconFolder/yad-tux-shell-console96.png\" --image-on-top"
		window+=" --button=\"!/$installerIconFolder/www32.png:3\" --button=\"!/$installerIconFolder/octocat32.png:2\" --button=\"!/$installerIconFolder/door32.png:1\" --button=\"!/$installerIconFolder/next32.png:0\""
		window+=" --window-icon=\"$installerIconFolder/tux-shell-console32.png\""

		for categoryName in "${categoryArray[@]}"; do
			eval categoryDescription=\$$categoryName"Description"
			# Applications for the category
			applicationArray=( $( getApplicationList "$categoryName" ) )
			totalApplicationNumber=$((${#applicationArray[@]}+1))
			if [ $totalApplicationNumber -gt $maxApplicationNumber ]; then
					maxApplicationNumber=$totalApplicationNumber
			fi
			eval $( getApplicationsWindow applicationArray[@] "$categoryName" $key $categoryNumber ) > "$tempFolder/yad$categoryName" &
			window+=" --tab=\"<span font='$fontFamilyText $fontSmallSize'><b>$categoryDescription</b></span>\" --tab-pos=left"
			categoryNumber=$(($categoryNumber+1))
		done
		local height=$( getHeight $maxApplicationNumber )
		window+=" --width=$width --height=$height --center"

		eval "$window"
		local resultCode=$?
		pkill yad*
		case $resultCode in
				0) local summaryWindow=$( getSummaryWindow categoryArray[@] )
					 eval "$summaryWindow"
					 case $? in
						 0) salida="true" ;;
						 1) salida="false" ;;
						 *) salida="true"; rm -f "$tempFolder/selectedAppsFile" ;;
					 esac ;;
				1) salida="true"; rm -f "$tempFolder/selectedAppsFile" ;;
				2) xdg-open 'https://github.com/cesar-rgon/desktop-app-installer'; salida="true"; rm -f "$tempFolder/selectedAppsFile" ;;
				3) xdg-open 'https://cesar-rgon.github.io/desktop-app-installer-website'; salida="true"; rm -f "$tempFolder/selectedAppsFile" ;;
				*) salida="true"; echo "" ;;
		esac
	done
}
