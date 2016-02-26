_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
check\_dependencies.pl

## SYNOPSIS ##
`[`sudo`]` ./check\_dependencies.pl

```
  Options:
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--version


> Print the program version number.

> 
--help


> This help text.

> 
## DESCRIPTION ##
This program will check for Perl module dependencies used by the biotoolbox  scripts. It will check for the installed version and the current version  in CPAN. For missing or out of date modules, it will offer to install them  through CPAN. Note that any dependencies may not be handled well, and you  may wish to decline and install manually through CPAN.

If your Perl modules are located in system-owned directories, you may need to  execute this script with root privilages. Or, if you prefer, check what is  missing with this program and then install manually with root privilages.

This will require that CPAN is properly configured (proxies, mirrors, etc.).

More information about setting up your computer may be found on the web at http://code.google.com/p/biotoolbox/wiki/!BioToolBoxSetUp**.

## AUTHOR ##
```
 Timothy J. Parnell, PhD
 Howard Hughes Medical Institute
 Dept of Oncological Sciences
 Huntsman Cancer Institute
 University of Utah
 Salt Lake City, UT, 84112
```
This package is free software; you can redistribute it and/or modify it under the terms of the GPL (either version 1, or at your option, any later version) or the Artistic License 2.0.

```
```
```
```