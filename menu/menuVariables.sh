##########################################################################
# This script contains global variables used by main script menu.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 31/07/2016
# Licence: MIT
##########################################################################

# Array of categories from appListFile of your distro. Delete blank and comment lines. Take category list (first column) and remove duplicated rows in appListFile content.
declare -a categoryArray=(`cat "$appListFile" | awk '!/^($|#)/{ print $1; }' | uniq | sort`)
# Associate map wich gets selected applications from a category name
declare -A selectedAppsMap

if [ -z $DISPLAY ]; then
	# Associatie map wich gets category name from category description
	declare -A mapCategory
	# width of Dialog box
	width=$((`tput cols` - 4))
	# maximun height allowed for Dialog box
	maxHeight=$((`tput lines` - 5))
else 	
	# minimun height allowed for Zenity boxes
	baseHeight=180
	# rowHeight: height by element of the list for Zenity boxes
	rowHeight=28
	# Font family used in main text for Zenity boxes
	fontFamilyText="Sans"
	# Font size used in text for Zenity's category box
	fontSizeCategory="12"
	# Font size used in text for Zenity's apps boxes	
	fontSizeApps="16"
	# width of Zenity windows
	width=900
	# maximun height allowed for Zenity windows
	maxHeight=$((`xdpyinfo | grep dimensions | awk '{print $2}' | awk -F "x" '{print $2}'` - 100))
fi
