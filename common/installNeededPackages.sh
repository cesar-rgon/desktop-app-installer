#!/bin/bash
##########################################################################
# This script tries to install Yad application to manage desktop windows
# of the menu and installation process
# @author 	César Rodríguez González
# @since 		1.3.3, 2017-04-25
# @version 	1.3.3, 2017-04-25
# @license 	MIT
##########################################################################

# Parameters
if [ -n "$1" ]; then scriptRootFolder="$1"; else scriptRootFolder="`pwd`/.."; fi
if [ -n "$2" ]; then username="$2"; else username="`whoami`"; fi
if [ -n "$3" ]; then homeFolder="$3"; else homeFolder="$HOME"; fi

# Add common variables
. $scriptRootFolder/common/commonVariables.properties
neededPackages=( gdebi-core libgtk2-perl lsb-release software-properties-common systemd )

function tryToInstallYad
{
  # STEP 1. Check if yad is NOT installed
  if [ -z "`dpkg -s yad 2>&1 | grep "Status: install ok installed"`" ]; then
    # STEP 2. Try to install yad utility from official repositories
    clear
    echo "*** INSTALLING NEEDED PACKAGES: yad"
    echo ""
    sudo apt install -y yad --fix-missing
    if [ -z "`dpkg -s yad 2>&1 | grep "Status: install ok installed"`" ]; then
          # STEP 3. If not installed, add third-party repository
          if [ "$distro" == "ubuntu" ] || [ "$distro" == "linuxmint" ]; then
            sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
          else
            sudo apt-key add $etcFolder/yad.key
            echo "deb http://ppa.launchpad.net/webupd8team/y-ppa-manager/ubuntu xenial main" | sudo tee "/etc/apt/sources.list.d/yad.list"
          fi
          # STEP 4. Update repositories
          sudo apt update
          # STEP 5. Try to install yad again
          sudo apt install -y yad --fix-missing
          # STEP 6. Remove third-party repository
          if [ "$distro" == "ubuntu" ] || [ "$distro" == "linuxmint" ]; then
            sudo add-apt-repository -y -r ppa:webupd8team/y-ppa-manager
          else
            sudo apt-key del EEA14886
            sed -i 's/^deb/#deb/g' "/etc/apt/sources.list.d/yad.list"
          fi
          # STEP 7. Update repositories again
          sudo apt update
    fi
  fi
}

# Installs needed packages to be ready to execute the script
if [ -z "$DISPLAY" ]; then
	neededPackages+=( dialog tmux )
else
	neededPackages+=( libnotify-bin xterm )
	tryToInstallYad
	if [ -z "`dpkg -s yad 2>&1 | grep "Status: install ok installed"`" ]; then
    neededPackages+=( zenity )
  fi
fi

for package in "${neededPackages[@]}"; do
	if [ -z "`dpkg -s $package 2>&1 | grep "Status: install ok installed"`" ]; then
		clear
		echo "*** INSTALLING NEEDED PACKAGES: $package"
		sudo apt install -y $package --fix-missing 1>/dev/null
	fi
done
