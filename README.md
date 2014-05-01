App-installer
=============

Advanced scripts to install applications from default repositories, third-party repositories or external sources on any Ubuntu system (desktop or server).

![Main menu screenshot through Zenity box for desktop system][screenshot zenity]

![Main menu screenshot through Dailog box for terminal system][screenshot dialog]

**Index**
> 1. [Features](#Features)
> 2. [Installation](#Installation)  
> 2.1. [Method 1. Clone this repository](#Clone_this_repository)  
> 2.2. [Method 2. Download and extract files](#Download_files)
> 3. [Execution](#Execution)  
> 3.1 [Main script](#Exec_main_script)  
> 3.2 [Application script](#Exec_app_script)
> 4. [Installation's lifecycle](#Lifecycle)
> 5. [Extend script functionallity and customize applications to install](#Extend_functionallity)  
> 5.1 [Understanding project structure](#Understanding_project_structure)  
> 5.2 [Add new category. Modify or delete an existing one](#Add_new_application)  
> 5.3 [Add new application to a category. Modify or delete an existing one](#Add_new_script)  
> 5.4 [Add new separate application script](#Add_new_repository)  
> 5.5 [Add new third-party repository](#Add_new_non_repo_application)  
> 5.6 [Add new non-repository application script](#Add_new_config_script)  
> 5.7 [Add new application's config script](#Add_new_config_script)  
> 5.8 [Add new EULA config script for an application](#Add_new_eula_script)


Tested on: Ubuntu desktops 14.04 and Ubuntu Server 14.04.  
It should be executed without problems on previous Ubuntu versions with minor changes in config files.  
Version: 1.0 beta  
Last modified date: 04/29/2014  
TODO: Test compatibility with Debian 7. Bug fixes.

<a name="Features"/>
### 1. Features
* One main script that shows a menu of aplications to be installed and then install the selected ones.
* Alternatively, there is one separate script for each application, so it can be installed just running the appropiate script.
* Install official repository applications.
* Add third-party repositories and install related applications when needed.
* Download, extract and install non-repository applications through custom subscripts that extend the main script functionallity.
* Set up applications after they are installed through custom subscripts.
* Customize your own application list to install and third party repositories to add just editing some config files (no need to edit main script at all for this purpose).
* EULA support. Install applications automatically with no need of user interaction to accept legal terms of the application.
* The script runs with an interface adapted to the detected enviroment: Dialog for terminal. Zenity for desktop or terminal emulator.
* Installation log file that shows installation steps and errors if they happened
* Multilingual support. Easy to add new translations. At the moment: english and spanish languages are included. The script detect system language and it use the appropiate translation.

<a name="Installation"/>

### 2. Installation
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
<a name="Execution"/>
### 3. Execution
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
<a name="Lifecycle"/>
### 4. Installation's lifecycle
1. The user must select the applications to install.
2. The script adds third-party repositories of the selected third-party applications, if this is the case.
3. The script installs all the selected repository applications with EULA support if required.
4. The script executes custom subscripts to install the selected non-repository applications.
5. The script executes custom subscripts to setup selected applications.
6. The script run final operations to finish installation process and to clean temporal files.
7. The script shows an installation log file which contains installation steps and errors if they happened

Main script run all the previous steps while separate application scripts skip step 1 and run the rest.

<a name="Extend_functionallity"/>
### 5. Extend script functionallity and customize applications to install
To extend script functionallity is required to add subscripts for custom purposes. To customize applications to install is necessary to edit some config files. This actions will be detailed in next chapters.

<a name="Understanding_project_structure"/>
#### 5.1 Understanding project structure
Under construction ...  
![][under construction]

<!--
<a name="Add_new_actegory"/>
#### Add new category. Modify or delete an existing one.

<a name="Add_new_application"/>
#### Add new application to a category. Modify or delete an existing one.

<a name="Add_new_script"/>
#### Add new separate application script.

<a name="Add_new_repository"/>
#### Add new third-party repository.

<a name="Add_new_non_repo_application"/>
#### Add new non-repository application script.

<a name="Add_new_config_script"/>
#### Add new application's config script.

<a name="Add_new_eula_script"/>
#### Add new EULA config script for an application.
-->

<!-- References -->
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
[screenshot dialog]:http://cesar-rgon.github.io/app-installer/images/screenshots/screenshot-dialog.jpg
[screenshot zenity]:http://cesar-rgon.github.io/app-installer/images/screenshots/screenshot-zenity.jpg

