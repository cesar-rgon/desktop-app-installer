#!/bin/bash
##########################################################################
# This script installs Sublime text application.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 14/06/2014
# Licence: MIT
##########################################################################
# Get common variables and check if the script is being running by a root or sudoer user
if [ "$1" != "" ]; then
	scriptRootFolder="$1"
else
	scriptRootFolder=".."
fi
. $scriptRootFolder/common/commonVariables.sh

# Get Tor browser last version from website
wget -O $tempFolder/tor_index.html https://www.torproject.org/download/download-easy.html.en 2>&1
declare version
if [ `uname -m` == "x86_64" ]; then
	version=`cat $tempFolder/tor_index.html | grep "Version.*Linux" | tail -1 | awk {'print $2'}`
else
	version=`cat $tempFolder/tor_index.html | grep "Version.*Linux" | head -1 | awk {'print $2'}`
fi
# Get region
declare ISO639_1=${LANG:0:2}
declare region
case "$ISO639_1" in
"ar")
	region="ar";;
"de")
	region="de";;
"es")
	region="es-ES";;
"fa")
	region="fa";;
"fr")
	region="fr";;
"it")
	region="it";;
"ko")
	region="ko";;
"nl")
	region="nl";;
"pl")
	region="pl";;
"pt")
	region="pt-PT";;
"ru")
	region="ru";;
"tr")
	region="tr";;
"vi")
	region="vi";;
"zh")
	region="zh-CN";;
*)
	region="en-US";;
esac
# Get URL
if [ `uname -m` == "x86_64" ]; then
	torBrowserFile="tor-browser-linux64-$version_$region.tar.xz"
else
	torBrowserFile="tor-browser-linux32-$version_$region.tar.xz"
fi
torBrowserURL="https://www.torproject.org/dist/torbrowser/$version/$torBrowserFile"
# Download Tor browser
wget -O $tempFolder/$torBrowserFile $torBrowserURL 2>&1

# Install application
tar -C $tempFolder -xvf $tempFolder/$torBrowserFile
bash $tempFolder/tor-browser_$region/start-tor-browser

