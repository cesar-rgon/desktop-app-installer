#!/bin/bash
##########################################################################
# This script configures Clementine application to use monochrome taskbar
# icons.
#
# Author: César Rodríguez González
# Version: 1.0
# Last modified date (dd/mm/yyyy): 05/05/2014
# Licence: MIT
##########################################################################

# Create symbolic links for Clementine monochrome taskbar icons
ln -s /usr/share/icons/ubuntu-mono-dark/apps/24/clementine-panel.png /usr/share/icons/hicolor/24x24/status/clementine-panel.png
ln -s /usr/share/icons/ubuntu-mono-dark/apps/24/clementine-panel-grey.png /usr/share/icons/hicolor/24x24/status/clementine-panel-grey.png

