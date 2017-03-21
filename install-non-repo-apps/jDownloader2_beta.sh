#!/bin/bash
##########################################################################
# This script installs jDowloader 2 beta application.
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
if [ `uname -m` == "x86_64" ]; then
	jDownloader2File="JD2SilentSetup_x64.sh"
else
	jDownloader2File="JD2SilentSetup_x86.sh"
fi
jDownloader2URL="/tmp/jdownloader2.sh http://installer.jdownloader.org/$jDownloader2File"
wget -O /tmp/$jDownloader2File $jDownloader2URL 2>&1
bash /tmp/$jDownloader2File
chown $username:$username -R /opt/jd2
