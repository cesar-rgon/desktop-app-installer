Description: Application list per Linux Distro, used by main menu. It contains repository applications and/or non repository ones.
Author: César Rodríguez González
Licence: MIT

The columns are described below:
Category Name [mandatory]:      shall contain only letters, digits and/or underscore '_' and do not begin with a digit. No whitespaces.
Application Name [mandatory]:   shall contain only letters, digits and/or underscore '_' and do not begin with a digit. No whitespaces.
Application-packages:           For a repository application, this column is mandatory and it must contain whitespace character between
                                package names. For a non-repository application, this column must be empty because there isn't any
                                repository package to be installed.

Lines begining with comment character "#", "," or blank ones are ignored

