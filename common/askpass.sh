#!/bin/bash
##########################################################################
# This script opens a Zenity window to ask admin password
# @author 	César Rodríguez González
# @since 		1.3, 2016-08-05
# @version 	1.3, 2016-11-20
# @license 	MIT
##########################################################################

if [ -z "`dpkg -s yad 2>&1 | grep "Status: install ok installed"`" ]; then
  zenity --password --title "sudo"
else
  iconsFolder="."
  if [ -d "icons/installer" ]; then iconsFolder="icons/installer"; else if [ -d "../icons/installer" ]; then iconsFolder="../icons/installer"; fi
  fi
  yad --title="sudo" --image="$iconsFolder/unlock.png" --entry --hide-text --button="!$iconsFolder/next32.png:0" --center
fi
