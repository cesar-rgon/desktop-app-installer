#!/bin/bash
##########################################################################
# This script disables "http://security.debian.org/" repositories while
# installation proccess to avoid package dependecy problems on Debian 8
# and LMDE 2
# @author César Rodríguez González
# @since   1.3, 2016-10-10
# @version 1.3, 2016-10-10
# @license MIT
##########################################################################

# For Debian based O.S.
if [ "$distro" == "debian" ] || [ "$distro" == "lmde" ]; then
  url="http://security.debian.org"
  securityFileList=( `grep -r "$url" /etc/apt | awk -F : '{print $1}' | uniq` )
  sed -i "s/deb ${url//\//\\/}/#deb ${url//\//\\/}/g" ${securityFileList[@]} 2>/dev/null
  sed -i "s/deb-src ${url//\//\\/}/#deb-src ${url//\//\\/}/g" ${securityFileList[@]} 2>/dev/null
  sudo apt-get update
fi
