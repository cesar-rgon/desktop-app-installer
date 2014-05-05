#!/bin/bash
##########################################################################
# This script installs Teamviewer quick support application.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
# Licence: MIT
##########################################################################

# Get common variables and check if the script is being running by a root or sudoer user
. ../common/commonVariables.sh

# Download Teamviewer quick support
wget -O /tmp/teamviewer_qs.tar.gz http://download.teamviewer.com/download/teamviewer_qs.tar.gz 2>&1
# Install application
tar -C $homeFolder -xvf /tmp/teamviewer_qs.tar.gz
mv $homeFolder/teamviewer*qs $homeFolder/.teamviewerqs
chown -R $username:$username $homeFolder/.teamviewerqs

# Extract teamviewer icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/teamviewer.tar.gz"

# Create menu entry link
echo "[Desktop Entry]" > /usr/share/applications/teamviewer-quick-support.desktop
echo "Version=1.0" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Encoding=UTF-8" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Name=TeamViewer 9 Quick Support" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Comment=TeamViewer Quick Support for incoming conections" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Exec=$homeFolder/.teamviewerqs/tv_bin/script/teamviewer" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Icon=teamviewer" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Type=Application" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "Categories=Network;" >> /usr/share/applications/teamviewer-quick-support.desktop
echo "#Categories=Network;RemoteAccess;" >> /usr/share/applications/teamviewer-quick-support.desktop

