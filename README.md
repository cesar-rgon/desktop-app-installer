$ Desktop && app installer script
=================================

| Desktops and applications installer menu taking as source official repositories, third-party ones or others on Ubuntu, Debian, Linux Mint , LMDE or Raspbian (desktop or server).| ![Logo][tux-shell-terminal-logo] |
| --- | --- |

There are a lot of applications or desktops environments included in the default application list, it can be modified by the user by just editing a single text file. Furthermore, the user can add subscripts to extend main menu functionality, for example, add new repositories, setup applications, etc. In addition, exist one separate script for each application as an alternative way to do the installation proccess without the main menu.

> _Spanish version can be found [here][leeme.md] ( Versión española disponible [aquí][leeme.md] )_

> _Script's website can be found [here](http://cesar-rgon.github.io/desktop-app-installer-website/)_

##### Index
> 1. [Features](#1-features)
> 2. [Installing this project](#2-installing-this-project)  
>   - [Method 1. Clone this repository](#21-method-1-clone-this-repository)  
>   - [Method 2. Download and extract files](#22-method-2-download-and-extract-files)
> 3. [Executing a script](#3-executing-a-script)  
>   - [Main script](#31-main-script)  
>   - [Application script](#32-application-script)
> 4. [Execution's lifecycle](#4-executions-lifecycle)
> 5. [Extend functionality and customize applications to install](#5-extend-functionality-and-customize-applications-to-install)  
>   - [Understanding project structure](#51-understanding-project-structure)  
>   - [Add new application to a category. Modify or delete an existing one](#52-add-new-application-to-a-category-modify-or-delete-an-existing-one)  
>   - [Add new subscript to prepare the installation of an application](#53-add-new-subscript-to-prepare-the-installation-of-an-application)
>   - [Add a new file to add a third-party repo through a PPA](#54-add-a-new-file-to-add-a-third-party-repo-through-a-ppa)
>   - [Add new subscript to install an application](#55-add-new-subscript-to-install-an-application)  
>   - [Add new subscript to install a non-repository application](#56-add-new-subscript-to-install-a-non-repository-application)  
>   - [Add new subscript to setup an application](#57-add-new-subscript-to-setup-an-application)  
>   - [Add new subscript to setup EULA support](#58-add-new-subscript-to-setup-eula-support)
>   - [Add default authentication credentials for an application](#59-add-default-authentication-credentials-for-an-application)
> 6. [Add new translation file](#6-add-new-translation-file)
> 7. [Add new subscript to remove config files of an application during uninstallation proccess](#7-add-new-subscript-to-remove-config-files-of-an-application-during-uninstallation-proccess)
> 8. ANNEX
>   - [Subscript file considerations](#subscript-file-considerations)
>   - [Subscript commands considerations](#subscript-commands-considerations)

```
Tested on:   Ubuntu 16.04 LTS Xenial, Debian 9 Stretch, Linux Mint 18.1 Serena, LMDE 2 Betsy and Raspbian Jessie (desktop or server).
             With some changes in config files, it can be 100% compatible with previous versions.
Version:     1.3.4
Last change: 2017/11/27 (yyyy/mm/dd)
```

### 1. Features
* One main script that shows a menu of aplications or linux desktops enviroment which can be selected for installation.
* Alternatively, there is one separate script for each application, so it can be installed by just executing the appropriate script.
* Install official and third-party repository applications. In the last case, first add the necessary repositories to the distro.
* Download, extract and install non-repository applications through custom subscripts that extend the main script functionality. It includes several subscripts by default.
* Set up applications after they are installed through custom subscripts.
* Customize your own application list to be installed and third-party repositories to add to your distro by just editing some config files (no need to edit main script at all for this purpose).
* Third-party repositories, added by some applications, will be automatically disabled after the installation proccess.
* EULA support. Install applications automatically with no need of user interaction to accept legal terms of the application.
* The script runs with an interface adapted to the detected environment: Dialog for
terminal. Yad or Zenity for desktop or terminal emulator.
* User can set the authentication credentials for thouse applications witch require user's login.
* Installation log file that shows installation steps and errors if they have occurred.
* Multilingual support. Easy to add new translations. For the time being English and Spanish languages are included. The script detects system language and it use the appropiate translation.  
* Valid for multiple arquitecture systems: x64, i386, arm.

---
[Back to index](#index)

### 2. Installing this project

#### 2.1 Method 1. Clone this repository
```bash
$ sudo apt install git
$ git clone https://github.com/cesar-rgon/desktop-app-installer.git
$ cd desktop-app-installer
```

#### 2.2 Method 2. Download and extract files
```bash
$ wget https://github.com/cesar-rgon/desktop-app-installer/archive/master.tar.gz
$ tar -xvf master.tar.gz
$ cd desktop-app-installer-master
```

---
[Back to index](#index)

### 3. Executing a script

#### 3.1 Main script
It shows a menu of applications to be installed which are ordered by categories. The user can navigates through categories and selects the applications to be installed. Furthermore user can edit one specific category to modify the selected applications to be installed. Finally, when all are ready, installation process will begin.
```bash
$ bash installer.sh
```

##### Main menu. Difference between both modes
> ![Main menu screenshot desktop|terminal modes][screenshot-monitors]

##### Internet category (Desktop/Terminal mode)
> ![Intenet category window screenshot on desktop mode][screenshot-desktop-internetapp]
> ![Intenet category window screenshot on terminal mode][screenshot-terminal-internetapp]

##### Main menu with selected applications (Desktop/Terminal mode)
> ![Main menu screenshot with selected applications on desktop mode][screenshot-desktop-mainmenu]
> ![Main menu screenshot with selected applications on terminal mode][screenshot-terminal-mainmenu]

##### Change authentication credentials (Desktop/Terminal mode)
> ![Change authentication credentials screenshot on desktop mode][screenshot-desktop-credentials]
> ![Change authentication credentials screenshot on terminal mode][screenshot-terminal-credentials]

##### Installing applications (Desktop/Terminal mode)
> ![Screenshot installing an application on desktop mode][screenshot-desktop-installing-app]
> ![Screenshot installing an application on terminal mode][screenshot-terminal-installing-app]

##### Log
> ![Screenshot log view on desktop mode][screenshot-desktop-log]


#### 3.2 Application script
There is one separate script for each application, so it can be installed just by executing it.
```bash
$ bash ./app-scripts/applicationName.sh
```

---
[Back to index](#index)

### 4. Execution's lifecycle
1. The user must SELECT the APPLICATIONS to be installed.

2. The user can SET the AUTHENTICATION CREDENTIALS for thouse applications witch require user's login.

3. The User REQUIRES to START the INSTALATION process.

4. The script EXECUTES INITIAL OPERATIONS to be ready to install the selected applications.

5. For each application, execute next steps:
  * The script ADDS THIRD-PARTY REPOSITORY through a PPA, if defined in a specific file.
  * The script EXECUTES PRE-INSTALLATION OPERATIONS of the application to be installed if exists a custom sub-script for that purpose. The sub-script could add a third-party repository, custom commands instead of use a PPA, and/or prepare the installation of the application.
  * The script INSTALLS the APPLICATION, with EULA support, taking as source official distro repositories, third-party one or a custom sub-script created for that purpose.
  * The script automatically DISABLES THIRD-PARTY REPOSITORY of the installed application to avoid possible problems related to this.
  * The script EXECUTES POST-INSTALLATION OPERATIONS to set-up the installed application if exists a custom sub-script for that purpose.
  * The script STORES CREDENTIALS for AUTHENTICATION to the applicacion, if required.

6. The script EXECUTES FINAL OPERATIONS to clean packages, remove temporal files/folders, show logs and show login credentials.

```
NOTE 1: Main script runs all the previous steps whereas each individual application script skip step one and run the remaining.

NOTE 2: The script automatically updates repositories after pre-installation operations, add third-party repository or disable it.

NOTE 3: Logs generated during installation process contains installation steps and posible errors occurred.

NOTE 4: The Login credentials are used by those installed applications that require user authentication.
```

---
[Back to index](#index)

### 5. Extend functionality and customize applications to install
To extend script functionality is required to add subscripts for custom purposes. To customize applications to install, it's necessary to edit some config files. These actions will be detailed in next chapters.

#### 5.1 Understanding project structure
Tree of folders and some files:
```
├── app-scripts             It contains one installation script per application
│   ├── template-script.sh
│   └── *.sh
│
├── common                  It contains common functions, common variables and commands used by installation scripts
│   ├── commonFunctions.sh
│   ├── commonVariables.properties
│   ├── installapp.sh
│   └── *.sh
│
├── etc                     It contains config files used by some subscripts and version number of main installation script
│   ├── systemd.service
│   ├── version
│   │
│   ├── applist             It contains application list available to install for every linux distribution supported
│   │   ├── applicationList-debian.csv
│   │   ├── applicationList-linuxmint.csv
│   │   ├── applicationList-lmde.csv
│   │   ├── applicationList-raspbian.csv
│   │   └── applicationList-ubuntu.csv
│   │
│   ├── credentials         It contains a file per application with username/password needed for authentication
│   │   ├── template-credentials.properties
│   │   └── *.properties
│   │
│   ├── eula                It contains files to avoid questions to accept applications terms of use during installation's process
│   │   ├── template-eula
│   │   └── *
│   │
│   ├── languages           It contains language translation files used by installation scripts
│   │   ├── en.properties
│   │   ├── es.properties
│   │   └── *.properties
│   │
│   ├── old-init.d          It contains init.d scripts. Used by some daemons (for compatibility with LMDE2)
│   │   └── *
│   │
│   ├── ppa                 It contains one file per application which contains PPA to be added before installation
│   │   └── *
│   │
│   └── *
│
├── icons                   It contains a sets of application icons used by subscripts
│   ├── *
│   └── installer/*         It contains a set of icons used by installation script
│
├── installer.sh            File to start main installation script
│
├── install-non-repo-apps   It contains subscripts to install non-repository applications
│   ├── template-non-repo-app.sh
│   ├── *.sh                Subscripts used on any linux system
│   ├── debian/*.sh         Subscripts only used on a Debian system
│   ├── linuxmint/*.sh      Subscripts only used on a Linux Mint system
│   ├── lmde/*.sh           Subscripts only used on a LMDE system
│   ├── raspbian/*.sh       Subscripts only used on a Raspbian system
│   └── ubuntu/*.sh         Subscripts only used on an Ubuntu system
│
├── menu                    It contains functions used by main script menu (Terminal / Desktop)
│   ├── dialogFuntions.sh
│   ├── menuFunctions.sh
│   ├── menuVariables.properties
│   ├── yadFunctions.sh
│   └── zenityFunctions.sh
│
├── post-installation       It contains subscripts to setup applications after installation
│   ├── template-post-installation.sh
│   ├── *.sh                Subscripts used on any linux system
│   ├── debian/*.sh         Subscripts only used on a Debian system
│   ├── linuxmint/*.sh      Subscripts only used on a Linux Mint system
│   ├── lmde/*.sh           Subscripts only used on a LMDE system
│   ├── raspbian/*.sh       Subscripts only used on a Raspbian system
│   └── ubuntu/*.sh         Subscripts only used on an Ubuntu system
│
├── pre-installation        It contains subscripts to add third-party repositories and/or prepare the installation of apps
│   ├── template-pre-installation.sh
│   ├── *.sh                Subscripts used on any linux system
│   ├── debian/*.sh         Subscripts only used on a Debian system
│   ├── linuxmint/*.sh      Subscripts only used on a Linux Mint system
│   ├── lmde/*.sh           Subscripts only used on a LMDE system
│   ├── raspbian/*.sh       Subscripts only used on a Raspbian system
│   └── ubuntu/*.sh         Subscripts only used on an Ubuntu system
│
├── uninstall               It contains subscripts to remove application config files
│   ├── template-uninstall.sh
│   ├── *.sh                Subscripts used on any linux system
│   ├── debian/*.sh         Subscripts only used on a Debian system
│   ├── linuxmint/*.sh      Subscripts only used on a Linux Mint system
│   ├── lmde/*.sh           Subscripts only used on a LMDE system
│   ├── raspbian/*.sh       Subscripts only used on a Raspbian system
│   └── ubuntu/*.sh         Subscripts only used on an Ubuntu system
│
└── uninstaller.sh          File to start main uninstallation script
```

| Some important files                                           | Description                                                                                   |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------------  |
| [commonFunctions.sh][commonFunctions.sh]                       | It contains common functions used by all the installation scripts                             |
| [commonVariables.properties][commonVariables.properties]       | It contains common variables available for all scripts                                                          |
| [installapp.sh][installapp.sh]                                 | It contains needed commands to allow the installation of an application and posible reparation in case of error                                      |
| [dialogFunctions.sh][dialogFunctions.sh]                       | It contains menu functions for Dialog box (terminal mode). Used only by main script           |
| [menuFunctions.sh][menuFunctions.sh]                           | It contains menu functions. Used only by main script                                          |
| [menuVariables.properties][menuVariables.properties]           | It contains menu global variables available only for main script                              |
| [yadFunctions.sh][yadFunctions.sh]                             | It contains menu functions for Yad windows (desktop mode). Used only by main script        |
| [zenityFunctions.sh][zenityFunctions.sh]                       | It contains menu functions for Zenity windows (desktop mode). Used only by main script        |
| [applicationList-debian.csv][applicationList-debian.csv]               | It defines categories, applications and related packages for a Debian system                  |
| [applicationList-linuxmint.csv][applicationList-linuxmint.csv]         | It defines categories, applications and related packages for a Linux Mint system              |
| [applicationList-lmde.csv][applicationList-lmde.csv]                   | It defines categories, applications and related packages for a LMDE system                    |
| [applicationList-raspbian.csv][applicationList-raspbian.csv]               | It defines categories, applications and related packages for a Raspbian system                    |
| [applicationList-ubuntu.csv][applicationList-ubuntu.csv]               | It defines categories, applications and related packages for an Ubuntu system                 |
| [installer.sh][installer.sh]                                   | Main script file                                                                              |
| [en.properties][en.properties]                                 | English translation file                                                                      |
| [es.properties][es.properties]                                 | Spanish translation file                                                                      |
| [template-script.sh][template-script.sh]                       | Template file to help to create a new script file to install an application                   |
| [template-pre-installation.sh][template-pre-installation.sh]   | Template file to help to create a new subscript to add TPrepo or run pre-inst. commands       |
| [template-eula][template-eula]                                 | Template file to help to create a new subscript to setup EULA support for an application           |
| [template-non-repo-app.sh][template-non-repo-app.sh]           | Template file to help to create a new subscript to install a non-repository application       |
| [template-post-installation.sh][template-post-installation.sh] | Template file to help to create a new application subscript to run post-installation commands |
| [template-uninstall.sh][template-uninstall.sh] | Template file to help toremove application config files. No need to define commands to uninstall the application |
---

[Back to index](#index)

#### 5.2 Add new application to a category. Modify or delete an existing one
To add an application to be installed follow next steps:

1. Edit applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file (it is recommended to use LibreOffice or OpenOffice) and add a new line with the next syntax:

| 1st column - Category (*)  | 2nd column - Application Name (*) | 3rd column (Packages)   |
| -------------------------- | --------------------------------- | ------------------------|
| CategoryName               | ApplicationName                   | package1|package2|...   |

  Considerations:
  * Blank or comment lines are ignored in this file.
  * First column - Category: is mandatory. It repeats once per line, that means, once per application of this category.
  * If the category name is new in the file, the script will generate a new window for this category.
  * Each category must contain at least one application.
  * The category name shall contain only letters, digits and/or underscores '_' and it can't start with a digit.
  * Second column - Application name: is mandatory.
  * Just one row per application.
  * The application name shall contain only letters, digits and/or underscores '_' and it can't start with a digit.
  * The application source can be official repositories, third-party repositories even other sources (non-repositories).
  * The order in which applications are listed in the menu script is the same as set in this config file.
  * Third column - Packages: is mandatory only if the application belongs to a repository.
  * Package names must be separated by whitespace character.
  * Non-repository applications must leave this field empty.

2. Edit [en.properties][en.properties] file and add a description for categories (if it's a new one) and applications with the next syntax:
  CategoryNameDescription=Here goes the category description that is used by the main menu  
  ApplicationNameDescription=Here goes the application name description that is used by the main menu

  Considerations:
  * CategoryNameDescription is composed by _CategoryName_ word: must be identical (case-sensitive) to the category name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file. _Description_ word: must always follow the category name word.
  * To be intuitive, is recommended that CategoryNameDescription is defined in the 'CATEGORIES' section of the file.
  * ApplicationNameDescription is composed by: _ApplicationName_ word: must be identical (case-sensitive) to the application name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file. _Description_ word: must always follow the application name word.
  * To be intuitive, is recommended that ApplicationNameDescription is defined in the 'APPLICATIONS' section of the file.
  * It's recommended, but not mandatory, to add those descriptions to other translation files.
  * You can create a new translation file in your native language to be easier for your understanding. See chapter [Add new translation file](#6-add-new-translation-file) for more information.

To modify or delete an application or category just edit applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file and change/delete the corresponding lines.

---
[Back to index](#index)

#### 5.3 Add new subscript to prepare the installation of an application
To add a new subscript that prepares the installation of an application before the installation proccess begins just follow next steps:

1. Create a new file taking, as base, the [template-pre-installation.sh][template-pre-installation.sh] file following next [considerations](#subscript-file-considerations).
2. Add neccessary commands at the end of the file to add a third-party repository and/or to setup the application following next [considerations](#subscript-commands-considerations).

---
[Back to index](#index)

#### 5.4 Add a new file to add a third-party repo through a PPA
To add a new file that defines PPA to be used to add a third-party repository for an application just follow next steps:
1. Create a new file './etc/ppa/applicationName'
  Considerations:
  * The filename must be identically (case-sensitive) to the related application name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file.
  * The filename must not have extension at all.
2. The file must contain one and only one PPA. It can contains:
  * Blanck lines [optional]
  * '# Comentary' [optional]
  * ppa:/...  [mandatory]

---
[Back to index](#index)

#### 5.5 Add new subscript to install an application
To add a new installation script for an application follow next steps:

1. Create a new file './app-scripts/application-name.sh' taking, as base, next commands defined in [template-script.sh][template-script.sh] file

2. Modify content to asign values to variables: _appName_ and _logFile_  
  Considerations:
  * appName value must be identically (case-sensitive) to the application name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file.
  * logFile value is used to create the log file ~/logs/logFile.

---
[Back to index](#index)



#### 5.6 Add new subscript to install a non-repository application
To add a new subscript that installs a non-repository application just follow next steps:

1. Create a new file taking, as base, the [template-non-repo-app.sh][template-non-repo-app.sh] file following next [considerations](#subscript-file-considerations).
2. Add neccessary commands at the end of the file to download and install the non-repository application following next [considerations](#subscript-commands-considerations).

---
[Back to index](#index)

#### 5.7 Add new subscript to setup an application
To add a new subscript to setup an application after installation proccess just follow next steps:

1. Create a new file taking, as base, the [template-post-installation.sh][template-post-installation.sh] file following next [considerations](#subscript-file-considerations).
2. Add neccessary commands at the end of the file to setup the application following next [considerations](#subscript-commands-considerations).

---
[Back to index](#index)

#### 5.8 Add new subscript to setup EULA support
To add a new subscript to setup EULA support for an application just follow next steps:

1. Create a new file './etc/eula/applicationName' taking, as base, next commands from [template-eula][template-eula] file.
  Considerations:
  * The filename must be identically (case-sensitive) to the related application name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file.

2. Add parameters at the end of the file with the syntax indicated in template file to skip EULA questions during installation proccess.

---
[Back to index](#index)

#### 5.9 Add default authentication credentials for an application
To add default authentication credentials for an application which requires user's login just follow next steps:

1. Create a new file './etc/credentials/applicationName.properties' taking, as base, [template-credentials.properties][template-credentials.properties] file.
  Considerations:
  * The applicationName must be identically (case-sensitive) to the related application name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file.

2. Set values of variables appUsername, appPassword (credentials) and usernameCanBeEdited, passwordCanBeEdited (that tells to script if the value of the associated variable can be modified).

---
[Back to index](#index)

### 6. Add new translation file
To add a new language file just follow next steps:

1. Create a new file './languages/xx.properties' copying the content of an existing language file, for example, [en.properties][en.properties]
  Considerations:
  * 'xx' must consist of two lowercase characters based on [ISO639-1 code][ISO639] for the specific language.

2. Translate values of all variables to the specific language.  
  Considerations:
  * The variable names must not be changed at all.

---
[Back to index](#index)

### 7. Add new subscript to remove config files of an application during uninstallation proccess
To define a subscript that remove settings of an installed repo application, just follow next steps:

1. Create a new file taking, as base, the [template-uninstall.sh][template-uninstall.sh] file following next [considerations](#subscript-file-considerations).
2. Add neccessary commands at the end of the file to remove settings of the application during uninstallation proccess following next [considerations](#subscript-commands-considerations).
3. No need to define commands to uninstall the application, just to remove config settings. Main script will uninstall the application automatically.
4. Only is valid for repo-applications, that means, not valid for non-repo applications.

---
[Back to index](#index)

### ANNEX

#####  Subscript file considerations:
  * The filename must follow next pattern: ApplicationName[_i386/_x64].sh
    - ApplicationName: must be identical (case-sensitive) to the application name defined in applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv file.
    - _i386 / _x64 / _arm: Optional if neccessary. Script to be executed only if match corresponding O.S. architecture (that means, i386 for 32 bits O.S.; x64 for 64 bits O.S.; arm for ARM O.S.).
    - The extension must be always '.sh'
  * The script must be ubicated in _pre-installation|post-installation|install-non-repo-apps|uninstall_ folder if it's valid for all supported linux distros. We call general subscript and <target-folder>
  * The script must be ubicated in _<target-folder>/ubuntu_, _<target-folder>/debian_, _<target-folder>/linuxmint_, _<target-folder>/lmde_, _<target-folder>/raspbian_ folder if it's valid only for a specific supported linux distro. We call specific subscript.
  * Is possible to create a specific and a general subscripts for the same application. Both will be executed.

#####  Subscript commands considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by [commonVariables.properties][commonVariables.properties] file.
  * This script must be non-interactive, that means, no echo to monitor, no read from keyboard, no wait confirmation.

### Author notes
Any contribution to this project would be appreciated.  
I hope you find it useful.

<!-- References -->
[leeme.md]:./LEEME.md
[commonFunctions.sh]:./common/commonFunctions.sh
[commonVariables.properties]:./common/commonVariables.properties
[installapp.sh]:./common/installapp.sh
[dialogFunctions.sh]:./menu/dialogFunctions.sh
[menuFunctions.sh]:./menu/menuFunctions.sh
[menuVariables.properties]:./menu/menuVariables.properties
[yadFunctions.sh]:./menu/yadFunctions.sh
[zenityFunctions.sh]:./menu/zenityFunctions.sh
[applicationList-debian.csv]:./etc/applist/applicationList-debian.csv
[applicationList-linuxmint.csv]:./etc/applist/applicationList-linuxmint.csv
[applicationList-lmde.csv]:./etc/applist/applicationList-lmde.csv
[applicationList-ubuntu.csv]:./etc/applist/applicationList-ubuntu.csv
[applicationList-raspbian.csv]:./etc/applist/applicationList-raspbian.csv
[installer.sh]:./installer.sh
[en.properties]:./etc/languages/en.properties
[es.properties]:./etc/languages/es.properties
[template-pre-installation.sh]:./pre-installation/template-pre-installation.sh
[template-post-installation.sh]:./post-installation/template-post-installation.sh
[template-uninstall.sh]:./uninstall/template-uninstall.sh
[template-eula]:./etc/eula/template-eula
[template-credentials.properties]:./etc/credentials/template-credentials.properties
[template-non-repo-app.sh]:./install-non-repo-apps/template-non-repo-app.sh
[template-script.sh]:./app-scripts/template-script.sh
[screenshot-monitors]:http://cesar-rgon.github.io/desktop-app-installer-website/images/monitors.png
[screenshot-desktop-internetapp]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/yad-02.png
[screenshot-terminal-internetapp]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/dialog-02.png
[screenshot-desktop-mainmenu]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/yad-03.png
[screenshot-terminal-mainmenu]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/dialog-03.png
[screenshot-desktop-credentials]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/yad-04.png
[screenshot-terminal-credentials]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/dialog-05.png
[screenshot-desktop-installing-app]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/yad-05.png
[screenshot-terminal-installing-app]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/dialog-06.png
[screenshot-desktop-log]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/en/yad-07.png
[ISO639]:http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[tux-shell-terminal-logo]:http://cesar-rgon.github.io/desktop-app-installer-website/images/logos/desktop-app-installer.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
