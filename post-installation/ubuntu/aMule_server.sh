#!/bin/bash
##########################################################################
# This script configures aMule daemon to be ready to use.
# This one was compatible for both linux OS: Ubuntu and Debian.
# Debian 8 has removed amule package from stable repository.
# In a future version, if aMule come back to stable repository, this
# script will back to parent directory, it means, available for both
# linux OS.
# @author César Rodríguez González
# @version 1.3, 2016-08-16
# @license MIT
##########################################################################

# Check if the script is being running by a root or sudoer user
if [ "$(id -u)" != "0" ]; then echo ""; echo "This script must be executed by a root or sudoer user"; echo ""; exit 1; fi

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/../.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties
# Add credentials for authentication
. $scriptRootFolder/credentials/aMule_server.properties

### VARIABLES ############################################################
AMULE_DAEMON_DOWNLOAD_FOLDER="$homeDownloadFolder/aMule"
AMULE_DAEMON_TEMP_FOLDER="$homeFolder/.Temporal/aMule"
AMULE_DAEMON_CLIENT_PORT="4712"
AMULE_DAEMON_WEB_PORT="4711"
AMULE_DAEMON_TCP_PORT="4662"
AMULE_DAEMON_UDP_PORT="4672"
AMULE_DAEMON_FILE="/etc/systemd/system/amuled.service"
categories=( eMule Browser Proxy ExternalConnect WebServer GUI Razor_Preferences SkinGUIOptions Statistics Obfuscation PowerManagement UserEvents HTTPDownload )
declare -A categoriesMap

### FUNCTIONS ############################################################
# This function sets a category parameter in amule.conf file
function setCategoryParameter
{
	local category="$1" parameter="$2" value=$3
	echo "`echo ${categoriesMap[$category]} | tr '|' '\n' | sed \"s/^$parameter=.*/$parameter=$value/g\" | tr '\n' '|'`"
}

### CREATE FOLDERS #######################################################
sudo -u $username mkdir -p $AMULE_DAEMON_DOWNLOAD_FOLDER $AMULE_DAEMON_TEMP_FOLDER

### SETUP APPLICATION CONFIG FILES #######################################
# Try to start amule-daemon. The application can not start yet and will automatically create home folder and default config files
sudo -u $username amuled -f 1>/dev/null
# Backup of default main config file
sudo -u $username cp $homeFolder/.aMule/amule.conf $homeFolder/.aMule/amule.conf.backup

# Initialize categories map
for category in "${categories[@]}"; do
	parameters=`sed -n "/\[$category/,/\[/p" "$homeFolder/.aMule/amule.conf"`
	lastParameter=`echo "$parameters" | tail -n1`
	if [[ "$lastParameter" == [* ]]; then
		# Delete last line
		categoriesMap[$category]=`echo "$parameters" | sed '$ d' | tr '\n' '|'`
	else
		categoriesMap[$category]=`echo "$parameters" | tr '\n' '|'`
	fi
done


# Set relevant amule variables in config file
categoriesMap[eMule]=$( setCategoryParameter "eMule" "IncomingDir" "$(echo \"$AMULE_DAEMON_DOWNLOAD_FOLDER\" | sed -r 's/\/+/\\\//g')" )
categoriesMap[eMule]=$( setCategoryParameter "eMule" "TempDir" "$(echo \"$AMULE_DAEMON_TEMP_FOLDER\" | sed -r 's/\/+/\\\//g')" )
categoriesMap[eMule]=$( setCategoryParameter "eMule" "Port" "$AMULE_DAEMON_TCP_PORT" )
categoriesMap[eMule]=$( setCategoryParameter "eMule" "UDPPort" "$AMULE_DAEMON_UDP_PORT" )

categoriesMap[ExternalConnect]=$( setCategoryParameter "ExternalConnect" "AcceptExternalConnections" "1" )
categoriesMap[ExternalConnect]=$( setCategoryParameter "ExternalConnect" "ECPassword" "`echo -n $PASSWORD | md5sum | cut -d ' ' -f 1`" )
categoriesMap[ExternalConnect]=$( setCategoryParameter "ExternalConnect" "ECPort" "$AMULE_DAEMON_CLIENT_PORT" )

categoriesMap[WebServer]=$( setCategoryParameter "WebServer" "Enabled" "1" )
categoriesMap[WebServer]=$( setCategoryParameter "WebServer" "Password" "`echo -n $PASSWORD | md5sum | cut -d ' ' -f 1`" )
categoriesMap[WebServer]=$( setCategoryParameter "WebServer" "Port" "$AMULE_DAEMON_WEB_PORT" )

echo "" > $homeFolder/.aMule/amule.conf
for category in "${categories[@]}"; do
	echo ${categoriesMap[$category]} | tr '|' '\n' >> $homeFolder/.aMule/amule.conf
done


### SETUP SYSTEMD SERVICE ################################################
sed -i "s/=DESCRIPTION.*/=aMule daemon/g" $AMULE_DAEMON_FILE
sed -i "s/=man:PACKAGE.*/=man:amuled/g" $AMULE_DAEMON_FILE
sed -i "s/=SYSTEMD_TYPE.*/=forking/g" $AMULE_DAEMON_FILE
sed -i "s/=USERNAME.*/=$username/g" $AMULE_DAEMON_FILE
sed -i "s/=GROUP.*/=$username/g" $AMULE_DAEMON_FILE
sed -i "s/=COMMAND_AND_PARAMETERS_TO_START_SERVICE.*/=\/usr\/bin\/amuled -f/g" $AMULE_DAEMON_FILE


### CREATE DIRECT LINKS IN STARTUP MENU ##################################
# Create menu launcher for amule-daemon's web client.
echo "[Desktop Entry]
Name=aMule Web
Exec=xdg-open http://localhost:4711
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=aMule Web" > /usr/share/applications/amuled-web.desktop
# Create menu launcher to start amule-daemon.
echo "[Desktop Entry]
Name=aMule daemon start
Exec=gksudo systemctl start amuled
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Start aMule server" > /usr/share/applications/amuled-start.desktop
# Create menu launcher to stop amule-daemon.
echo "[Desktop Entry]
Name=aMule daemon stop
Exec=gksudo systemctl stop amuled
Icon=amule
Terminal=false
Type=Application
Categories=Network;P2P;
Comment=Stop aMule server" > /usr/share/applications/amuled-stop.desktop


### OTHERS ###############################################################
# Stop service and remove upstart scripts installed automatically by aMule daemon. Not used by systemd service manager
service amule-daemon stop 2>/dev/null
update-rc.d -f amule-daemon remove 2>/dev/null
rm /etc/init.d/amule-daemon 2>/dev/null
rm /etc/default/amule-daemon 2>/dev/null
# Set ownership of config files and/or folders
chown -R $username:$username $AMULE_DAEMON_DOWNLOAD_FOLDER $AMULE_DAEMON_TEMP_FOLDER $homeFolder/.aMule
# Download GeoIP Legacy Country Database. Needed by aMule and don't downloaded by amule daemon
sudo -u $username wget -O $homeFolder/.aMule/GeoIP.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
sudo -u $username gunzip -f $homeFolder/.aMule/GeoIP.dat.gz
# Extract amule icons
tar -C /usr/share/ -xvf "$scriptRootFolder/icons/amule.tar.gz"


### PREPARE DAEMON TO START ON SYSTEM BOOT AND START DAEMON NOW ##########
systemctl enable /etc/systemd/system/amuled.service
systemctl daemon-reload
systemctl start amuled
