App-installer
=============
Advanced scripts to install applications from default repositories, third-party repositories or external sources on any Ubuntu system (desktop or server).

![Main menu screenshot through Zenity box for desktop system][screenshot zenity]

![Main menu screenshot through Dailog box for terminal system][screenshot dialog]

<a name="index"/>
**Index**
> 1. [Features](#Features)
> 2. [Installing this project](#Installation)  
> 2.1. [Method 1. Clone this repository](#Clone_this_repository)  
> 2.2. [Method 2. Download and extract files](#Download_files)
> 3. [Executing a script](#Execution)  
> 3.1 [Main script](#Exec_main_script)  
> 3.2 [Application script](#Exec_app_script)
> 4. [Execution's lifecycle](#Lifecycle)
> 5. [Extend script functionallity and customize applications to install](#Extend_functionallity)  
> 5.1 [Understanding project structure](#Understanding_project_structure)  
> 5.2 [Add new application to a category. Modify or delete an existing one](#Add_new_script)  
> 5.3 [Add new separate application script](#Add_new_repository)  
> 5.4 [Add new third-party repository](#Add_new_non_repo_application)  
> 5.5 [Add new non-repository application script](#Add_new_config_script)  
> 5.6 [Add new application's config script](#Add_new_config_script)  
> 5.7 [Add new EULA config script for an application](#Add_new_eula_script)

```
Valid for:   Ubuntu desktops and server 14.04.
             With some changes in config files, it can be 100% compatible with previous versions.
Version:     1.0 beta  
Last change: 04/29/2014  
```
**Task List**:
> - [x] Test compatibility with Xubuntu 14.04
> - [x] Test compatibility with Ubuntu server 14.04
> - [ ] Test compatibility with Ubuntu 14.04
> - [ ] Test compatibility with Ubuntu Gnome 14.04
> - [ ] Test compatibility with Kubuntu 14.04
> - [ ] Test compatibility with Lubuntu 14.04
> - [ ] Test compatibility with Debian 7

---
<a name="Features"/>
### 1. Features
* One main script that shows a menu of aplications wich can be selected for installation.
* Alternatively, there is one separate script for each application, so it can be installed just executing the appropiate script.
* Install official repository applications.
* Add third-party repositories and install related applications when needed.
* Download, extract and install non-repository applications through custom subscripts that extend the main script functionallity. It includes several subscripts by default.
* Set up applications after they are installed through custom subscripts.
* Customize your own application list to install and third party repositories to add just editing some config files (no need to edit main script at all for this purpose).
* EULA support. Install applications automatically with no need of user interaction to accept legal terms of the application.
* The script runs with an interface adapted to the detected enviroment: Dialog for terminal. Zenity for desktop or terminal emulator.
* Installation log file that shows installation steps and errors if they happened
* Multilingual support. Easy to add new translations. At the moment: english and spanish languages are included. The script detect system language and it use the appropiate translation.  

---  
<a name="Installation"/>
### 2. Installing this project
<a name="Clone_this_repository"/>
#### 2.1 Method 1. Clone this repository
```bash
$ sudo apt-get install git
$ git clone -b master https://github.com/cesar-rgon/app-installer.git
$ cd app-installer
```

<a name="Download_files"/>
#### 2.2 Method 2. Download and extract files
```bash
$ wget https://github.com/cesar-rgon/app-installer/archive/master.tar.gz
$ tar -xvf master.tar.gz
$ cd app-installer-master
```
[Back to index](#index)

---
<a name="Execution"/>
### 3. Executing a script
<a name="Exec_main_script"/>
#### 3.1 Main script
It shows a menu of aplications to be installed ordered by categories. The user navigates through categories and selects the applications to be installed. After that, installation process begins.
```bash
$ bash installer.sh
```
<a name="Exec_app_script"/>
#### 3.2 Application script
There is one separate script for each application, so it can be installed just running the appropiate script.
```bash
$ bash ./scripts/applicationName.sh
```
[Back to index](#index)

---
<a name="Lifecycle"/>
### 4. Execution's lifecycle
1. The user must select the applications to install.
2. The script adds third-party repositories of the selected third-party applications, if this is the case.
3. The script installs all the selected repository applications with EULA support if required.
4. The script executes custom subscripts to install the selected non-repository applications.
5. The script executes custom subscripts to setup selected applications.
6. The script run final operations to finish installation process and to clean temporal files.
7. The script shows an installation log file which contains installation steps and errors if they happened

Main script run all the previous steps while separate application scripts skip step 1 and run the rest.

[Back to index](#index)

---
<a name="Extend_functionallity"/>
### 5. Extend functionallity and customize applications to install
To extend script functionallity is required to add subscripts for custom purposes. To customize applications to install is necessary to edit some config files. This actions will be detailed in next chapters.

<a name="Understanding_project_structure"/>
#### 5.1 Understanding project structure
Tree of folders and files:
```
├── common
│   ├── askpass.sh
│   ├── commonFunctions
│   ├── commonVariables
│   └── menuFunctions
├── config-apps
│   └── ...
├── etc
│   ├── applicationList
│   └── ...
├── eula
│   └── ...
├── icons
│   └── ...
├── installer.sh
├── languages
│   ├── en.properties
│   └── es.properties
├── non-repository-apps
│   └── ...
├── README.md
├── scripts
│   └── ...
└── third-party-repo
    ├── ...
    └── keys
        └── ...
```

| Folders                                          | Description                                                                                     | 
| ------------------------------------------------ | ----------------------------------------------------------------------------------------------- |
| [common](./common)                               | It contains common functions and variables used by installation scripts                         |
| [config-apps](./config-apps)                     | It contains subscripts to setup applications after install                                      |
| [etc](./etc)                                     | It contains application list and miscelanea files used by config subscripts                     |
| [eula](./eula)                                   | It contains text files who set parameters to skip EULA questions during installation's proccess |
| [icons](./icons)                                 | It contains sets of application icons used by subscripts                                        |
| [languages](./languages)                         | It contains language translations used by installation scripts                                  |
| [non-repository-apps](./non-repository-apps)     | It contains subscripts to install non-repository applications                                   |
| [scripts](./scripts)                             | It contains one installation script by each application                                         |
| [third-party-repo](./third-party-repo)           | It contains subscripts to add third-party repository for some applications                      |
| [third-party-repo/keys](./third-party-repo/keys) | It contains key files used by third-party repository's subscripts                               |

| Important files                                        | Description                                                                       |
| ------------------------------------------------------ | --------------------------------------------------------------------------------- |
| [installer.sh](./installer.sh)                         | Main script file                                                                  |
| [./etc/applicationList](./etc/applicationList)         | Text file which defines categories, applications and packages used by main script |
| [./languages/en.properties](./languages/en.properties) | English translation file                                                          |
| [./languages/es.properties](./languages/es.properties) | Spanish translation file                                                          |

<a name="Add_new_application"/>
#### 5.2 Add new application to a category. Modify or delete an existing one.
To add an application to be installed follow next steps:

1. Edit [applicationList](./etc/applicationList) file and add a new line with the next syntax:

  | First column - Category (*)  | Second column - Application Name (*) | Other columns (Packages) |
  | ---------------------------- | ------------------------------------ | ------------------------ |
  | Existing/New_category_name   | Application_name                     | repository package(s)    |

  Considerations:
  * First column - Category: is mandatory.
  * If the category name is new in file, the script will generate a new window for this category.
  * Each category should contain at least one application.
  * The category name shall contain only letters, digits and/or underscore '_' and do not begin with a digit.
  * Second column - Application name: is mandatory.
  * The application name shall contain only letters, digits and/or underscore '_' and do not begin with a digit.
  * The application source can be official repositories, third-party repository even other source (non-repository).
  * The order in which applications are listed in menu is the same as set in this file.
  * Third column - Packages: is mandatory only if the application belongs to a repository.
  * Packages must be separated by whitespaces.
  * Non-repository applications must leave this field empty.


Under construction ...  
![][under construction]

<!--


<a name="Add_new_script"/>
#### 5.3 Add new separate application script.

<a name="Add_new_repository"/>
#### 5.4 Add new third-party repository.

<a name="Add_new_non_repo_application"/>
#### 5.5 Add new non-repository application script.

<a name="Add_new_config_script"/>
#### 5.6 Add new application's config script.

<a name="Add_new_eula_script"/>
#### 5.7 Add new EULA config script for an application.
-->
[Back to index](#index)

<!-- References 
[tux bricoleur]:https://nowhere.dk/wp-content/uploads/2010/03/lilitux-tux-bricoleur.png
-->
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
[screenshot dialog]:http://cesar-rgon.github.io/app-installer/images/screenshots/screenshot-dialog.jpg
[screenshot zenity]:http://cesar-rgon.github.io/app-installer/images/screenshots/screenshot-zenity.jpg
