#!/bin/bash
if [[ "$LANG" == "es"* ]]; then		# System language is spanish or latin so apply spanish language to this script.
	zenity --password --title "Contraseña administrador"
else					# System language is not spanish nor latin so apply english language to this script.
	zenity --password --title "Administrator password"
fi
