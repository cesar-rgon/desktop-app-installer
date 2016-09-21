#!/bin/bash
##########################################################################
# This script installs Teamviewer quick support application.
# @author César Rodríguez González
# @version 1.3, 2016-08-09
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties

# Commands to download, extract and install a non-repository application.
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
