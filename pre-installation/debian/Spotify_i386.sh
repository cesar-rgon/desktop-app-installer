#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository to be able
# to install Spotify application
# @author César Rodríguez González
# @version 1.3.4, 2017-11-26
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

# Install package dirmngr and libssl1.0.0 library
apt install -y dirmngr
wget -O /var/cache/apt/archives/libssl1.0.0_1.0.1t-1+deb8u7_i386.deb http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u6_i386.deb 2>&1
dpkg -i /var/cache/apt/archives/libssl1.0.0_1.0.1t-1+deb8u7_i386.deb

# Add the Spotify repository signing key to be able to verify downloaded packages
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EFDC8610341D9410

# Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | tee /etc/apt/sources.list.d/spotify.list
