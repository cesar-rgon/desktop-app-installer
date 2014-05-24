Linux app installer
===================
Menú de instalación de aplicaciones desde los repositorios por defecto, de terceros o fuentes externas en cualquier sistema Ubuntu 14.04, Debian 7, Linux Mint 17 o LMDE (escritorio o servidor). Hay un listado por defecto que incluye muchas aplicaciones, pero dicho listado puede ser modificado por el usuario tan sólo editando un fichero de texto. Además, los usuarios pueden añadir subscripts que extiendan la funcionalidad del menú, por ejemplo, añadir nuevos repositorios, configurar aplicaciones, etc. Por otro lado, existe un script individual por cada aplicación como modo alternativo de realizar el proceso de instalación sin el menú principal. 

![Captura de pantalla del menú usando Zenity para escritorio][screenshot zenity]

![Captura de pantalla del menú usando Dailog para terminal][screenshot dialog]

##### Indice
> 1. [Características](#1-características)
> 2. [Instalando este proyecto](#2-instalando-este-proyecto)  
>   - [Método 1. Clonar este repositorio](#21-método-1-clonar-este-repositorio)  
>   - [Método 2. Descargar y extraer ficheros](#22-método-2-descargar-y-extraer-ficheros)
> 3. [Ejecutando un script](#3-ejecutando-un-script)  
>   - [Script principal](#31-script-principal)  
>   - [Script de aplicación](#32-script-de-aplicación)
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
> - [x] Añadida compatibilidad con Ubuntu 14.04 (unity/gnome/kde/xfce/lxde/server)
> - [x] Añadida compatibilidad con Debian 7
> - [x] Añadida compatibilidad con Linux Mint 17 (cinnamon/mate)
> - [x] Añadida compatibilidad con LMDE (cinnamon/mate)

##### POR HACER
> - [ ] Desarrollar página web en Github

---

### 1. Características
* Un script principal que muestra un menú de aplicaciones a ser seleccionado para instalación.
* Alternativamente, hay un script individual por cada aplicación que se encarga de instalar dicha aplicación.
* Instala aplicaciones de repositorios oficiales.
* Añade repositorios de terceros e instala las aplicaciones relacionadas cuando sea necesario.
* Descarga, extrae e instala aplicaciones externas a repositorios mediante subscripts propios que extienden la funcionalidad del script principal. Se incluyen varios por defecto.
* Configura aplicaciones después de que sean instaladas mediante subscripts propios. Se incluyen varios por defecto.
* Personaliza tu propia lista de aplicaciones a instalar y repositorios de terceros a agregar editando algunos ficheros de configuración (no hay necesidad de editar el script principal para este propósito).
* Soporte EULA. Instala aplicaciones automáticamente sin necesidad de interacción del usuario para aceptar acuerdos legales de la aplicación.
* El script se ejecuta con una interfaz adaptada al entorno detectado: Dialog para terminal. Zenity para escritorio o emulador de terminal.
* Fichero de log que muestra los pasos de instalación y posibles errores si ocurrieran.
* Soporte multilenguaje. Es sencillo añadir un nuevo idioma. Por el momento están incluidos Inglés y Español. El script detecta el idioma del sistema y usa la traducción apropiada.

---
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

### 3. Ejecutando un script

#### 3.1 Script principal
Muestra un menú de aplicaciones a ser instaladas que están ordenadas por categorías. El usuario navega a través de las categorías y selecciona las aplicaciones a ser instaladas. Después de esto, el proceso de instalación comienza.
```bash
$ bash installer.sh
```
#### 3.2 Script de aplicación
Existe un script individual por cada aplicación, de forma que, puede ser instalada ejecutando dicho script.
```bash
$ bash ./scripts/applicationName.sh
```

---
[Regresar al índice](#indice)

### 4. Ciclo de vida de ejecución
1. El usuario debe seleccionar las aplicaciones a instalar.
2. El script añade los repositorios de terceros de las aplicaciones de terceros seleccionadas, cuando sea requerido.
3. El script ejecuta subscripts propios para preparar la instalación de algunas aplicaciones.
4. El script instala todas las aplicaciones de repositorios seleccionadas con soporte EULA si es requerido.
5. El script ejecuta subscripts propios para instalar las aplicaciones externas a repositorios.
6. El script ejecuta subscripts propios para configurar las aplicaciones seleccionadas.
7. El script ejecuta operaciones finales para terminal el proceso de instalación y limpiar ficheros temporales.
8. El script muestra un fichero de log que contiene los pasos de instalación y posibles errores si ocurrieran.

El script principal ejecuta todos los pasos previos, mientras que los scripts individuales omiten el paso 1 y ejecutan el resto.

---
[Regresar al índice](#indice)

### 5. Extender funcionalidad y personalizar aplicaciones a instalar
Para extender la funcionalidad del script principal es necesario añadir subscripts para tareas concretas. Para personalizar la lista de aplicaciones a instalar, es necesario editar varios ficheros de configuración. Estas acciones serán detalladas en los siguientes capítulos.

#### 5.1 Entendiendo la estructura del proyecto
Árbol de directorios y algunos ficheros:
```
├── common                  Contiene funciones comúnes y variables usadas por los scripts de instalación
│   ├── commonFunctions.sh
│   ├── commonVariables.sh
│   ├── menuFunctions.sh
│   └── *
│
├── etc                     Contiene lista de aplicaciones y algunos ficheros de configuración usados por subscripts
│   ├── applicationList.debian
│   ├── applicationList.linuxmint
│   ├── applicationList.lmde
│   ├── applicationList.ubuntu
│   └── *
│
├── eula                    Contiene ficheros que inicializan parámetros para saltar preguntas durante el proceso de instalación
│   ├── template-eula
│   └── *
│
├── icons                   Contiene conjuntos de iconos de aplicaciones usados por subscripts
│   ├── *
│   └── installer           Contiene iconos usados por los scripts de instalación
│       └── *
├── installer.sh
│
├── languages               Contiene ficheros de traducción usados por los scripts de instalación
│   ├── en.properties
│   └── es.properties
│
├── non-repository-apps     Contiene subscripts para instalar aplicaciones externas a repositorios
│   ├── template-non-repo-app.sh
│   ├── *                   Subscripts usados en cualquier sistema linux
│   ├── debian              Subscripts usados sólamente en sistemas Debian
│   │   └── *
│   ├── linuxmint           Subscripts usados sólamente en sistemas Linux Mint
│   │   └── *
│   ├── lmde                Subscripts usados sólamente en sistemas LMDE
│   │   └── *
│   └── ubuntu              Subscripts usados sólamente en sistemas Ubuntu
│       └── *
│
├── post-installation       Contiene subscripts para configurar aplicaciones después de la instalación
│   ├── template-post-installation.sh
│   ├── *                   Subscripts usados en cualquier sistema linux
│   ├── debian              Subscripts usados sólamente en sistemas Debian
│   │   └── *
│   ├── linuxmint           Subscripts usados sólamente en sistemas Linux Mint
│   │   └── *
│   ├── lmde                Subscripts usados sólamente en sistemas LMDE
│   │   └── *
│   └── ubuntu              Subscripts usados sólamente en sistemas Ubuntu
│       └── *
│
├── pre-installation        Contiene subscripts para preparar la instalación de algunas aplicaciones
│   ├── template-pre-installation.sh
│   ├── *                   Subscripts usados en cualquier sistema linux
│   ├── debian              Subscripts usados sólamente en sistemas Debian
│   │   └── *
│   ├── linuxmint           Subscripts usados sólamente en sistemas Linux Mint
│   │   └── *
│   ├── lmde                Subscripts usados sólamente en sistemas LMDE
│   │   └── *
│   └── ubuntu              Subscripts usados sólamente en sistemas Ubuntu
│       └── *
├── README.md
│
├── scripts                 Contiene un script de instalación por aplicación
│   ├── template-script.sh
│   └── *.sh
│
└── third-party-repo        Contiene subscripts que añaden repositorios de terceros para algunas aplicaciones
    ├── template-repository.sh
    ├── *                   Subscripts usados en cualquier sistema linux
    ├── debian              Subscripts usados sólamente en sistemas Debian
    │   └── *
    ├── keys                Contiene ficheros de clave usados por subscripts de repositorios de terceros
    │   └── *
    ├── linuxmint           Subscripts usados sólamente en sistemas Linux Mint
    │   └── *
    ├── lmde                Subscripts usados sólamente en sistemas LMDE
    │   └── *
    └── ubuntu              Subscripts usados sólamente en sistemas Ubuntu
        └── *
```

| Algunos ficheros importantes                                   | Descripción                                                                                          |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [commonFunctions.sh][commonFunctions.sh]                       | Contiene funciones comunes usados por todos los scripts de instalación                               |
| [commonVariables.sh][commonVariables.sh]                       | Contiene variables comunes disponibles para todos los subscripts                                     |
| [menuFunctions.sh][menuFunctions.sh]                           | Contiene funciones del menú. Usado sólamente por el script principal                                 |
| [applicationList.debian][applicationList.debian]               | Define categorías, aplicaciones y paquetes usados por el script principal para un sistema Debian     |
| [applicationList.linuxmint][applicationList.linuxmint]         | Define categorías, aplicaciones y paquetes usados por el script principal para un sistema Linux Mint |
| [applicationList.lmde][applicationList.lmde]                   | Define categorías, aplicaciones y paquetes usados por el script principal para un sistema LMDE       |
| [applicationList.ubuntu][applicationList.ubuntu]               | Define categorías, aplicaciones y paquetes usados por el script principal para un sistema Ubuntu     |
| [installer.sh][installer.sh]                                   | Fichero del script principal                                                                         |
| [en.properties][en.properties]                                 | Fichero de traducción Inglesa                                                                        |
| [es.properties][es.properties]                                 | Fichero de traducción Español                                                                        |
| [template-script.sh][template-script.sh]                       | Plantilla para ayudar a crear un nuevo script para instalar una aplicación                           |
| [template-repository.sh][template-repository.sh]               | Plantilla para ayudar a crear un nuevo subscript para añadir un repositorio de tercero               |
| [template-pre-installation.sh][template-pre-installation.sh]   | Plantilla para ayudar a crear un nuevo subscript con comandos de pre-instalación de una aplicación   |
| [template-eula][template-eula]                                 | Plantilla para ayudar a crear un nuevo subscript para configurar soporte EULA para un paquete        |
| [template-non-repo-app.sh][template-non-repo-app.sh]           | Plantilla para ayudar a crear un nuevo subscript para instalar una aplicación externa a repositorios |
| [template-post-installation.sh][template-post-installation.sh] | Plantilla para ayudar a crear un nuevo subscript con comandos de post-instalación de una aplicación  |

---

[Regresar al índice](#indice)

En construcción  
![En construcción][under construction]

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
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

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
[Regresar al índice](#indice)

### 6. Añadir nuevo fichero de traducción
To add a new translation file for a specific language just follow next steps:

1. Create a new file "./languages/xx.properties" with the content of an existing translation file, for example, [en.properties][en.properties]
  Considerations:
  * 'xx' must consist of two lowercase characters based on [ISO639-1 code][ISO639] for the specific language.

2. Translate values of all variables to the specific language.  
  Considerations:
  * The variable names must not be changed at all.

---
[Regresar al índice](#indice)

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
[ISO639]:http://es.wikipedia.org/wiki/ISO_639-1
[tux bricoleur]:https://nowhere.dk/wp-content/uploads/2010/03/lilitux-tux-bricoleur.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
