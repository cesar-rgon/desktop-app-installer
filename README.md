Linux app installer
===================

| Installation menu for applications from official repositories, third-party ones or external sources on any Ubuntu , Debian, Linux Mint or LMDE linux (desktop or server).| ![Logo][tux bricoleur] |
|-

There are a lot of applications included in the default list, but this list can be modified by the user by just editing a single text file. Furthermore, users can add subscripts to extend main menu functionality, for example, add new repositories, setup applications, etc. In addition, exist one separate script for each application as an alternative way to do the installation proccess without the main menu.

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
>   - [Add new subscript to install an application](#53-add-new-subscript-to-install-an-application)  
>   - [Add new subscript to add a third-party repository](#54-add-new-subscript-to-add-third-party-repository)  
>   - [Add new subscript to prepare the installation of an application](#55-add-new-subscript-to-prepare-the-installation-of-an-application)
>   - [Add new subscript to install a non-repository application](#56-add-new-subscript-to-install-a-non-repository-application)  
>   - [Add new subscript to setup an application](#57-add-new-subscript-to-setup-an-application)  
>   - [Add new subscript to setup EULA support](#58-add-new-subscript-to-setup-eula-support)
> 6. [Add new translation file](#6-add-new-translation-file)

```
Valid for:   Ubuntu v16.04, Debian 8, Linux Mint 18 and LMDE (for all desktops or server).
             With some changes in config files, it can be 100% compatible with previous versions.
Version:     1.3
Last change: 08/02/2016 (mm/dd/yyyy)
```

### 1. Features
* One main script that shows a menu of aplications which can be selected for installation.
* Alternatively, there is one separate script for each application, so it can be installed by just executing the appropriate script.
* Install official and third-party repository applications. In the last case, first add the necessary repositories to the distro.
* Download, extract and install non-repository applications through custom subscripts that extend the main script functionality. It includes several subscripts by default.
* Set up applications after they are installed through custom subscripts.
* Customize your own application list to install and third-party repositories to add to your distro by just editing some config files (no need to edit main script at all for this purpose).
* EULA support. Install applications automatically with no need of user interaction to accept legal terms of the application. Disabled by default.
* The script runs with an interface adapted to the detected enviroment: Dialog for terminal. Zenity for desktop or terminal emulator.
* Installation log file that shows installation steps and errors if they have occurred.
* Multilingual support. Easy to add new translations. For the time being English and Spanish languages are included. The script detects system language and it use the appropiate translation.  

---
[Back to index](#index)

### 2. Installing this project

#### 2.1 Method 1. Clone this repository
```bash
$ sudo apt-get install git
$ git clone -b master https://github.com/cesar-rgon/linux-app-installer.git
$ cd linux-app-installer
```

#### 2.2 Method 2. Download and extract files
```bash
$ wget https://github.com/cesar-rgon/linux-app-installer/archive/master.tar.gz
$ tar -xvf master.tar.gz
$ cd linux-app-installer-master
```

---
[Back to index](#index)

### 3. Executing a script

#### 3.1 Main script
It shows a menu of applications to be installed which are ordered by categories. The user can navigates through categories and selects the applications to be installed. Furthermore user can edit one specific category to modify the selected applications to be installed. Finally, when all are ready, installation process will begin.
```bash
$ bash installer.sh
```

##### Installer main menu (Desktop/Terminal mode)
> ![Main menu screenshot on desktop mode][screenshot-desktop-mainmenu1]
> ![Main menu screenshot on terminal mode][screenshot-terminal-mainmenu1]

##### Installer Internet Category (Desktop/Terminal mode)
> ![Intenet category window screenshot on desktop mode][screenshot-desktop-internetapp]
> ![Intenet category window screenshot on terminal mode][screenshot-terminal-internetapp]

##### Installer main menu with selected applications (Desktop/Terminal mode)
> ![Main menu screenshot with selected applications on desktop mode][screenshot-desktop-mainmenu2]
> ![Main menu screenshot with selected applications on terminal mode][screenshot-terminal-mainmenu2]


#### 3.2 Application script
There is one separate script for each application, so it can be installed just by executing it.
```bash
$ bash ./scripts/applicationName.sh
```

---
[Back to index](#index)

### 4. Execution's lifecycle
1. The user must select the applications to install.
2. The script would add third-party repositories of some of the selected applications, if required.
3. The script executes previous tasks, before the installation process begins, defined in custom sub-scripts that contain needed commands to be executed to leave all ready to start.
4. The script installs selected applications, with EULA support if needed, taking as source official distro repositories or third-party ones.
5. The script executes custom subscripts to install the selected non-repository applications.
6. The script executes custom subscripts to setup some of the selected applications.
7. The script runs final operations to finish installation process and to clean all temporal files.
8. The script shows an installation log file which contains installation steps and errors if occurred during installation process.

Main script runs all the previous steps, whereas individual application scripts skip step one and run the remaining.

---
[Back to index](#index)

### 5. Extend functionality and customize applications to install
To extend script functionality is required to add subscripts for custom purposes. To customize applications to install, it's necessary to edit some config files. These actions will be detailed in next chapters.

#### 5.1 Understanding project structure
Tree of folders and some files:
```
├── applist                 It contains application list available to install for every linux distribution supported
│   ├── applicationList.debian
│   ├── applicationList.linuxmint
│   ├── applicationList.lmde
│   └── applicationList.ubuntu
│
├── common                  It contains common functions, common variables and commands used by installation scripts
│   ├── commonFunctions.sh
│   ├── commonVariables.sh
│   └── installapp.sh
│
├── etc                     It contains config files used by some subscripts and version number of main installation script
│   ├── systemd.service
│   ├── version
│   └── *
│
├── eula                    It contains files to avoid questions to accept applications terms of use during installation's process
│   ├── template-eula
│   └── *
│
├── icons                   It contains a sets of application icons used by subscripts
│   ├── *
│   └── installer/*         It contains a set of icons used by installation script
│
├── installer.sh            File to start main installation script
│
├── languages               It contains language translation files used by installation scripts
│   ├── en.properties
│   ├── es.properties
│   └── *
│
├── menu                    It contains functions used by main script menu (Terminal / Desktop)
│   ├── dialogFuntions.sh
│   ├── menuFunctions.sh
│   ├── menuVariables.sh
│   └── zenityFunctions.sh
│
├── non-repository-apps     It contains subscripts to install non-repository applications
│   ├── template-non-repo-app.sh
│   ├── *                   Subscripts used on any linux system
│   ├── debian/*            Subscripts only used on a Debian system
│   ├── linuxmint/*         Subscripts only used on a Linux Mint system
│   ├── lmde/*              Subscripts only used on a LMDE system
│   └── ubuntu/*            Subscripts only used on an Ubuntu system
│
├── post-installation       It contains subscripts to setup applications after installation
│   ├── template-post-installation.sh
│   ├── *                   Subscripts used on any linux system
│   ├── debian/*            Subscripts only used on a Debian system
│   ├── linuxmint/*         Subscripts only used on a Linux Mint system
│   ├── lmde/*              Subscripts only used on a LMDE system
│   └── ubuntu/*            Subscripts only used on an Ubuntu system
│
├── pre-installation       It contains subscripts to prepare the installation of some applications
│   ├── template-pre-installation.sh
│   ├── *                   Subscripts used on any linux system
│   ├── debian/*            Subscripts only used on a Debian system
│   ├── linuxmint/*         Subscripts only used on a Linux Mint system
│   ├── lmde/*              Subscripts only used on a LMDE system
│   └── ubuntu/*            Subscripts only used on an Ubuntu system
│
├── scripts                 It contains one installation script per application
│   ├── template-script.sh
│   └── *.sh
│
└── third-party-repo        It contains subscripts to add third-party repositories for some applications
    ├── template-repository.sh
    ├── *                   Subscripts used on any linux system
    ├── debian/*            Subscripts only used on a Debian system
    ├── linuxmint/*         Subscripts only used on a Linux Mint system
    ├── lmde/*              Subscripts only used on a LMDE system
    └── ubuntu/*            Subscripts only used on an Ubuntu system
```

| Some important files                                           | Description                                                                                   |
| -------------------------------------------------------------- | --------------------------------------------------------------------------------------------  |
| [commonFunctions.sh][commonFunctions.sh]                       | It contains common functions used by all the installation scripts                             |
| [commonVariables.sh][commonVariables.sh]                       | It contains common variables available for all scripts                                        |
| [dialogFunctions.sh][dialogFunctions.sh]                       | It contains menu functions for Dialog box (terminal mode). Used only by main script           |
| [menuFunctions.sh][menuFunctions.sh]                           | It contains menu functions. Used only by main script                                          |
| [menuVariables.sh][menuVariables.sh]                           | It contains menu global variables available only for main script                              |
| [zenityFunctions.sh][zenityFunctions.sh]                       | It contains menu functions for Zenity windows (desktop mode). Used only by main script        |
| [applicationList.debian][applicationList.debian]               | It defines categories, applications and related packages for a Debian system                  |
| [applicationList.linuxmint][applicationList.linuxmint]         | It defines categories, applications and related packages for a Linux Mint system              |
| [applicationList.lmde][applicationList.lmde]                   | It defines categories, applications and related packages for a LMDE system                    |
| [applicationList.ubuntu][applicationList.ubuntu]               | It defines categories, applications and related packages for an Ubuntu system                 |
| [installer.sh][installer.sh]                                   | Main script file                                                                              |
| [en.properties][en.properties]                                 | English translation file                                                                      |
| [es.properties][es.properties]                                 | Spanish translation file                                                                      |
| [template-script.sh][template-script.sh]                       | Template file to help to create a new script file to install an application                   |
| [template-repository.sh][template-repository.sh]               | Template file to help to create a new subscript to add a third-party repository               |
| [template-pre-installation.sh][template-pre-installation.sh]   | Template file to help to create a new application subscript to run pre-installation commands  |
| [template-eula][template-eula]                                 | Template file to help to create a new subscript to setup EULA support for a package           |
| [template-non-repo-app.sh][template-non-repo-app.sh]           | Template file to help to create a new subscript to install a non-repository application       |
| [template-post-installation.sh][template-post-installation.sh] | Template file to help to create a new application subscript to run post-installation commands |

---

[Back to index](#index)

#### 5.2 Add new application to a category. Modify or delete an existing one
To add an application to be installed follow next steps:

1. Edit [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file and add a new line with the next syntax:

| 1st column - Category (*)  | 2nd column - Application Name (*) | Other columns (Packages) |
| -------------------------- | --------------------------------- | ------------------------ |
| CategoryName               | ApplicationName                   | repository package(s)    |

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
  * Package names must be separated by whitespaces.
  * Non-repository applications must leave this field empty.

2. Edit [en.properties][en.properties] file and add a description for categories (if it's a new one) and applications with the next syntax:
  CategoryNameDescription=Here goes the category description that is used by the main menu  
  ApplicationNameDescription=Here goes the application name description that is used by the main menu

  Considerations:
  * CategoryNameDescription is composed by _CategoryName_ word: must be identical (case-sensitive) to the category name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file. _Description_ word: must always follow the category name word.
  * To be intuitive, is recommended that CategoryNameDescription is defined in the 'CATEGORIES' section of the file.
  * ApplicationNameDescription is composed by: _ApplicationName_ word: must be identical (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file. _Description_ word: must always follow the application name word.
  * To be intuitive, is recommended that ApplicationNameDescription is defined in the 'APPLICATIONS' section of the file.
  * It's recommended, but not mandatory, to add those descriptions to other translation files.
  * You can create a new translation file in your native language to be easier for your understanding. See chapter [Add new translation file](#6-add-new-translation-file) for more information.

To modify or delete an application or category just edit [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file and change/delete the corresponding lines.

---
[Back to index](#index)

#### 5.3 Add new subscript to install an application
To add a new installation script for an application follow next steps:

1. Create a new file './scripts/application-name.sh' taking, as base, next commands defined in [template-script.sh][template-script.sh] file

2. Modify content to asign values to variables: _appName_ and _logFile_  
  Considerations:
  * appName value must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * logFile value is used to create the log file ~/logs/logFile.

---
[Back to index](#index)

#### 5.4 Add new subscript to add third-party repository
To add a new subscript that adds a third-party repository for an application follow next steps:

1. Create a new file taking, as base, the [template-repository.sh][template-repository.sh] file following next [considerations](#subscript-file-considerations).
2. Add neccessary commands at the end of the file to add the repository following next [considerations](#subscript-commands-considerations).

---
[Back to index](#index)

#### 5.5 Add new subscript to prepare the installation of an application
To add a new subscript that prepares the installation of an application before the installation proccess begins just follow next steps:

1. Create a new file taking, as base, the [template-pre-installation.sh][template-pre-installation.sh] file following next [considerations](#subscript-file-considerations).
2. Add neccessary commands at the end of the file to setup the application following next [considerations](#subscript-commands-considerations).

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
To add a new subscript to setup EULA support for a package just follow next steps:

1. Create a new file './eula/packageName' taking, as base, next commands from [template-eula][template-eula] file.
  Considerations:
  * The filename must be identically (case-sensitive) to the related application package defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.

2. Add parameters at the end of the file with the syntax indicated in template file to skip EULA questions during installation proccess.

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

### ANNEX

#####  Subscript file considerations:
  * The filename must follow next pattern: ApplicationName[_i386/_x64]
    - ApplicationName: must be identical (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
    - _i386 / _x64: Optional if neccessary. Script to be executed only if match corresponding O.S. architecture (that means, i386 for 32 bits O.S.; x64 for 64 bits O.S.).
  * The script must be ubicated in _./third-party-repo_ folder if it's valid for all supported linux distros. We call general subscript.
  * The script must be ubicated in _./third-party-repo/ubuntu_, _./third-party-repo/debian_, _./third-party-repo/linuxmint_, _./third-party-repo/lmde_ folder if it's valid only for a specific supported linux distro. We call specific subscript.
  * Is possible to create specific and general subscripts for a same thrid-party repository. Both will be executed.

#####  Subscript commands considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by [commonVariables.sh][commonVariables.sh] file.
  * This script must be non-interactive, that means, no echo to monitor, no read from keyboard, no wait confirmation.

### Author notes
Any contribution to this project would be appreciated.  
I hope you find it useful.

<!-- References -->
[commonFunctions.sh]:./common/commonFunctions.sh
[commonVariables.sh]:./common/commonVariables.sh
[dialogFunctions.sh]:./menu/dialogFunctions.sh
[menuFunctions.sh]:./menu/menuFunctions.sh
[menuVariables.sh]:./menu/menuVariables.sh
[zenityFunctions.sh]:./menu/zenityFunctions.sh
[applicationList.debian]:./applist/applicationList.debian
[applicationList.linuxmint]:./applist/applicationList.linuxmint
[applicationList.lmde]:./applist/applicationList.lmde
[applicationList.ubuntu]:./applist/applicationList.ubuntu
[installer.sh]:./installer.sh
[en.properties]:./languages/en.properties
[es.properties]:./languages/es.properties
[template-pre-installation.sh]:./pre-installation/template-pre-installation.sh
[template-post-installation.sh]:./post-installation/template-post-installation.sh
[template-eula]:./eula/template-eula
[template-non-repo-app.sh]:./non-repository-apps/template-non-repo-app.sh
[template-script.sh]:./scripts/template-script.sh
[template-repository.sh]:./third-party-repo/template-repository.sh
[screenshot-desktop-mainmenu1]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-desktop-1.3-01.png
[screenshot-desktop-internetapp]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-desktop-1.3-02.png
[screenshot-desktop-mainmenu2]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-desktop-1.3-03.png
[screenshot-terminal-mainmenu1]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-terminal-1.3-01.png
[screenshot-terminal-internetapp]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-terminal-1.3-02.png
[screenshot-terminal-mainmenu2]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-terminal-1.3-03.png
[ISO639]:http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[tux bricoleur]:https://nowhere.dk/wp-content/uploads/2010/03/lilitux-tux-bricoleur.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
