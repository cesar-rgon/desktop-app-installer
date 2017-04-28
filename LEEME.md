$ Desktop && app installer script
=================================

| Menú de instalación de escritorios y aplicaciones de repositorios oficiales, terceros o fuentes externas para Ubuntu, Debian, Linux Mint, LMDE o Raspbian (escritorio o servidor).| ![Logo][tux-shell-terminal-logo] |
| --- | --- |

Hay muchas aplicaciones y escritorios incluidos en el listado de aplicaciones por defecto, dicho listado listado puede ser modificado por el usuario tan sólo editando un simple fichero de texto. Además, el usuario puede añadir subscripts que extiendan la funcionalidad del menú, por ejemplo, añadir nuevos repositorios, configurar aplicaciones, etc. Por otro lado, existe un script individual por cada aplicación como modo alternativo de realizar el proceso de instalación sin el menú principal.

> _Versión inglesa disponible [aquí][readme.md] ( English version can be found [here][readme.md] )_

> _Página web del script disponible [aquí](http://cesar-rgon.github.io/desktop-app-installer-website/)_

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
>   - [Añadir nuevo subscript para preparar la instalación de una aplicación](#53-añadir-nuevo-subscript-para-preparar-la-instalación-de-una-aplicación)
<   - [Añadir un nuevo fichero para agregar repositorio de tercero mediante PPA](#54-añadir-un-nuevo-fichero-para-agregar-repositorio-de-tercero-mediante-ppa)
>   - [Añadir nuevo subscript para instalar una aplicación](#55-añadir-nuevo-subscript-para-instalar-una-aplicación)  
>   - [Añadir nuevo subscript para instalar una aplicación externa a repositorios](#56-añadir-nuevo-subscript-para-instalar-una-aplicación-externa-a-repositorios)  
>   - [Añadir nuevo subscript para configurar una aplicación](#57-añadir-nuevo-subscript-para-configurar-una-aplicación)  
>   - [Añadir nuevo subscript para configurar el soporte EULA](#58-añadir-nuevo-subscript-para-configurar-el-soporte-eula)
>   - [Añadir credenciales de autenticación por defecto a una aplicación](#59-añadir-credenciales-de-autenticación-por-defecto-a-una-aplicación)
> 6. [Añadir nuevo fichero de traducción](#6-añadir-nuevo-fichero-de-traducción)
> 7. [Añadir nuevo subscript para eliminar ficheros de configuración de una aplicación durante el proceso de desinstalación](#7-añadir-nuevo-subscript-para-eliminar-ficheros-de-configuración-de-una-aplicación-durante-el-proceso-de-desinstalación)
> 8. ANEXO
>   - [Consideraciones del fichero subscript](#consideraciones-del-fichero-subscript)
>   - [Consideraciones de comandos en fichero subscript](#consideraciones-de-comandos-en-fichero-subscript)

```
Probado en:    Ubuntu 16.04 LTS Xenial, Debian 8 Jessie, Linux Mint 18.1 Serena, LMDE 2 Betsy o Raspbian Jessie (escritorio o servidor).
               Con algunos cambios en ficheros de configuración, puede ser 100% compatible con versiones previas.
Versión:       1.3.3
Último cambio: 26/04/2017 (dd/mm/yyyy)
```

### 1. Características
* Un script principal que muestra un menú de aplicaciones o escritorios linux a seleccionar para instalación.
* Alternativamente, hay un script individual por cada aplicación que se encarga de instalar la misma.
* Instala aplicaciones de repositorios oficiales y repositorios de terceros. En este último caso agrega los repositorios necesarios.
* Descarga, extrae e instala aplicaciones de fuentes externas a los repositorios mediante subscripts personalizados que extienden la funcionalidad del script principal. Se incluyen varios por defecto.
* Configura aplicaciones después de ser instaladas mediante subscripts específicos. Se incluyen varios por defecto.
* Personaliza tu propia lista de aplicaciones a instalar y repositorios de terceros a agregar editando algunos ficheros de configuración (no hay necesidad de editar el script principal para este propósito).
* Los repositorios de terceros añadidos por algunas aplicaciones serán desactivados automáticamente tras la instalación de las mismas.
* Soporte EULA. Instala aplicaciones automáticamente sin necesidad de interacción del usuario para aceptar acuerdos legales de la aplicación.
* El script se ejecuta con una interfaz adaptada al entorno detectado: Dialog para terminal. Yad o Zenity para escritorio o emulador de terminal.
* Posibilidad de establecer las credenciales de autenticación para aquellas aplicaciones que requieran inicio de sesión de usuario.
* Fichero de log que muestra los pasos de instalación y posibles errores si ocurrieran.
* Soporte multilenguaje. Es sencillo añadir un nuevo idioma. Por el momento están incluidos Inglés y Español. El script detecta el idioma del sistema y usa la traducción apropiada.
* Válido para multiples arquitecturas: x64, i386, arm.

---
[Regresar al índice](#indice)

### 2. Instalando este proyecto

#### 2.1 Método 1. Clonar este repositorio
```bash
$ sudo apt install git
$ git clone https://github.com/cesar-rgon/desktop-app-installer.git
$ cd desktop-app-installer
```

#### 2.2 Método 2. Descargar y extraer ficheros
```bash
$ wget https://github.com/cesar-rgon/desktop-app-installer/archive/master.tar.gz
$ tar -xvf master.tar.gz
$ cd desktop-app-installer-master
```

---
[Regresar al índice](#indice)

### 3. Ejecutando un script

#### 3.1 Script principal
Muestra un menú de aplicaciones a ser instaladas que están ordenadas por categorías. El usuario navega a través de las categorías y selecciona las aplicaciones a ser instaladas. Además tiene la posibilidad de editar una categoría para modificar la lista de aplicaciones seleccionadas a instalar. Tras esto, el proceso de instalación comenzará cuando el usuario lo especifique.
```bash
$ bash installer.sh
```
##### Menú principal. Diferencia entre ambos modos
> ![Captura pantalla de modos escritorio|terminal][screenshot-monitores]

##### Categoría Internet del instalador (modo Escrotorio/Terminal)
> ![Captura de pantalla menú categoría internet modo escritorio][screenshot-desktop-internetapp]
> ![Captura de pantalla menú categoría internet modo terminal][screenshot-terminal-internetapp]

##### Menú principal tras selección programas (modo Escritorio/Terminal)
> ![Captura pantalla menú principal con programas seleccionados modo escritorio][screenshot-desktop-mainmenu]
> ![Captura pantalla menú principal con programas seleccionados modo terminal][screenshot-terminal-mainmenu]

##### Cambio de credenciales de autenticación (modo Escritorio/Terminal)
> ![Captura pantalla cambio de credenciales de autenticación modo escritorio][screenshot-desktop-credentials]
> ![Captura pantalla cambio de credenciales de autenticación modo terminal][screenshot-terminal-credentials]

##### Instalando aplicaciones (modo Escritorio/Terminal)
> ![Captura pantalla instalando una aplicación en modo escritorio][screenshot-desktop-installing-app]
> ![Captura pantalla instalando una aplicación en modo terminal][screenshot-terminal-installing-app]

##### Log
> ![Captura pantalla visor de log en modo escritorio][screenshot-desktop-log]

#### 3.2 Script de aplicación
Existe un script individual por cada aplicación, de forma que, puede ser instalada ejecutando dicho script.
```bash
$ bash ./app-scripts/applicationName.sh
```

---
[Regresar al índice](#indice)

### 4. Ciclo de vida de ejecución
1. El usuario debe SELECCIONAR las APLICACIONES a instalar.

2. El usuario puede ESTABLECER las CREDENCIALES DE AUTENTICACIÓN para aquellas aplicaciones que requieran inicio de sesión de usuario.

3. El usuario SOLICITA INICIAR el proceso de INSTALACIÓN.

4. El script EJECUTA OPERACIONES INICIALES para preparar la instalación de las aplicaciones seleccionadas.

5. Por cada aplicación, ejecuta los siguientes pasos:
  * El script AGREGA un REPOSITORIO DE TERCERO mediante PPA, si es definido por fichero.
  * El script EJECUTA OPERACIONES de PRE-INSTALACIÓN de la aplicación a ser instalada si existe un sub-script específico para este propósito. El sub-script podría añadir un repositorio de tercero, mediante comandos propios en lugar de uso de PPA, y/o preparar la instalación de la aplicación.
  * El script INSTALA la APLICACIÓN, con soporte EULA, tomando como fuente los repositorios oficiales, de terceros o bien un sub-script propio creado para tal propósito.
  * El script DESACTIVA automáticamente el REPOSITORIO de TERCERO de la aplicación instalada para evitar posibles problemas derivados de esto.
  * El script EJECUTA OPERACIONES de POST-INSTALACION para configurar la aplicación instalada si existe un sub-script propio para este propósito.
  * El script ALMACENA CREDENCIALES de AUTENTICACION a la aplicación, si esta lo requiere.

6. El script EJECUTA OPERACIONES FINALES para limpiar paquetes, eliminar ficheros/carpetas temporales, mostrar logs y credenciales de login.

```
NOTA 1: El script principal ejecuta todos los pasos previos mientras que los scripts indididuales por aplicación omiten el primer paso.

NOTA 2: El script actualiza automáticamente los repositorios tras las operaciones de pre-instalación, añadir repositorio de tercero o desactivar el mismo.

NOTA 3: Los logs generados durante el proceso de instalación contiene los pasos seguidos y posibles errores ocurridos.

NOTA 4: Las credenciales de login son usadas por aquellas aplicaciones instaladas que requieren autenticación de usuario.
```

---
[Regresar al índice](#indice)

### 5. Extender funcionalidad y personalizar aplicaciones a instalar
Para extender la funcionalidad del script principal es necesario añadir subscripts para tareas concretas. Para personalizar la lista de aplicaciones a instalar, es necesario editar varios ficheros de configuración. Estas acciones serán detalladas en los siguientes capítulos.

#### 5.1 Entendiendo la estructura del proyecto
Árbol de directorios y algunos ficheros:
```
├── app-scripts             Contiene un script de instalación por aplicación
│   ├── template-script.sh
│   └── *.sh
│
├── common                  Contiene funciones comúnes, variables comunes y comandos usados por los scripts de instalación
│   ├── commonFunctions.sh
│   ├── commonVariables.properties
│   ├── installapp.sh
│   └── *.sh
│
├── etc                     Contiene ficheros de configuración usados por subscripts y el número de version del script principal
│   ├── systemd.service
│   ├── version
│   │
│   ├── applist             Contiene listado de aplicaciones disponibles para instalar en cada distribucion linux soportada
│   │   ├── applicationList-debian.csv
│   │   ├── applicationList-linuxmint.csv
│   │   ├── applicationList-lmde.csv
│   │   ├── applicationList-raspbian.csv
│   │   └── applicationList-ubuntu.csv
│   │
│   ├── credentials         Contiene un fichero por aplicacion con nombre-usuario/contraseña requerido para autenticación
│   │   ├── template-credentials.properties
│   │   └── *.properties
│   │
│   ├── eula                Evita preguntas de aceptacion de terminos de uso de algunas aplicaciones durante el proceso de instalacion
│   │   ├── template-eula
│   │   └── *
│   │
│   ├── languages           Contiene ficheros de traducción usados por los scripts de instalación
│   │   ├── en.properties
│   │   ├── es.properties
│   │   └── *.properties
│   │
│   ├── old-init.d          Contiene scripts basados en init.d. Usado por algunos demonios (para compatibilidad con LMDE 2)
│   │   └── *
│   │
│   ├── ppa                 Contiene un fichero por aplicación que contiene PPA a ser añadido antes de la instalación
│   │   └── *
│   │
│   └── *
│
├── icons                   Contiene un conjunto de iconos de aplicaciones usado por algunos subscripts
│   ├── *
│   └── installer/*         Contiene iconos usados por los scripts de instalación
│
├── installer.sh            Fichero que inicia el script principal de instalacion
│
├── install-non-repo-apps   Contiene subscripts para instalar aplicaciones externas a repositorios
│   ├── template-non-repo-app.sh
│   ├── *.sh                Subscripts usados en cualquier sistema linux
│   ├── debian/*.sh         Subscripts usados sólamente en sistemas Debian
│   ├── linuxmint/*.sh      Subscripts usados sólamente en sistemas Linux Mint
│   ├── lmde/*.sh           Subscripts usados sólamente en sistemas LMDE
│   ├── raspbian/*.sh       Subscripts usados sólamente en sistemas Raspbian
│   └── ubuntu/*.sh         Subscripts usados sólamente en sistemas Ubuntu
│
├── menu                    Contiene funciones usados por el menú del script principal (Terminal / Escritorio)
│   ├── dialogFuntions.sh
│   ├── menuFunctions.sh
│   ├── menuVariables.properties
│   ├── yadFunctions.sh
│   └── zenityFunctions.sh
│
│
├── post-installation       Contiene subscripts para configurar aplicaciones después de la instalación
│   ├── template-post-installation.sh
│   ├── *.sh                Subscripts usados en cualquier sistema linux
│   ├── debian/*.sh         Subscripts usados sólamente en sistemas Debian
│   ├── linuxmint/*.sh      Subscripts usados sólamente en sistemas Linux Mint
│   ├── lmde/*.sh           Subscripts usados sólamente en sistemas LMDE
│   ├── raspbian/*.sh       Subscripts usados sólamente en sistemas Raspbian
│   └── ubuntu/*.sh         Subscripts usados sólamente en sistemas Ubuntu
│
└── pre-installation        Contiene subscripts para añadir repositorio de tercero y/o preparar instalación de aplicaciones
    ├── template-pre-installation.sh
    ├── *.sh                Subscripts usados en cualquier sistema linux
    ├── debian/*.sh         Subscripts usados sólamente en sistemas Debian
    ├── linuxmint/*.sh      Subscripts usados sólamente en sistemas Linux Mint
    ├── lmde/*.sh           Subscripts usados sólamente en sistemas LMDE
    ├── raspbian/*.sh       Subscripts usados sólamente en sistemas Raspbian
    └── ubuntu/*.sh         Subscripts usados sólamente en sistemas Ubuntu
```

| Algunos ficheros importantes                                   | Descripción                                                                                          |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [commonFunctions.sh][commonFunctions.sh]                       | Contiene funciones comunes usados por todos los scripts de instalación                               |
| [commonVariables.properties][commonVariables.properties]       | Contiene variables comunes disponibles para todos los scripts                                        |
| [installapp.sh][installapp.sh]       | Contiene los comandos necesarios para la instalación de una aplicación y posible reparación en caso de fallo                                       |
| [dialogFunctions.sh][dialogFunctions.sh]                       | Contiene funciones del menú para cajas Dialog (modo terminal). Usado sólo por script principal       |
| [menuFunctions.sh][menuFunctions.sh]                           | Contiene funciones del menú. Usado sólamente por el script principal                                 |
| [menuVariables.properties][menuVariables.properties]           | Contiene variables globales del menú disponibles sólo para el script principal                       |
| [yadFunctions.sh][yadFunctions.sh]                             | Contiene funciones del menú para ventanas Yad (modo escritorio). Usado sólo por script principal  |
| [zenityFunctions.sh][zenityFunctions.sh]                       | Contiene funciones del menú para ventanas Zenity (modo escritorio). Usado sólo por script principal  |
| [applicationList-debian.csv][applicationList-debian.csv]               | Define categorías, aplicaciones y los paquetes correspondientes para un sistema Debian               |
| [applicationList-linuxmint.csv][applicationList-linuxmint.csv]         | Define categorías, aplicaciones y los paquetes correspondientes para un sistema Linux Mint           |
| [applicationList-lmde.csv][applicationList-lmde.csv]                   | Define categorías, aplicaciones y los paquetes correspondientes para un sistema LMDE                 |
| [applicationList-raspbian.csv][applicationList-raspbian.csv]           | Define categorías, aplicaciones y los paquetes correspondientes para un sistema Raspbian             |
| [applicationList-ubuntu.csv][applicationList-ubuntu.csv]               | Define categorías, aplicaciones y los paquetes correspondientes para un sistema Ubuntu               |
| [installer.sh][installer.sh]                                   | Fichero del script principal                                                                         |
| [en.properties][en.properties]                                 | Fichero de idioma inglés                                                                             |
| [es.properties][es.properties]                                 | Fichero de idioma español                                                                            |
| [template-script.sh][template-script.sh]                       | Plantilla para ayudar a crear un nuevo script para instalar una aplicación                           |
| [template-pre-installation.sh][template-pre-installation.sh]   | Plantilla para ayudar a crear un nuevo subscript que agrega repo-tercero y/o prepara instalación de aplicación   |
| [template-eula][template-eula]                                 | Plantilla para ayudar a crear un nuevo subscript para configurar soporte EULA para una aplicación        |
| [template-non-repo-app.sh][template-non-repo-app.sh]           | Plantilla para ayudar a crear un nuevo subscript para instalar una aplicación externa a repositorios |
| [template-post-installation.sh][template-post-installation.sh] | Plantilla para ayudar a crear un nuevo subscript con comandos de post-instalación de una aplicación  |
| [template-uninstall.sh][template-uninstall.sh]	         | Plantilla para ayudar a crear un nuevo subscript que elimine ficheros de configuración de una applicación   |
---

[Regresar al índice](#indice)

#### 5.2 Añadir nueva aplicación a una categoría. Modificar o borrar una existente
Para añadir una nueva aplicación a ser instalada, siga los siguientes pasos:

1. Editar fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv (se recomienda usar LibreOffice u Openoffice) y añadir una nueva línea con la siguiente sintaxis:

| 1ra columna - Categoría (*) | 2da columna - Aplicación (*) | 3ra columna - Paquetes    |
| ----------------------------| ---------------------------- | ------------------------- |
| NombreCategoria             | NombreAplicacion             | paquete1|paquete2|...     |

  Consideraciones:
  * Las líneas en blanco o de comentarios son ignoradas por el script.
  * La primera columna - Categoría: es obligatoria. Se repite en cada línea por aplicación correspondiente a dicha categoría.
  * Si el nombre de categoría es nuevo en este fichero, el script genera una nueva ventana para ésta.
  * Cada categoría debe contener al menos una aplicación.
  * El nombre de categoría debe contener sólo letras, dígitos y/o guión bajo '_' y no puede comenzar con un dígito.
  * La segunda columna - Nombre aplicación: es obligatoria.
  * Sólo debe haber una fila por aplicación.
  * El nombre de aplicación debe contener sólo letras, dígitos y/o guión bajo '_' y no puede comenzar con un dígito.
  * La fuente de la aplicación puede venir de repositorios oficiales, de terceros o incluso otras (sin repositorios).
  * El orden en la que se listan las aplicaciones en el menú es la misma que el especificado en este fichero.
  * La tercera columna - Paquetes: es obligatoria sólo si la aplicación proviene de un repositorio.
  * Los nombres de paquetes deben estar separados por el carácter espacio.
  * Las aplicaciones sin repositorio no deben especificar paquete alguno.

2. Editar fichero [es.properties][es.properties] y añadir una descripción para categorías (si hay nuevas) y aplicaciones con la siguiente sintaxis:
  NombreCategoriaDescription=Aquí va la descripción de la categoría tal y como se verá en el menú principal
  NombreAplicacionDescription=Aquí va la descripción de la aplicación tal y como se verá en el menú principal

  Consideraciones:
  * NombreCategoriaDescription está compuesta por la palabra _NombreCategoria_: debe ser idéntica (sensible a mayúsculas) a la especificada en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv. La palabra _Description_: debe continuar al nombre de categoría.
  * Para que sea intuitivo, es recomendable definir NombreCategoriaDescription en la sección 'CATEGORIAS' de este fichero.
  * NombreAplicacionDescription está compuesta por la palabra _NombreAplicacion_: debe ser idéntica (sensible a mayúsculas) a la especificada en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv. La palabra _Description_: debe continuar al nombre de aplicación.
  * Para que sea intuitivo, es recomendable definir NombreAplicacionDescription en la sección 'APLICACIONES' de este fichero.
  * Es recomendado, pero no obligatorio, añadir estas descripciones a otros ficheros de traducción.  
  * Puedes crear un nuevo fichero de traducción en tu idioma nativo para facilitar la comprensión. Vea el capítulo [Añadir nuevo fichero de traducción](#6-añadir-nuevo-fichero-de-traducción) para más información.

Para modificar o eliminar una aplicación o categoría, debe editar el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv y cambiar/borrar las líneas correspondientes.

---
[Regresar al índice](#indice)

#### 5.3 Añadir nuevo subscript para preparar la instalación de una aplicación
Para añadir un nuevo subscript que prepare una aplicación antes de que comience el proceso de instalación, siga los siguientes pasos:

1. Crear un nuevo fichero tomando como base la plantilla [template-pre-installation.sh][template-pre-installation.sh] teniendo en cuenta estas [consideraciones](#consideraciones-del-fichero-subscript).
2. Añadir los comandos necesarios al final del fichero para agregar un repositorio de tercero y/o preparar la instalación de la aplicación teniendo en cuenta estas [consideraciones](#consideraciones-de-comandos-en-fichero-subscript).

---
[Regresar al índice](#indice)

#### 5.4 Añadir un nuevo fichero para agregar repositorio de tercero mediante PPA
Para añadir un fichero que define PPA a ser usado para agregar repositorio de tercero para una aplicación siga los siguientes pasos:
1. Crear un nuevo fichero './etc/ppa/applicationName'
  Considerationes:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) a la aplicación correspondiente definida en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv.
  * El nombre de fichero no debe tener extensión.
2. El fichero debe contener sólamente uno y solo un PPA. Puede estar formado por:
  * Líneas en blanco [opcional]
  * '# Comentarios' [opcional]
  * ppa:/...  [obligatorio]

---
[Regresar al índice](#indice)

#### 5.5 Añadir nuevo subscript para instalar una aplicación
Para añadir un nuevo script de instalación de una aplicación siga los siguientes pasos:

1. Crear un nuevo fichero './app-scripts/nombre-aplicacion.sh' tomando como base los comandos definidos en la plantilla [template-script.sh][template-script.sh]

2. Modificar contenido para asignar valores a las variables: _appName_ y _logFile_  
  Consideraciones:
  * el valor de _appName_ debe ser idéntico (sensible a mayúsculas) al definido en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv.
  * el valor de _logFile_ es usado para crear el fichero ~/logs/logFile.

---
[Regresar al índice](#indice)

#### 5.6 Añadir nuevo subscript para instalar una aplicación externa a repositorios
Para añadir un nuevo subscript para instalar una aplicación externa a repositorios, siga los siguientes pasos:

1. Crear un nuevo fichero tomando como base la plantilla [template-non-repo-app.sh][template-non-repo-app.sh] teniendo en cuenta estas [consideraciones](#consideraciones-del-fichero-subscript).
2. Añadir los comandos necesarios al final del fichero para descargar e instalar la aplicación externa teniendo en cuenta estas [consideraciones](#consideraciones-de-comandos-en-fichero-subscript).

---
[Regresar al índice](#indice)

#### 5.7 Añadir nuevo subscript para configurar una aplicación
Para añadir un nuevo subscript que configure una aplicación después del proceso de instalación, siga los siguientes pasos:

1. Crear un nuevo fichero tomando como base la plantilla [template-post-installation.sh][template-post-installation.sh] teniendo en cuenta estas [consideraciones](#consideraciones-del-fichero-subscript).
2. Añadir comandos necesarios al final del fichero para configurar la aplicación teniendo en cuenta estas [consideraciones](#consideraciones-de-comandos-en-fichero-subscript).

---
[Regresar al índice](#indice)

#### 5.8 Añadir nuevo subscript para configurar el soporte EULA
Para añadir un nuevo subscript que configure el soporte EULA para una aplicación, siga los siguientes pasos:

1. Crear un nuevo fichero './etc/eula/nombreAplicacion' tomando como base los siguientes comandos de la plantilla [template-eula][template-eula].
  Consideraciones:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) a la aplicación correspondiente definida en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv.

2. Añadir parámetros al final del fichero con la sintaxis indicada en la plantilla para evitar las preguntas EULA durante el proceso de instalación.

---
[Regresar al índice](#indice)

#### 5.9 Añadir credenciales de autenticación por defecto a una aplicación
Para añadir credenciales de autenticación por defecto a una aplicación que requiere inicio de sesión de usuario, siga los siguientes pasos:

1. Crear un nuevo fichero './etc/credentials/nombreAplicacion.properties' tomando, como base, el fichero [template-credentials.properties][template-credentials.properties].
  Consideraciones:
  * El nombre de aplicaión debe ser idéntico (sensible a mayúsculas) a la aplicación correspondiente definida en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv.

2. Establecer valores de las variables appUsername, appPassword (credenciales) y usernameCanBeEdited, passwordCanBeEdited (que dice al script si el valor de la variable asociada puede ser modificada).

---
[Regresar al índice](#indice)

### 6. Añadir nuevo fichero de traducción
Para añadir un nuevo fichero de idioma, siga los siguientes pasos:

1. Crear un nuevo fichero './languages/xx.properties' copiando el contenido de un fichero de traducción existente, por ejemplo, [es.properties][es.properties]
  Consideraciones:
  * 'xx' debe ser dos caracteres minúsculas basado en [ISO639-1 code][ISO639] para el idioma concreto.

2. Traducir los valores de todas las variables al idioma concreto.
  Consideraciones:
  * Los nombres de variables no deben ser cambiados bajo ninguna circunstancia.

---
[Regresar al índice](#indice)

### 7. Añadir nuevo subscript para eliminar ficheros de configuración de una aplicación durante el proceso de desinstalación
Para definir un subscript que elimine la configuración de una aplicación instalada. siga los siguientes pasos:

1. Crear un nuevo fichero tomando, como base, el fichero [template-uninstall.sh][template-uninstall.sh] siguiendo las siguientes [consideraciones](#consideraciones-del-fichero-subscript).
2. Añadir comandos necesarios al final del fichero para eliminar ficheros de configuracion de la aplicación durante el proceso de desinstalación teniendo en cuenta estas [consideraciones](#consideraciones-de-comandos-en-fichero-subscript).
3. No hay necesidad de definir comandos para desinstalar la aplicación, sólo basta con eliminar configuración. El script principal la desinstalará automáticamente.
4. Sólo es válido para aplicaciones de repositorios, esto es, no es válido para aplicaciones de fuentes externas.

---
[Regresar al índice](#indice)

### ANEXO

##### Consideraciones del fichero subscript
  * El nombre de fichero debe seguir el siguiente patrón: NombreAplicacion[_i386/_x64]
    - NombreAplicacion: debe ser idéntico (sensible a mayúsculas) al nombre de aplicación definido en el fichero applicationList-[ubuntu][applicationList-ubuntu.csv]/[debian][applicationList-debian.csv]/[linuxmint][applicationList-linuxmint.csv]/[lmde][applicationList-lmde.csv]/[raspbian][applicationList-raspbian.csv].csv
	  - _i386 / _x64 / arm: Opcional si fuera necesario. Script que sólo debe ser ejecutado en la arquitectura correspondiente del S.O. (i386 para 32 bits; x64: para 64 bits; arm: para sistemas ARM).
    - La extensión debe ser siempre '.sh'
  * El subscript debe estar ubicado en la carpeta _./third-party-repo_ si es válido para todas las distros linux soportadas. Lo denominamos subscript general.
  * El subscript debe estar ubicado en la carpeta _./third-party-repo/ubuntu_, _./third-party-repo/debian_, _./third-party-repo/linuxmint_, _./third-party-repo/lmde_ si es válido sólo para una distro linux soportada. Lo denominamos subscript específico.
  * Es posible crear subscript específico y general para un mismo repositorio de tercero. Ambos serán ejecutados.  

##### Consideraciones de comandos en fichero subscript
  * No es necesario usar 'sudo' ya que el subscript será ejecutado como usuario administrador.
  * Se pueden usar las variables comunes definidas en el fichero [commonVariables.properties][commonVariables.properties].
  * Este script no debe ser interactivo, es decir, no enviar mensajes al monitor, ni leer de teclado, ni esperar confirmación alguna.  

---
[Regresar al índice](#indice)


### Notas del autor
Sería apreciada cualquier contribución a este proyecto.  
Espero que lo encontréis útil.

<!-- Referencias -->
[readme.md]:./README.md
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
[screenshot-monitores]:http://cesar-rgon.github.io/desktop-app-installer-website/images/monitores.png
[screenshot-desktop-internetapp]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/yad-02.png
[screenshot-terminal-internetapp]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/dialog-02.png
[screenshot-desktop-mainmenu]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/yad-03.png
[screenshot-terminal-mainmenu]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/dialog-03.png
[screenshot-desktop-credentials]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/yad-04.png
[screenshot-terminal-credentials]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/dialog-05.png
[screenshot-desktop-installing-app]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/yad-05.png
[screenshot-terminal-installing-app]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/dialog-06.png
[screenshot-desktop-log]:http://cesar-rgon.github.io/desktop-app-installer-website/images/screenshots/es/yad-07.png
[ISO639]:http://es.wikipedia.org/wiki/ISO_639-1
[tux-shell-terminal-logo]:http://cesar-rgon.github.io/desktop-app-installer-website/images/logos/desktop-app-installer.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
