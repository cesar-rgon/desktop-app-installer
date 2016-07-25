##########################################################################
# This script contains common variables used by installation scripts or
# subscripts. Also, it checks if the script is being running like root
# user.
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 25/07/2016
# Licence: MIT
##########################################################################

########################################################################################################################
# Variables
########################################################################################################################
if [ "$2" != "" ]; then
	# username is passed by second parameter
	username="$2"
else
	username=`whoami`
fi
if [ "$3" != "" ]; then
	tempFolder="$3"
fi
homeFolder=`sudo -u $username -i eval 'echo $HOME'`
homeDownloadFolder="$homeFolder/`cat $homeFolder/.config/user-dirs.dirs | grep "XDG_DOWNLOAD_DIR" | awk -F "=" '{print $2}' | tr -d '"' | awk -F "/" '{print $2}'`"

# Check distro name appropiate to add third-party repositories to your OS. Not necessary your distro name. Only valid for Debian, Ubuntu and Ubuntu based linux (example: Linux Mint)
if [ "$(lsb_release -sc)" == "jessie" ]; then
	# Debian 8: Jessie
	distroName="jessie"
else
	# Ubuntu 16.04: Xenial (Or Ubuntu 16.04 based linux. For example, Linux Mint 18)
	distroName="xenial"
fi

########################################################################################################################
# Check if the script is being running like root user (root user has id equal to 0)
########################################################################################################################
if [ $(id -u) != 0 ]
then
	echo ""
	echo "This script must be executed by a root or sudoer user"
	echo ""
	exit 1
fi
