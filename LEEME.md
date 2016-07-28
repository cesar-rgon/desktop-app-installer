Linux app installer
===================
Menú de instalación de aplicaciones desde los repositorios por defecto, de terceros o fuentes externas en cualquier sistema Ubuntu 16.04, Debian 8, Linux Mint 18 o LMDE (escritorio o servidor). Hay un listado por defecto que incluye muchas aplicaciones, pero dicho listado puede ser modificado por el usuario tan sólo editando un fichero de texto. Además, los usuarios pueden añadir subscripts que extiendan la funcionalidad del menú, por ejemplo, añadir nuevos repositorios, configurar aplicaciones, etc. Por otro lado, existe un script individual por cada aplicación como modo alternativo de realizar el proceso de instalación sin el menú principal. 

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
Válido para:   Ubuntu v16.04, Debian 8, Linux Mint 18 y LMDE (para todos los escritorios y servidor).
               Con algunos cambios en ficheros de configuración, puede ser 100% compatible con versiones previas.
Versión:       1.3
Último cambio: 28/07/2016 (dd/mm/yyyy)
```

### 1. Características
* Un script principal que muestra un menú de aplicaciones a ser seleccionado para instalación.
* Alternativamente, hay un script individual por cada aplicación que se encarga de instalar la misma.
* Instala aplicaciones de repositorios oficiales y repositorios de terceros. En este último caso agrega los repositorios necesarios.
* Descarga, extrae e instala aplicaciones sin repositorios mediante subscripts propios que extienden la funcionalidad del script principal. Se incluyen varios por defecto.
* Configura aplicaciones después de ser instaladas mediante subscripts específicos. Se incluyen varios por defecto.
* Personaliza tu propia lista de aplicaciones a instalar y repositorios de terceros a agregar editando algunos ficheros de configuración (no hay necesidad de editar el script principal para este propósito).
* Soporte EULA. Instala aplicaciones automáticamente sin necesidad de interacción del usuario para aceptar acuerdos legales de la aplicación. Desactivado por defecto.
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
Muestra un menú de aplicaciones a ser instaladas que están ordenadas por categorías. El usuario navega a través de las categorías y selecciona las aplicaciones a ser instaladas. Además tiene la posibilidad de editar una categoría para modificar la lista de aplicaciones seleccionadas a instalar. Tras esto, el proceso de instalación comenzará cuando el usuario lo especifique.
```bash
$ bash installer.sh
```

ESTO TENGO QUE ACTUALIZARLO A LA V1.3
![Captura de pantalla del menú usando Zenity para escritorio][screenshot zenity]
ESTO TENGO QUE ACTUALIZARLO A LA V1.3
![Captura de pantalla del menú usando Dailog para terminal][screenshot dialog]

#### 3.2 Script de aplicación
Existe un script individual por cada aplicación, de forma que, puede ser instalada ejecutando dicho script.
```bash
$ bash ./scripts/applicationName.sh
```

---
[Regresar al índice](#indice)

### 4. Ciclo de vida de ejecución
1. El usuario debe seleccionar las aplicaciones a instalar.
2. El script añade los repositorios externos requeridos por algunas de las aplicaciones seleccionadas.
3. El script ejecuta tareas previas a la instalación definidas en sub-scripts específicos que contienen los comandos necesarios para dejarlo todo listo.
4. El script instala las aplicaciones seleccionadas, con soporte EULA si fuera requerido, tomando como origen los repositorios oficiales de la distribución o repositorios de terceros.
5. El script instala aplicaciones ajenas a repositorios mediante la ejecución de subscripts específicos por aplicación.
6. El script configura algunas aplicaciones tras el proceso de instalación mediante la ejecución de subscripts específicos por aplicación.
7. El script ejecuta operaciones finales para terminal el proceso de instalación y limpiar ficheros temporales.
8. El script muestra un fichero de log que contiene los pasos de instalación y posibles errores si ocurrieran.

El script principal ejecuta todos los pasos previos, mientras que los scripts individuales omiten el paso uno y ejecutan el resto.

---
[Regresar al índice](#indice)

### 5. Extender funcionalidad y personalizar aplicaciones a instalar
Para extender la funcionalidad del script principal es necesario añadir subscripts para tareas concretas. Para personalizar la lista de aplicaciones a instalar, es necesario editar varios ficheros de configuración. Estas acciones serán detalladas en los siguientes capítulos.

#### 5.1 Entendiendo la estructura del proyecto
Árbol de directorios y algunos ficheros:
```
├── applist                 Contiene listado de aplicaciones disponibles para instalar en cada distribucion linux soportada
│   ├── applicationList.debian
│   ├── applicationList.linuxmint
│   ├── applicationList.lmde
│   └── applicationList.ubuntu
│
├── common                  Contiene funciones comúnes, variables comunes y comandos usados por los scripts de instalación
│   ├── commonFunctions.sh
│   ├── commonVariables.sh
│   ├── installapp.sh
│   └── menuFunctions.sh
│
├── etc                     Contiene ficheros de configuración usados por subscripts y el numero de version del script principal
│   ├── systemd.service
│   ├── version
│   └── *
│
├── eula                    Evita preguntas de aceptacion de terminos de uso de algunas aplicaciones durante el proceso de instalacion
│   ├── template-eula
│   └── *
│
├── icons                   Contiene un conjunto de iconos de aplicaciones usado por algunos subscripts
│   ├── *
│   └── installer/*         Contiene iconos usados por los scripts de instalación
│
├── installer.sh            Fichero que inicia el script principal de instalacion
│
├── languages               Contiene ficheros de traducción usados por los scripts de instalación
│   ├── en.properties
│   ├── es.properties
│   └── *
│
├── non-repository-apps     Contiene subscripts para instalar aplicaciones externas a repositorios
│   ├── template-non-repo-app.sh
│   ├── *                   Subscripts usados en cualquier sistema linux
│   ├── debian/*            Subscripts usados sólamente en sistemas Debian
│   ├── linuxmint/*         Subscripts usados sólamente en sistemas Linux Mint
│   ├── lmde/*              Subscripts usados sólamente en sistemas LMDE
│   └── ubuntu/*            Subscripts usados sólamente en sistemas Ubuntu
│
├── post-installation       Contiene subscripts para configurar aplicaciones después de la instalación
│   ├── template-post-installation.sh
│   ├── *                   Subscripts usados en cualquier sistema linux
│   ├── debian/*            Subscripts usados sólamente en sistemas Debian
│   ├── linuxmint/*         Subscripts usados sólamente en sistemas Linux Mint
│   ├── lmde/*              Subscripts usados sólamente en sistemas LMDE
│   └── ubuntu/*            Subscripts usados sólamente en sistemas Ubuntu
│
├── pre-installation        Contiene subscripts para preparar la instalación de algunas aplicaciones
│   ├── template-pre-installation.sh
│   ├── *                   Subscripts usados en cualquier sistema linux
│   ├── debian/*            Subscripts usados sólamente en sistemas Debian
│   ├── linuxmint/*         Subscripts usados sólamente en sistemas Linux Mint
│   ├── lmde/*              Subscripts usados sólamente en sistemas LMDE
│   └── ubuntu/*            Subscripts usados sólamente en sistemas Ubuntu
│
├── scripts                 Contiene un script de instalación por aplicación
│   ├── template-script.sh
│   └── *.sh
│
└── third-party-repo        Contiene subscripts que añaden repositorios de terceros para algunas aplicaciones
    ├── template-repository.sh
    ├── *                   Subscripts usados en cualquier sistema linux
    ├── debian/*            Subscripts usados sólamente en sistemas Debian
    ├── linuxmint/*         Subscripts usados sólamente en sistemas Linux Mint
    ├── lmde/*              Subscripts usados sólamente en sistemas LMDE
    └── ubuntu/*            Subscripts usados sólamente en sistemas Ubuntu
```
------ REVISADO HASTA AQUI :) ------

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

#### 5.2 Añadir nueva aplicación a una categoría. Modificar o borrar una existente
Para añadir una aplicación a ser instalada, siga los siguientes pasos:

1. Editar fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] o [applicationList.lmde][applicationList.lmde] y añadir una nueva línea con la siguiente sintaxis:

| 1ra columna - Categoría (*) | 2da columna - Aplicación (*) | Othas columnas - Paquetes |
| ----------------------------| ---------------------------- | ------------------------- |
| NombreCategoria             | NombreAplicacion             | paquete(s) de repositorio |

  Consideraciones:
  * Las líneas en blanco o de comentarios son ignoradas por el script.
  * La primera columna - Categoría: es obligatorioa.
  * El nombre de la categoría se repite una vez por aplicación contenida en ella.
  * Si el nombre de categoría es nuevo en este fichero, el script genera una nueva ventana para ésta.
  * Cada categoría debe contener al menos una aplicación.
  * El nombre de categoría debe contener sólo letras, dígitos y/o guión bajo '_' y no puede comenzar con un dígito.
  * La segunda columna - Nombre aplicación: es obligatoria.
  * Sólo debe haber una fila por aplicación.
  * El nombre de aplicación debe contener sólo letras, dígitos y/o guión bajo '_' y no puede comenzar con un dígito.
  * La fuente de la aplicación puede venir de repositorios oficiales, de terceros o incluso otras (sin repositorios).
  * El orden en la que se listan las aplicaciones en el menú es la misma que el especificado en este fichero.
  * Tercera columna en adelante - Paquetes: es obligatoria sólo si la aplicación proviene de un repositorio.
  * Los paquetes deben estar separados por espacios en blanco.
  * Las aplicaciones sin repositorio no deben especificar paquete alguno.

2. Editar fichero [es.properties][es.properties] y añadir una descripción para categorías (si hay nuevas) y aplicaciones con la siguiente sintaxis:
  NombreCategoriaDescription=Aquí va la descripción de la categoría tal y como se verá en el menú principal
  ApplicationNameDescription=Aquí va la descripción de la aplicación tal y como se verá en el menú principal

  Consideraciones:
  * NombreCategoriaDescription está compuesta por la palabra _NombreCategoria_: debe ser idéntica (sensible a mayúsculas) a la especificada en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] o [applicationList.lmde][applicationList.lmde]. La palabra _Description_: debe continuar al nombre de categoría.
  * Para que sea intuitivo, NombreCategoriaDescription debe ser definido en la sección 'CATEGORIAS' de este fichero.
  * NombreAplicacionDescription está compuesta por la palabra _NombreAplicacion_: debe ser idéntica (sensible a mayúsculas) a la especificada en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] o [applicationList.lmde][applicationList.lmde]. La palabra _Description_: debe continuar al nombre de aplicación.
  * Para que sea intuitivo, NombreAplicacionDescription debe ser definido en la sección 'APLICACIONES' de este fichero.
  * Es recomendado, pero no obligatorio, añadir estas descripciones a otros ficheros de traducción.  
  * Puede crear un nuevo fichero de traducción en tu idioma nativo para facilitar la comprensión. Vea el capítulo [Añadir nuevo fichero de traducción](#6-añadir-nuevo-fichero-de-traducción) para más información.

Para modificar o eliminar una aplicación o categoría, debe editar el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde] y cambiar las líneas correspondientes.

---
[Regresar al índice](#indice)

#### 5.3 Añadir nuevo subscript para instalar una aplicación
Para añadir un nuevo script de instalación de una aplicación siga los siguientes pasos:

1. Crear un nuevo fichero './scripts/nombre-aplicacion.sh' tomando como base los siguientes comandos de la plantilla [template-script.sh][template-script.sh]
  ```bash
  #!/bin/bash
  scriptRootFolder=`pwd`/..
  . $scriptRootFolder/common/commonFunctions.sh
  appName=""  # Aquí va el nombre de aplicación. Debe ser igual (sensible a mayúsculas) a la definida en el fichero ../applist/applicationList.<distro>
  logFile=""  # Aquí va el nombre del fichero de logs que será creado en ~/logs/logFile

  prepareScript "$scriptRootFolder" "$logFile"
  installAndSetupApplications $appName
  ```

2. Modificar contenido para asignar valores a las variables: _appName_ y _logFile_  
  Consideraciones:
  * el valor de _appName_ debe ser idéntico (sensible a mayúsculas) al definido en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] o [applicationList.lmde][applicationList.lmde].
  * el valor de _logFile_ es usado para crear el fichero ~/logs/logFile.

---
[Regresar al índice](#indice)

#### 5.4 Añadir nuevo subscript para agregar un repositorio de tercero
Para añadir un nuevo subscript que agregue un repositorio de terceros para una aplicación, siga los siguientes pasos:

1. Crear un nuevo fichero 'NombreAplicacion.sh' tomando como base la plantilla [template-repository.sh][template-repository.sh].
  Consideraciones:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) al nombre de aplicación definido en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde].
  * Si el script es válido para todas las distros linux, debe ser colocado en la carpeta _./third-party-repo_.
  * Si el script es válido sólo para distros Ubuntu, debe ser colocado en la carpeta _./third-party-repo/ubuntu_.
  * Si el script es válido sólo para distros Debian, debe ser colocado en la carpeta _./third-party-repo/debian_.
  * Si el script es válido sólo para distros Linux Mint, debe ser colocado en la carpeta _./third-party-repo/linuxmint_.
  * Si el script es válido sólo para distros LMDE, debe ser colocado en la carpeta _./third-party-repo/lmde_.
  * Los scripts ubicados en carpetas específicas de distribución tienen mayor prioridad frente a los scripts ubicados en la carpeta _./third-party-repo_.

2. Añadir los comandos necesarios al final del fichero para agregar el repositorio.
  Consideraciones:
  * No es necesario usar 'sudo' ya que el subscript será ejecutado como usuario administrador.
  * Se pueden usar las variables comunes suministradas por el script principal según sea necesario.
  * Este script no debe ser interactivo, es decir, no enviar mensajes al monitor, no leer de teclado, no esperar confirmación.
  * Si los comandos necesitan usar un fichero llave, debería ser ubicado en la carpeta [keys][keys].

---
[Regresar al índice](#indice)

#### 5.5 Añadir nuevo subscript para preparar la instalación de una aplicación
Para añadir un nuevo subscript que prepare una aplicación antes de que comience el proceso de instalación, siga los siguientes pasos:

1. Crear un nuevo fichero 'NombreAplicacion.sh' tomando como base la plantilla [template-pre-installation.sh][template-pre-installation.sh].
  Consideraciones:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) al nombre de aplicación definido en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde].
  * Si el script es válido para todas las distros linux, debe ser colocado en la carpeta _./third-party-repo_.
  * Si el script es válido sólo para distros Ubuntu, debe ser colocado en la carpeta _./third-party-repo/ubuntu_.
  * Si el script es válido sólo para distros Debian, debe ser colocado en la carpeta _./third-party-repo/debian_.
  * Si el script es válido sólo para distros Linux Mint, debe ser colocado en la carpeta _./third-party-repo/linuxmint_.
  * Si el script es válido sólo para distros LMDE, debe ser colocado en la carpeta _./third-party-repo/lmde_.
  * Los scripts ubicados en carpetas específicas de distribución tienen mayor prioridad frente a los scripts ubicados en la carpeta _./third-party-repo_.

2. Añadir los comandos necesarios al final del fichero para configurar la aplicación
  Consideraciones:
  * No es necesario usar 'sudo' ya que el subscript será ejecutado como usuario administrador.
  * Se pueden usar las variables comunes suministradas por el script principal según sea necesario.
  * Este script no debe ser interactivo, es decir, no enviar mensajes al monitor, no leer de teclado, no esperar confirmación.

---
[Regresar al índice](#indice)

#### 5.6 Añadir nuevo subscript para instalar una aplicación externa a repositorios
Para añadir un nuevo subscript para instalar una aplicación externa a repositorios, siga los siguientes pasos:

1. Crear un nuevo fichero 'NombreAplicacion.sh' tomando como base la plantilla [template-non-repo-app.sh][template-non-repo-app.sh].
  Consideraciones:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) al nombre de aplicación definido en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde].
  * Si el script es válido para todas las distros linux, debe ser colocado en la carpeta _./third-party-repo_.
  * Si el script es válido sólo para distros Ubuntu, debe ser colocado en la carpeta _./third-party-repo/ubuntu_.
  * Si el script es válido sólo para distros Debian, debe ser colocado en la carpeta _./third-party-repo/debian_.
  * Si el script es válido sólo para distros Linux Mint, debe ser colocado en la carpeta _./third-party-repo/linuxmint_.
  * Si el script es válido sólo para distros LMDE, debe ser colocado en la carpeta _./third-party-repo/lmde_.
  * Los scripts ubicados en carpetas específicas de distribución tienen mayor prioridad frente a los scripts ubicados en la carpeta _./third-party-repo_.

2. Añadir los comandos necesarios al final del fichero para descargar e instalar la aplicación externa.
  Consideraciones:
  * No es necesario usar 'sudo' ya que el subscript será ejecutado como usuario administrador.
  * Se pueden usar las variables comunes suministradas por el script principal según sea necesario.
  * Este script no debe ser interactivo, es decir, no enviar mensajes al monitor, no leer de teclado, no esperar confirmación.

---
[Regresar al índice](#indice)

#### 5.7 Añadir nuevo subscript para configurar una aplicación
Para añadir un nuevo subscript que configure una aplicación después del proceso de instalación, siga los siguientes pasos:

1. Crear un nuevo fichero 'NombreAplicacion.sh' tomando como base la plantilla [template-post-installation.sh][template-post-installation.sh].
  Consideraciones:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) al nombre de aplicación definido en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde].
  * Si el script es válido para todas las distros linux, debe ser colocado en la carpeta _./third-party-repo_.
  * Si el script es válido sólo para distros Ubuntu, debe ser colocado en la carpeta _./third-party-repo/ubuntu_.
  * Si el script es válido sólo para distros Debian, debe ser colocado en la carpeta _./third-party-repo/debian_.
  * Si el script es válido sólo para distros Linux Mint, debe ser colocado en la carpeta _./third-party-repo/linuxmint_.
  * Si el script es válido sólo para distros LMDE, debe ser colocado en la carpeta _./third-party-repo/lmde_.
  * Los scripts ubicados en carpetas específicas de distribución tienen mayor prioridad frente a los scripts ubicados en la carpeta _./third-party-repo_.

2. Añadir comandos necesarios al final del fichero para configurar la aplicación
  Consideraciones:
  * No es necesario usar 'sudo' ya que el subscript será ejecutado como usuario administrador.
  * Se pueden usar las variables comunes suministradas por el script principal según sea necesario.
  * Este script no debe ser interactivo, es decir, no enviar mensajes al monitor, no leer de teclado, no esperar confirmación.

---
[Regresar al índice](#indice)

#### 5.8 Añadir nuevo subscript para configurar el soporte EULA
Para añadir un nuevo subscript que configure el soporte EULA para un paquete, siga los siguientes pasos:

1. Crear un nuevo fichero './eula/nombrePaquete' tomando como base los siguientes comandos de la plantilla [template-eula][template-eula].
  ```bash
  ##########################################################################
  # Este fichero contiene parámetros del comando debconf para evitar la
  # instalación interactiva del paquete para confirmar EULA.
  #
  # Formato: <paquete> <módulo>/<parámetro> <comando> <valor>.
  # Vea "man debconf" o "man debconf-set-selections" para más información.
  ##########################################################################

  # ...
  ```
  Consideraciones:
  * El nombre de fichero debe ser idéntico (sensible a mayúsculas) al paquete asociado a la aplicación definido en el fichero [applicationList.ubuntu][applicationList.ubuntu], [applicationList.debian][applicationList.debian], [applicationList.linuxmint][applicationList.linuxmint] or [applicationList.lmde][applicationList.lmde].

2. Añadir parámetros al final del fichero con la sintaxis indicada en la plantilla para evitar las preguntas EULA durante el proceso de instalación.

---
[Regresar al índice](#indice)

### 6. Añadir nuevo fichero de traducción
Para añadir un nuevo fichero de traducción a otro idioma, siga los siguientes pasos:

1. Crear un nuevo fichero './languages/xx.properties' con el contenido de un fichero de traducción existente, por ejemplo, [en.properties][en.properties]
  Consideraciones:
  * 'xx' debe ser dos caracteres minúsculas basado en [ISO639-1 code][ISO639] para el idioma concreto.

2. Traducir los valores de todas las variables al idioma concreto.
  Consideraciones:
  * Los nombres de variables no deben ser cambiados bajo ninguna circunstancia.

---
[Regresar al índice](#indice)

### Notas del autor
Sería apreciada cualquier contribución a este proyecto.  
Espero que lo encontréis útil.

<!-- Referencias -->
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
[screenshot dialog]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/screenshot-dialog.jpg
[screenshot zenity]:http://cesar-rgon.github.io/linux-app-installer/images/screenshots/screenshot-zenity.jpg
[ISO639]:http://es.wikipedia.org/wiki/ISO_639-1
[tux bricoleur]:https://nowhere.dk/wp-content/uploads/2010/03/lilitux-tux-bricoleur.png
[under construction]:http://1.bp.blogspot.com/_qgWWAMk9DLU/R0_rG8oIQWI/AAAAAAAAAdI/DjY32PC6Wu4/s200/xanderrun-tux-construction-8454.png
