#!/bin/bash
##########################################################################
# This script contains menu functions used only by main script.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 31/05/2014
# Licence: MIT
##########################################################################

function menuAttributes
{
	if [ -z $DISPLAY ]; then
		width=$((`tput cols` - 4))
		maxHeight=$((`tput lines` - 5))
	else
		width=900
		baseHeight=180
		rowHeight=28
		maxHeight=$((`xdpyinfo | grep dimensions | awk '{print $2}' | awk -F "x" '{print $2}'` - 100))
		fontFamilyText="Sans"
		fontSizeText="16"
	fi
}


function getHeight
{
	declare -i rowsNumber=$1

	if [ -z $DISPLAY ]; then
		height=$(($rowsNumber+8))
	else
		if [ $rowsNumber -gt 2 ]; then
			height=$(($baseHeight+$(($(($rowsNumber-2))*$rowHeight))))
		else
			height=$baseHeight
		fi
	fi
	if [ $height -gt $maxHeight ]; then
		height=$maxHeight
	fi
}


function selectCategoriesToBrowse
{
	declare rows selection

	if [ -z $DISPLAY ]; then
		declare -i totalCategoriesNumber=${#categoryArray[@]}
		# Order by category descriptions
		rows=`echo $(for categoryName in "${!mapCategoryRows[@]}"; do echo ${mapCategoryRows[$categoryName]}; done | sort -k1)`
		selection=`eval "dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$selectCatogories\" $height $width $totalCategoriesNumber $rows"`
	else
		declare formattedText="<span font='$fontFamilyText $fontSizeText'>$selectCatogories</span>"
		# Order by category descriptions
		rows=`echo $(for categoryName in "${!mapCategoryRows[@]}"; do echo ${mapCategoryRows[$categoryName]}; done | sort -k3)`
		selection=`eval "zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$categoryLabel\" --column \"$categoryLabel\" --column \"$selecteAppsLabel\" $rows --hide-column=2 --window-icon=\"$installerIconFolder/tux32.png\""`
	fi
	if [[ $? -ne 0 ]]; then
		exit 0    # Exit the script
	fi
	if [ "$selection" != "" ]; then
		if [ -z $DISPLAY ]; then
			declare -a selectedCategoryDescriptions=(`echo "$selection" | tr '|' ' '`)
			declare -i index=0
			selectedCategories=()
			# Get category name from category description
			for categoryDescription in "${selectedCategoryDescriptions[@]}"; do
				selectedCategories[$index]=${mapCategory[$categoryDescription]}
				index=$(($index+1))
			done
		else
			selectedCategories=(`echo "$selection" | tr '|' ' '`)
		fi
	else
		selectedCategories=()
	fi
}


function selectAppsToInstallByCategory
{
	declare categoryName="$1" appRows="${2}" checklistText="${3}" selection

	if [ -z $DISPLAY ]; then
		declare -i appsNumber=$4
		declare backtitle="$linuxAppInstallerTitle. $linuxAppInstallerComment. $linuxAppInstallerAuthor"
		selection=`eval "dialog --title \"$mainMenuLabel\" --backtitle \"$backtitle\" --stdout --separate-output --output-separator \"|\" --checklist \"$checklistText\" $height $width $appsNumber $appRows"`
	else
		declare formattedText="<span font='$fontFamilyText $fontSizeText'>$checklistText</span>"
		selection=`eval "zenity --title=\"$linuxAppInstallerTitle\" --text \"$formattedText\" --list --checklist --width=$width --height=$height --column \"\" --column \"$nameLabel\" --column \"$descriptionLabel\" --column \"$observationLabel\" $appRows --window-icon=\"$installerIconFolder/tux32.png\""`
	fi
	if [[ $? -eq 0 ]]; then
		if [ "$selection" != "" ]; then
			mapSelectedApps[$categoryName]="${selection//|/. }"
		else
			mapSelectedApps[$categoryName]=""
		fi
	else
		break 	# Exit to category menu
	fi
}

function menu
{
	declare -A mapCategory		# Associatie map wich gets category name from category description
	declare -A mapSelectedApps	# Associate map wich gets selected applications from a category name
	declare -A mapCategoryRows	# Associate map wich gets category rows used by dialog and zenity
	declare -a categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | awk '!x[$0]++'`)  # Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
  	declare -a selectedCategories appNameArray selectedApps sortedCategoryDescriptions
	declare -i totalCategoriesNumber=${#categoryArray[@]} categoryNumber=1 appsNumber=0 totalSelectedCategories index
	declare categoryName appName appDescription appRows checklistText appNameForMenu selectedApp enabled exitWhile="false"

	menuAttributes
	# Set category rows for Dialog/Zenity window
	for categoryName in "${categoryArray[@]}"; do
		eval categoryDescription=\$$categoryName"Description"
		if [ -z $DISPLAY ]; then
			mapCategoryRows[$categoryName]="\"$categoryDescription\" \"\" off"
			mapCategory[$categoryDescription]=$categoryName
		else
			mapCategoryRows[$categoryName]="false \"$categoryName\" \"$categoryDescription\" \"\" "		
		fi
	done

	while [ "$exitWhile" == "false" ] ; do
		getHeight $totalCategoriesNumber
		categoryNumber=1
		selectCategoriesToBrowse
		if [ "`echo ${selectedCategories[@]}`" == "" ]; then
			exitWhile="true"
			break
		fi

		totalSelectedCategories=${#selectedCategories[@]}
		for categoryName in "${selectedCategories[@]}"; do
			# Each category has it's own screen
			eval categoryDescription=\$$categoryName"Description"
			# Delete blank and comment lines,then filter by category name and take application list (second column)
			appNameArray=(`cat "$appListFile" | awk -v category=$categoryName '!/^($|#)/{ if ($1 == category) print $2; }'`)
			appsNumber=${#appNameArray[@]}
			appRows=""
			checklistText="$categoryLabel $categoryNumber/$totalSelectedCategories: $categoryDescription"
			getHeight $appsNumber

			index=0			
			for appName in "${appNameArray[@]}"; do
				appNameForMenu="`echo $appName | tr '_' ' '`"
				# Indirect variable reference. Take value from variable <appName>Description
				eval appDescription=\$$appName"Description"
				eval appObservation=\$$appName"Observation"
				IFS='.' read -a selectedApps <<< `echo ${mapSelectedApps[$categoryName]}`
				selectedApp="`echo ${selectedApps[$index]}`"

				if [ -z $DISPLAY ]; then
					enabled=`[ "$appNameForMenu" == "$selectedApp" ] && echo on || echo off`
					appRows+="\"$appNameForMenu\" \"$appDescription. $appObservation\" $enabled "
				else
					enabled=`[ "$appNameForMenu" == "$selectedApp" ] && echo true || echo false`
					appRows+="$enabled \"$appNameForMenu\" \"$appDescription\" \"$appObservation\" "		
				fi
				if [ "$enabled" == "true" ] || [ "$enabled" == "on" ]; then
					index=$(($index+1))					
				fi
			done
			selectAppsToInstallByCategory "$categoryName" "$appRows" "$checklistText" $appsNumber
			categoryNumber=$(($categoryNumber+1))
			# Set selected apps in category row of main menu
			eval categoryDescription=\$$categoryName"Description"
			if [ -z $DISPLAY ]; then
				mapCategoryRows[$categoryName]="\"$categoryDescription\" \"`echo ${mapSelectedApps[$categoryName]}`\" off"
			else
				mapCategoryRows[$categoryName]="false \"$categoryName\" \"$categoryDescription\" \"`echo ${mapSelectedApps[$categoryName]}`\" "		
			fi
		done
	done
	if [ "`echo ${mapSelectedApps[@]}`" != "" ]; then
		declare seledtedApps appsFormatted
		for categoryName in "${!mapSelectedApps[@]}"; do
			appsFormatted=`echo ${mapSelectedApps[$categoryName]}`
			seledtedApps+="`echo ${appsFormatted//. /|} | tr -d '.' | tr ' ' '_' | tr '|' ' '` "
			dialog --title "$mainMenuLabel" --backtitle "$backtitle" --stdout --msgbox "$seledtedApps" $height $width
		done
		echo "$seledtedApps"
	else
		echo ""	
	fi
}

