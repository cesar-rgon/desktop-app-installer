Linux app installer
===================
Menu to install applications from default repositories, third-party ones or external sources on any Ubuntu 16.04, Debian 8, Linux Mint 18 or LMDE system (desktop or server). There are a lot of applications included in the default list, but this list can be modified by the user by just editing a single text file. Furthermore, users can add subscripts to extend main menu functionality, for example, add new repositories, setup applications, etc. In addition, exist one separate script for each application as an alternative way to do the installation proccess without the main menu.

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
Last change: 07/28/2016 (mm/dd/yyyy)
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

##### Menú principal del instalador (modo Escritorio/Terminal)
> ![Captura pantalla menú principal modo escritorio][screenshot-desktop-mainmenu1]
> ![Captura pantalla menú principal modo terminal][screenshot-terminal-mainmenu1]


##### Categoría Internet del instalador (modo Escrotorio/Terminal)
> ![Captura de pantalla menú categoría internet modo escritorio][screenshot-desktop-internetapp]
> ![Captura de pantalla menú categoría internet modo terminal][screenshot-terminal-internetapp]


##### Menú principal del instalador tras selección programas (modo Escritorio/Terminal)
> ![Captura pantalla menú principal con programas seleccionados modo escritorio][screenshot-desktop-mainmenu2]
> ![Captura pantalla menú principal con programas seleccionados modo terminal][screenshot-terminal-mainmenu2]


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
│   ├── installapp.sh
│   └── menuFunctions.sh
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
------ CHECKED TO HERE :) ------

| Some important files                                           | Description                                                                                  |
| -------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [commonFunctions.sh][commonFunctions.sh]                       | It contains common functions used by all the installation scripts                            |
| [commonVariables.sh][commonVariables.sh]                       | It contains common variables available for all subscripts                                    |
| [menuFunctions.sh][menuFunctions.sh]                           | It contains menu functions. Used only by main script                                         |
| [applicationList.debian][applicationList.debian]               | It defines categories, applications and packages used by main script for a Debian system     |
| [applicationList.linuxmint][applicationList.linuxmint]         | It defines categories, applications and packages used by main script for a Linux Mint system |
| [applicationList.lmde][applicationList.lmde]                   | It defines categories, applications and packages used by main script for a LMDE system       |
| [applicationList.ubuntu][applicationList.ubuntu]               | It defines categories, applications and packages used by main script for an Ubuntu system    |
| [installer.sh][installer.sh]                                   | Main script file                                                                             |
| [en.properties][en.properties]                                 | English translation file                                                                     |
| [es.properties][es.properties]                                 | Spanish translation file                                                                     |
| [template-script.sh][template-script.sh]                       | Template file to help to create new script file to install an application                    |
| [template-repository.sh][template-repository.sh]               | Template file to help to create new subscript to add a third-party repository                |
| [template-pre-installation.sh][template-pre-installation.sh]   | Template file to help to create new application subscript to run pre-installation commands   |
| [template-eula][template-eula]                                 | Template file to help to create new subscript to setup EULA support for a package            |
| [template-non-repo-app.sh][template-non-repo-app.sh]           | Template file to help to create new subscript to install a non-repository application        |
| [template-post-installation.sh][template-post-installation.sh] | Template file to help to create new application subscript to run post-installation commands  |

---

