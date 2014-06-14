#!/bin/bash
##########################################################################
# This script executes commands to add third-party repository for games
#
# Author: César Rodríguez González
# Version: 1.3
# Last modified date (dd/mm/yyyy): 14/06/2014
# Licence: MIT
##########################################################################

wget -q -O - http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
sh -c 'echo "deb http://archive.getdeb.net/ubuntu trusty-getdeb games" >> /etc/apt/sources.list.d/getdeb.list'
