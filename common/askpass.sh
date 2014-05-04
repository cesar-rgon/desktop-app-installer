#!/bin/bash
ISO639_1=${LANG:0:2}
LANGUAGE_FILE="../languages/"$ISO639_1".properties"

if [ -f "$LANGUAGE_FILE" ]; then
	. $LANGUAGE_FILE
else
	. ../languages/en.properties
fi

zenity --password --title "$adminPassword"