[Back to index](#index)

#### 5.2 Add new application to a category. Modify or delete an existing one
To add an application to be installed follow next steps:

1. Edit [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file and add a new line with the next syntax:

| 1st column - Category (*)  | 2nd column - Application Name (*) | Other columns (Packages) |
| -------------------------- | --------------------------------- | ------------------------ |
| Existing/New_category_name | Application_name                  | repository package(s)    |

  Considerations:
  * Blank or comment lines are ignored in this file.
  * First column - Category: is mandatory.
  * Category name is repeated once per application contained in it.
  * If the category name is new in the file, the script will generate a new window for this category.
  * Each category should contain at least one application.
  * The category name shall contain only letters, digits and/or underscores '_' and it can't start with a digit.
  * Second column - Application name: is mandatory.
  * Just one row per application.
  * The application name shall contain only letters, digits and/or underscores '_' and it can't start with a digit.
  * The application source can be official repositories, third-party repositories even other sources (non-repositories).
  * The order in which applications are listed in the menu is the same as set in this file.
  * Third column - Packages: is mandatory only if the application belongs to a repository.
  * Packages must be separated by whitespaces.
  * Non-repository applications must leave this field empty.

2. Edit [en.properties][en.properties] file and add a description for categories (if it's new) and applications with the next syntax:
  CategoryNameDescription=Here goes the category description that is used by the main menu  
  ApplicationNameDescription=Here goes the application description that is used by the main menu

  Considerations:
  * CategoryNameDescription is composed by _CategoryName_ word: must be identical (case-sensitive) to the category name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file. _Description_ word: must always follow the category name word.
  * To be intuitive, CategoryNameDescription should be defined in the 'CATEGORIES' section of the file.
  * ApplicationNameDescription is composed by: _ApplicationName_ word: must be identical (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file. _Description_ word: must always follow the application name word.
  * To be intuitive, ApplicationNameDescription should be defined in the 'APPLICATIONS' section of the file.
  * It's recommended, but not mandatory, to add those descriptions to other translation files.
  * You can create a new translation file in your native language to be easier for your understanding. See chapter [Add new translation file](#6-add-new-translation-file) for more information.

To modify or delete an application or category just edit [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file and change the corresponding lines.

---
[Back to index](#index)

#### 5.3 Add new subscript to install an application
To add a new installation script for an application follow next steps:

1. Create a new file './scripts/application-name.sh' taking, as base, next commands from [template-script.sh][template-script.sh] file
  ```bash
  #!/bin/bash
  scriptRootFolder=`pwd`/..
  . $scriptRootFolder/common/commonFunctions.sh
  appName=""  # Here goes application name. It must be identically (case-sensitive) to the application name defined in ../applist/applicationList.<distro> file.
  logFile=""  # Here goes log file name that will be created in ~/logs/logFile

  prepareScript "$scriptRootFolder" "$logFile"
  installAndSetupApplications $appName
  ```

2. Modify content to asign values to variables: _appName_ and _logFile_  
  Considerations:
  * appName value must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * logFile value is used to create the log file ~/logs/logFile.

---
[Back to index](#index)

#### 5.4 Add new subscript to add third-party repository
To add a new subscript to add a third-party repository for an application follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-repository.sh][template-repository.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./third-party-repo_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./third-party-repo/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./third-party-repo/debian_ folder.
  * If the script is only valid for Linux Mint distros, it must be placed in _./third-party-repo/linuxmint_ folder.
  * If the script is only valid for LMDE distros, it must be placed in _./third-party-repo/lmde_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./third-party-repo_ folder.

2. Add neccessary commands at the end of the file to add the repository  
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.
  * If commands need to use a key file, it should be placed in [keys][keys] folder.

---
[Back to index](#index)

#### 5.5 Add new subscript to prepare the installation of an application
To add a new subscript to prepare the installation of an application before the installation proccess begins just follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-pre-installation.sh][template-pre-installation.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./pre-installation_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./pre-installation/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./pre-installation/debian_ folder.
  * If the script is only valid for Linux Mint distros, it must be placed in _./third-party-repo/linuxmint_ folder.
  * If the script is only valid for LMDE distros, it must be placed in _./third-party-repo/lmde_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./pre-installation_ folder.

2. Add neccessary commands at the end of the file to setup the application
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.

---
[Back to index](#index)

#### 5.6 Add new subscript to install a non-repository application
To add a new subscript to install a non-repository application just follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-non-repo-app.sh][template-non-repo-app.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./non-repository-apps_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./non-repository-apps/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./non-repository-apps/debian_ folder.
  * If the script is only valid for Linux Mint distros, it must be placed in _./third-party-repo/linuxmint_ folder.
  * If the script is only valid for LMDE distros, it must be placed in _./third-party-repo/lmde_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./non-repository-apps_ folder.

2. Add neccessary commands at the end of the file to download and install the non-repository application
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.

---
[Back to index](#index)

#### 5.7 Add new subscript to setup an application
To add a new subscript to setup an application after installation proccess just follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-post-installation.sh][template-post-installation.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./post-installation_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./post-installation/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./post-installation/debian_ folder.
  * If the script is only valid for Linux Mint distros, it must be placed in _./third-party-repo/linuxmint_ folder.
  * If the script is only valid for LMDE distros, it must be placed in _./third-party-repo/lmde_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./post-installation_ folder.

2. Add neccessary commands at the end of the file to setup the application
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.

---
[Back to index](#index)

#### 5.8 Add new subscript to setup EULA support
To add a new subscript to setup EULA support for a package just follow next steps:

1. Create a new file './eula/packageName' taking, as base, next commands from [template-eula][template-eula] file.
  ```bash
  ##########################################################################
  # This file contains debconf's parameters to avoid interactive
  # installation of the package to confirm EULA.
  #
  # Format: <package> <module>/<parameter> <command> <value>.
  # See man debconf or debconf-set-selections for more information.
  ##########################################################################

  # ...
  ```
  Considerations:
  * The filename must be identically (case-sensitive) to the related application package defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.

2. Add parameters at the end of the file with the syntax indicated in template file to skip EULA questions during installation proccess.

---
[Back to index](#index)

### 6. Add new translation file
To add a new translation file for a specific language just follow next steps:

1. Create a new file './languages/xx.properties' with the content of an existing translation file, for example, [en.properties][en.properties]
  Considerations:
  * 'xx' must consist of two lowercase characters based on [ISO639-1 code][ISO639] for the specific language.

2. Translate values of all variables to the specific language.  
  Considerations:
  * The variable names must not be changed at all.

---
[Back to index](#index)

### Author notes
Any contribution to this project would be appreciated.  
I hope you find it useful.

<!-- References -->
[commonFunctions.sh]:./common/commonFunctions.sh
[commonVariables.sh]:./common/commonVariables.sh
[menuFunctions.sh]:./common/menuFunctions.sh
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
[keys]:./third-party-repo/keys
[screenshot-desktop-mainmenu1]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-desktop-1.3-01.png
[screenshot-desktop-internetapp]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-desktop-1.3-02.png
[screenshot-desktop-mainmenu2]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-desktop-1.3-03.png
[screenshot-terminal-mainmenu1]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-terminal-1.3-01.png
[screenshot-terminal-internetapp]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-terminal-1.3-02.png
[screenshot-terminal-mainmenu2]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/en/screenshot-terminal-1.3-03.png
[ISO639]:http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[tux bricoleur]:https://nowhere.dk/wp-content/uploads/2010/03/lilitux-tux-bricoleur.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
