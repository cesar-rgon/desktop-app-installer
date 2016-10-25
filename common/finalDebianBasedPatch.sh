#!/bin/bash
##########################################################################
# This script enables again "http://security.debian.org/" repositories
# at the end of the installation proccess only on Debian 8 or LMDE 2
# @author César Rodríguez González
# @since   1.3, 2016-10-10
# @version 1.3, 2016-10-10
# @license MIT
##########################################################################

# Debian based O.S. patch. Enable "http://security.debian.org/" repositories again.
if [ "$distro" == "debian" ] || [ "$distro" == "lmde" ]; then
	url="http://security.debian.org"
	securityFileList=( `grep -r "$url" /etc/apt | awk -F : '{print $1}' | uniq` )
	sed -i "s/#deb ${url//\//\\/}/deb ${url//\//\\/}/g" ${securityFileList[@]} 2>/dev/null
	sed -i "s/#deb-src ${url//\//\\/}/deb-src ${url//\//\\/}/g" ${securityFileList[@]} 2>/dev/null
	sudo apt update
fi
