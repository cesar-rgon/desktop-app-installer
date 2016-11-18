#!/bin/bash
##########################################################################
# This script opens a Zenity window to ask admin password
# @author 	César Rodríguez González
# @since 		1.3, 2016-08-05
# @version 	1.3, 2016-11-18
# @license 	MIT
##########################################################################

if [ -z "`dpkg -s yad 2>&1 | grep "Status: install ok installed"`" ]; then
  zenity --password --title "sudo"
else
  yad --title="sudo" --image="icons/installer/unlock.png" --entry --hide-text
fi
