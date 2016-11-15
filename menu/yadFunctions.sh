#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script on
# Desktop Mode. The application to manage windows is Yad.
# @author 	César Rodríguez González
# @since 		1.3, 2016-11-14
# @version 	1.3, 2016-11-14
# @license 	MIT
##########################################################################

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
# This function gets option parameters of each row of Yad window.
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
# @since 	v1.3.2
# @param 	String[]	applicationArray 		list of applications
# @param 	String		categoryName 				name of category
# @param 	String		categoryDescription description of category
# @param 	int				categoryNumber 	    index of category order
# @param 	int				totalCategories		  number of categories
# @param 	int				key		  						random number used to match tabs in window
# @return String 												commands to create app. window
##
function getApplicationsWindow
{
	local applicationArray=(${!1}) categoryName="$2" key=$3 categoryNumber=$4
	local totalApplicationNumber=$((${#applicationArray[@]}+1))
	local height=$( getHeight $totalApplicationNumber )
	local checklistText="Seleccione las aplicaciones a instalar en esta categoria"
 	local formattedText="<span font='$fontFamilyText $fontSmallSize'>$checklistText</span>"
	# Set first row: ALL applications
	local appRows="false \"[$all]\" \"\" \"\" "
	# Set rest of rows. One per aplication
	appRows+=$( getApplicationOptions applicationArray[@] "$categoryName" )
	# Create yad window (desktop mode)
	window="yad --plug=$key --tabnum=$categoryNumber --text \"$formattedText\" --list --checklist --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows"
 	echo "$window"
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
	local categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | uniq | sort`) categoryNumber=1
	local categoryNumber=1 key=$RANDOM

	local formattedText="<span font='$fontFamilyText $fontBigSize'>Linux App Installer v1.3.2</span>"
	formattedText+="\n<span font='$fontFamilyText $fontSmallSize'>Script instalador y configurador de aplicaciones y escritorios</span>"

	local window="yad --notebook --key=$key --title=\"Linux App Installer v1.3.2\" --text=\"$formattedText\""
	window+=" --image=\"$installerIconFolder/tux-shell-console96.png\" --image-on-top"
	window+=" --button=\"!/$installerIconFolder/www32.png:3\" --button=\"!/$installerIconFolder/octocat32.png:2\" --button=\"!/$installerIconFolder/door32.png:1\" --button=\"!/$installerIconFolder/next32.png:0\""
	window+=" --width=600 --height=200"
	window+=" --window-icon=\"$installerIconFolder/tux-shell-console32.png\""

	for categoryName in "${categoryArray[@]}"; do
		local categoryDescription
		eval categoryDescription=\$$categoryName"Description"

		# Applications for the category
		local applicationArray=$( getApplicationList "$categoryName" "$1" )
		`eval $( getApplicationsWindow applicationArray[@] "$categoryName" $key $categoryNumber )` &

		#selectedAppsMap[$categoryName]=$( selectAppsToInstallByCategory applicationArray[@] "$categoryName" "$categoryDescription" "$categoryNumber" "${#categoryArray[@]}" )
		window+=" --tab=\"$categoryDescription\""
		categoryNumber=$(($categoryNumber+1))
	done
	eval "$window"
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
