Linux app installer
===================
Menú de instalación de aplicaciones desde los repositorios por defecto, de terceros o fuentes externas en cualquier sistema Ubuntu 14.04, Debian 7, Linux Mint 17 o LMDE (escritorio o servidor). Hay un listado por defecto que incluye muchas aplicaciones, pero dicho listado puede ser modificado por el usuario tan sólo editando un fichero de texto. Además, los usuarios pueden añadir subscripts que extiendan la funcionalidad del menú, por ejemplo, añadir nuevos repositorios, configurar aplicaciones, etc. Por otro lado, existe un script individual por cada aplicación como modo alternativo de realizar el proceso de instalación sin el menú principal. 

![Main menu screenshot through Zenity box for desktop system][screenshot zenity]

![Main menu screenshot through Dailog box for terminal system][screenshot dialog]

##### Índice
> 1. [Características](#1-características)
> 2. [Instalando este proyecto](#2-instalando-este-proyecto)  
>   - [Método 1. Clonar este repositorio](#21-método-1-clonar-este-repositorio)  
>   - [Método 2. Descargar y extraer ficheros](#22-método-2-descargar-y-extraer-ficheros)
> 3. [Ejecutando un script](#3-ejecutando-un-script)  
>   - [Script principal](#31-script-principal)  
>   - [Script de aplicación](#32-script-de-aplicacion)
> 4. [Ciclo de vida de ejecución](#4-ciclo-de-vida-de-ejecución)
> 5. [Extender funcionalidad y personalizar aplicaciones a instalar](#5-extender-funcionalidad-y-personalizar-aplicaciones-a-instalar)  
>   - [Entendiendo la estructura del proyecto](#51-entendiendo-la-estructura-del-proyecto)  
>   - [Añadir nueva aplicación a una categoría. Modificar o borrar una existente](#52-añadir-nueva-aplicación-a-una-categoría-modificar-o-borrar-una-existente)  
>   - [Añadir nuevo subscript para instalar una aplicación](#53-añadir-nuevo-subscript-para-instalar-una-aplicación)  
>   - [Añadir nuevo subscript para agregar un repositorio de tercero](#54-añadir-nuevo-subscript-para-agregar-un-repositorio-de-tercero)  
>   - [Añadir nuevo subscript para preparar la instalación de una aplicación](#55-añadir-nuevo-subscript-para-preparar-la-instalación-de-una-aplicación)
>   - [Añadir nuevo subscript para instalar una aplicación externa a repositorios](#56-añadir-nuevo-subscript-para-instalar-una-aplicación-externa-a-repositorios)  
>   - [Añadir nuevo subscript para configurar una aplicación](#57-añadir-nuevo-subscript-para-configurar-una-aplicación)  
>   - [Añadir nuevo subscript para configurar el soporte EULA](#58-añadir-nuevo-subscript-para-configurar-el-soporte-eula)
> 6. [Añadir nuevo fichero de traducción](#6-añadir-nuevo-fichero-de-traducción)

```
Válido para:   Ubuntu v14.04, Debian 7, Linux Mint 17 y LMDE (para todos los escritorios y servidor).
               Con algunos cambios en ficheros de configuración, puede ser 100% compatible con versiones previas.
Versión:       1.2
Último cambio: 23/05/2014 (dd/mm/yyyy)
```
##### HECHO
> - [x] Añadido compatibilidad con Ubuntu 14.04 (unity/gnome/kde/xfce/lxde/server)
> - [x] Añadido compatibilidad con Debian 7
> - [x] Añadido compatibilidad con Linux Mint 17 (cinnamon/mate)
> - [x] Añadido compatibilidad con LMDE (cinnamon/mate)

##### POR HACER
> - [ ] Desarrollar página web en Github

---
[En construcción][under construction]

### 1. Características
* One main script that shows a menu of aplications wich can be selected for installation.
* Alternatively, there is one separate script for each application, so it can be installed by just executing the appropriate script.
* Install official repository applications.
* Add third-party repositories and install related applications when needed.
* Download, extract and install non-repository applications through custom subscripts that extend the main script functionality. It includes several subscripts by default.
* Set up applications after they are installed through custom subscripts.
* Customize your own application list to install and third party repositories to add by just editing some config files (no need to edit main script at all for this purpose).
* EULA support. Install applications automatically with no need of user interaction to accept legal terms of the application.
* The script runs with an interface adapted to the detected enviroment: Dialog for terminal. Zenity for desktop or terminal emulator.
* Installation log file that shows installation steps and errors if they have occurred.
* Multilingual support. Easy to add new translations. For the time being English and Spanish languages are included. The script detects system language and it use the appropiate translation.  

---
[Regresar al índice](#índice)

### 2. Instalando este proyecto

#### 2.1 Método 1. Clonar este repositorio
```bash
$ sudo apt-get install git
$ git clone -b master https://github.com/cesar-rgon/linux-app-installer.git
$ cd linux-app-installer
```

#### 2.2 Método 2. Descargar y extraer ficheros
```bash
$ wget https://github.com/cesar-rgon/linux-app-installer/archive/master.tar.gz
$ tar -xvf master.tar.gz
$ cd linux-app-installer-master
```

---
[Regresar al índice](#índice)

### 3. Ejecutando un script

#### 3.1 Script principal
It shows a menu of applications to be installed which are ordered by categories. The user navigates through categories and selects the applications to be installed. After that, installation process begins.
```bash
$ bash installer.sh
```
#### 3.2 Script de aplicación
There is one separate script for each application, so it can be installed just by running the appropriate script.
```bash
$ bash ./scripts/applicationName.sh
```

---
[Regresar al índice](#índice)

### 4. Ciclo de vida de ejecución
1. The user must select the applications to install.
2. The script would add third-party repositories of the selected third-party applications, when required.
3. The script executes custom subscripts to prepare the installation of some applications.
4. The script installs all the selected repository applications with EULA support if required.
5. The script executes custom subscripts to install the selected non-repository applications.
6. The script executes custom subscripts to setup selected applications.
7. The script runs final operations to finish installation process and to clean temporal files.
8. The script shows an installation log file which contains installation steps and errors if they have occurred.

Main script runs all the previous steps, whereas individual application scripts skip step 1 and run the remaining.

---
[Regresar al índice](#índice)

### 5. Extender funcionalidad y personalizar aplicaciones a instalar
To extend script functionality is required to add subscripts for custom purposes. To customize applications to install, it's necessary to edit some config files. These actions will be detailed in next chapters.

#### 5.1 Entendiendo la estructura del proyecto
Tree of folders and some files:
```
├── common                  It contains common functions and variables used by installation scripts
│   ├── commonFunctions.sh
│   ├── commonVariables.sh
│   ├── menuFunctions.sh
│   └── *
│
├── etc                     It contains application list and some config files used by subscripts
│   ├── applicationList.debian
│   ├── applicationList.linuxmint
│   ├── applicationList.lmde
│   ├── applicationList.ubuntu
│   └── *
│
├── eula                    It contains files who set parameters to skip questions during installation's process
│   ├── template-eula
│   └── *
│
├── icons                   It contains sets of application icons used by subscripts
│   ├── *
│   └── installer           It contains icons used by installation scripts
│       └── *
├── installer.sh
│
├── languages               It contains language translations used by installation scripts
│   ├── en.properties
│   └── es.properties
│
├── non-repository-apps     It contains subscripts to install non-repository applications
│   ├── template-non-repo-app.sh
│   ├── *                   Subscripts used on any linux system
│   ├── debian              Subscripts only used on a Debian system
│   │   └── *
│   ├── linuxmint           Subscripts only used on a Linux Mint system
│   │   └── *
│   ├── lmde                Subscripts only used on a LMDE system
│   │   └── *
│   └── ubuntu              Subscripts only used on an Ubuntu system
│       └── *
│
├── post-installation       It contains subscripts to setup applications after installation
│   ├── template-post-installation.sh
│   ├── *                   Subscripts used on any linux system
│   ├── debian              Subscripts only used on a Debian system
│   │   └── *
│   ├── linuxmint           Subscripts only used on a Linux Mint system
│   │   └── *
│   ├── lmde                Subscripts only used on a LMDE system
│   │   └── *
│   └── ubuntu              Subscripts only used on an Ubuntu system
│       └── *
│
├── pre-installation       It contains subscripts to prepare the installation of some applications
│   ├── template-pre-installation.sh
│   ├── *                   Subscripts used on any linux system
│   ├── debian              Subscripts only used on a Debian system
│   │   └── *
│   ├── linuxmint           Subscripts only used on a Linux Mint system
│   │   └── *
│   ├── lmde                Subscripts only used on a LMDE system
│   │   └── *
│   └── ubuntu              Subscripts only used on an Ubuntu system
│       └── *
├── README.md
│
├── scripts                 It contains one installation script per application
│   ├── template-script.sh
│   └── *.sh
│
└── third-party-repo        It contains subscripts to add third-party repositories for some applications
    ├── template-repository.sh
    ├── *                   Subscripts used on any linux system
    ├── debian              Subscripts only used on a Debian system
    │   └── *
    ├── keys                It contains key files used by third-party repository's subscripts
    │   └── *
    ├── linuxmint           Subscripts only used on a Linux Mint system
    │   └── *
    ├── lmde                Subscripts only used on a LMDE system
    │   └── *
    └── ubuntu              Subscripts only used on an Ubuntu system
        └── *
```

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

[Regresar al índice](#índice)

#### 5.2 Añadir nueva aplicación a una categoría. Modificar o borrar una existente
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
  * ApplicationNameDescription is composed by: _ApplicationName_ word: must be identical (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file. _Description_ word: must always follow the category name word.
  * To be intuitive, ApplicationNameDescription should be defined in the 'APPLICATIONS' section of the file.
  * It's recommended, but not mandatory, to add those descriptions to other translation files.
  * You can create a new translation file in your native language to be easier for your understanding. See chapter [Add new translation file](#6-add-new-translation-file) for more information.

To modify or delete an application or category just edit [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file and change the corresponding lines.

---
[Regresar al índice](#índice)

#### 5.3 Añadir nuevo subscript para instalar una aplicación
To add a new installation script for an application follow next steps:

1. Create a new file './scripts/application-name.sh' taking, as base, next commands from [template-script.sh][template-script.sh] file
  ```bash
  #!/bin/bash
  scriptRootFolder=`pwd`/..
  . $scriptRootFolder/common/commonFunctions.sh
  appName=""  # Here goes application name. It must be identically (case-sensitive) to the application name defined in ../etc/applicationList.ubuntu or ../etc/applicationList.debian file.
  logFile=""  # Here goes log file name that will be created in ~/logs/logFile

  prepareScript "$scriptRootFolder" "$logFile"
  installAndSetupApplications $appName
  ```

2. Modify content to asign values to variables: _appName_ and _logFile_  
  Considerations:
  * appName value must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * logFile value is used to create the log file ~/logs/logFile.

---
[Regresar al índice](#índice)

#### 5.4 Añadir nuevo subscript para agregar un repositorio de tercero
To add a new subscript to add a third-party repository for an application follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-repository.sh][template-repository.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./third-party-repo_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./third-party-repo/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./third-party-repo/debian_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./third-party-repo_ folder.

2. Add neccessary commands at the end of the file to add the repository  
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.
  * If commands need to use a key file, it should be placed in [keys][keys] folder.

---
[Regresar al índice](#índice)

#### 5.5 Añadir nuevo subscript para preparar la instalación de una aplicación
To add a new subscript to prepare the installation of an application before the installation proccess begins just follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-pre-installation.sh][template-pre-installation.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./pre-installation_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./pre-installation/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./pre-installation/debian_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./pre-installation_ folder.

2. Add neccessary commands at the end of the file to setup the application
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.

---
[Regresar al índice](#índice)

#### 5.6 Añadir nuevo subscript para instalar una aplicación externa a repositorios
To add a new subscript to install a non-repository application just follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-non-repo-app.sh][template-non-repo-app.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./non-repository-apps_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./non-repository-apps/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./non-repository-apps/debian_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./non-repository-apps_ folder.

2. Add neccessary commands at the end of the file to download and install the non-repository application
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.

---
[Regresar al índice](#índice)

#### 5.7 Añadir nuevo subscript para configurar una aplicación
To add a new subscript to setup an application after installation proccess just follow next steps:

1. Create a new file 'applicationName.sh' taking, as base, the [template-post-installation.sh][template-post-installation.sh] file.

  Considerations:
  * The filename must be identically (case-sensitive) to the application name defined in [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] file.
  * If the script is valid for all linux distros, it must be placed in _./post-installation_ folder.
  * If the script is only valid for Ubuntu distros, it must be placed in _./post-installation/ubuntu_ folder.
  * If the script is only valid for Debian distros, it must be placed in _./post-installation/debian_ folder.
  * The scripts placed within the specific distro folders have more preference over the scripts placed in _./post-installation_ folder.

2. Add neccessary commands at the end of the file to setup the application
  Considerations:
  * No need to use 'sudo' in commands because the subscript will be executed as root user.
  * Use common variables supplied by main script as needed.
  * This script must be non-interactive, this means, no echo to monitor, no read from keyboard, no wait confirmation.

---
[Regresar al índice](#índice)

#### 5.8 Añadir nuevo subscript para configurar el soporte EULA
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
[Regresar al índice](#índice)

### 6. Añadir nuevo fichero de traducción
To add a new translation file for a specific language just follow next steps:

1. Create a new file "./languages/xx.properties" with the content of an existing translation file, for example, [en.properties][en.properties]
  Considerations:
  * 'xx' must consist of two lowercase characters based on [ISO639-1 code][ISO639] for the specific language.

2. Translate values of all variables to the specific language.  
  Considerations:
  * The variable names must not be changed at all.

---
[Regresar al índice](#índice)

### Notas del autor
Any contribution to this project would be appreciated.  
I hope you find it useful.

<!-- Referencias -->
[commonFunctions.sh]:./common/commonFunctions.sh
[commonVariables.sh]:./common/commonVariables.sh
[menuFunctions.sh]:./common/menuFunctions.sh
[applicationList.debian]:./etc/applicationList.debian
[applicationList.linuxmint]:./etc/applicationList.linuxmint
[applicationList.lmde]:./etc/applicationList.lmde
[applicationList.ubuntu]:./etc/applicationList.ubuntu
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
[screenshot dialog]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/screenshot-dialog.jpg
[screenshot zenity]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/screenshot-zenity.jpg
[ISO639]:http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[tux bricoleur]:https://nowhere.dk/wp-content/uploads/2010/03/lilitux-tux-bricoleur.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
