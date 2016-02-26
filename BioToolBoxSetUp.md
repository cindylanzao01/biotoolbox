# Installing BioPerl and other prerequisites for BioToolBox #

This guide is for new users looking to set up BioPerl and BioToolBox.

## Contents ##
  1. [Before you begin](BioToolBoxSetUp#Before_you_begin.md)
  1. [Version of Perl](BioToolBoxSetUp#Version_of_Perl.md)
    1. [Using PerlBrew to install a new Perl](BioToolBoxSetUp#Using_PerlBrew_to_install_a_new_Perl.md)
  1. [Local or Root](BioToolBoxSetUp#Local_or_Root.md)
    1. [Installing locally](BioToolBoxSetUp#Installing_locally.md)
  1. [Installing Perl Modules](BioToolBoxSetUp#Installing_Perl_Modules.md)
    1. [Installing Perl modules using cpanminus](BioToolBoxSetUp#Installing_Perl_modules_using_cpanminus.md)
    1. [Installing Perl modules through CPAN](BioToolBoxSetUp#Installing_Perl_modules_through_CPAN.md)
    1. [Basic perl modules to install](BioToolBoxSetUp#Basic_perl_modules_to_install.md)
    1. [Trouble shooting	Perl module installation](BioToolBoxSetUp#Trouble_shooting_Perl_module_installation.md)
  1. [Installing Bioperl](BioToolBoxSetUp#Installing_Bioperl.md)
  1. [Installing BioToolBox](BioToolBoxSetUp#Installing_BioToolBox.md)
  1. [Installing database modules](BioToolBoxSetUp#Installing_database_modules.md)
  1. [Installing Graphing Modules](BioToolBoxSetUp#Installing_Graphing_Modules.md)
  1. [Installing Bam file support](BioToolBoxSetUp#Installing_Bam_file_support.md)
  1. [Installing bigWig and bigBed support](BioToolBoxSetUp#Installing_bigWig_and_bigBed_support.md)
    1. [Big file utilities](BioToolBoxSetUp#Big_file_utilities.md)
  1. [Installing support for legacy wig files](BioToolBoxSetUp#Installing_support_for_legacy_wig_files.md)
  1. [Installing the Ensembl Perl API](BioToolBoxSetUp#Installing_the_Ensembl_Perl_API.md)

## Before you begin ##
This guide assumes a few things.
  * First, you have access to a unix-based computer, including Linux and Mac OS X. Windows users may need to explore other options (a new [computer](http://store.apple.com) or a new [operating system](http://www.ubuntu.com/))
  * Second, you have relative familiarity with command line usage in the terminal. Users should be able to move around and understand the file system directory, view and manipulate files, run programs, etc.
  * Third, Perl is installed on your machine. Almost every unix-based computer should have it installed, at least in some basic form. See the section below about Perl for more information.
  * Finally, you'll need to have GNU C compiler (GCC) installed for compiling software from source code. Most Linux distributions should already have this installed; if not, it's easily obtainable using your favorite package manager. On Mac OS X, you'll need to install the Developer Tools from your installation disc or XCode from the Mac App Store. Be sure to include the Command Line Tools from within XCode.
  * Mac users may wish to look more closely at my other guide, [Set up for Mac OS X](SetupForMacOSX.md), although this guide will mostly work as well.

## Version of Perl ##
BioToolBox should run on any version of Perl that is at least version 5.8. Although, getting it installed is another issue. I have found that the older the version of Perl, the harder I have installing modules (more and more prerequisites need to be upgraded, sometimes with circular dependencies). This is especially true with 5.8. Version 5.10 doesn't seem too bad, and 5.12 and newer goes fairly smoothly.

### Using PerlBrew to install a new Perl ###
If you find yourself with a linux computer with a geriatric version of Perl (e.g., Red Hat), you can try checking your package manager for a newer version that can be installed. If one is not available, you can install one from [source](http://www.cpan.org/src/README.html). But the absolute easiest way to do this, especially if you do not have administrative privileges on the server, is to use [Perlbrew](http://perlbrew.pl). To install, for example, perl 5.16 in your home directory, enter the following commands in a terminal.
<pre>
curl -L http://install.perlbrew.pl | bash<br>
echo "source ~/perl5/perlbrew/etc/bashrc" >> ~/.bashrc<br>
source ~/.bashrc<br>
perlbrew install-cpanm<br>
perlbrew install -v --multi --thread --64all --as 5.16 perl-5.16.4<br>
perlbrew clean<br>
perlbrew use 5.16<br>
</pre>
The above commands will set up perlbrew, set up your environment to use perlbrew, install cpanminus package manager, install perl version 5.16 with threaded 64 bit support, clean up the installation files, and use the installed version. You can type `perlbrew help` on the command line for more information.

Note that anytime you start a new terminal session, you should run "`perlbrew use perl-X.XX`" to switch to that version of Perl, otherwise you will default to the system installed version. Alternatively, you can also use the command "`perlbrew switch`" command to always enable a specific Perl version whenever you start a new terminal session.

## Local or Root ##
If you are an administrator on the computer, then you can install BioPerl and other Perl modules in the system directories for multiple users. This can sometimes make things easier and avoids multiple installations. However, it's easier to break something, especially if you're not sure what you are doing.

If you don't have administrator access, or prefer to keep things confined, then you can easily install in your home directory. In this manner, you would use the system-installed Perl and libraries, and additional or newer versions of Perl modules would be installed in your own personal library.

### Installing locally ###
If you installed your own version of Perl using perlbrew as described above, then you are already working with your own version in your home directory. You should then skip this section. Otherwise, if you are using the system installed Perl but cannot or will not install modules in the system directories, then you can set up your own perl libraries in your home directory. These are in addition to the system directories.

The easiest way to install Perl modules locally in your own directory is to use the `local::lib` module. By installing this module, it will automatically set up your own Perl libraries in your home directory.

Download the latest [version](http://search.cpan.org/perldoc?local::lib) manually from CPAN, and follow the directions in the readme under the bootstrap section. Or follow the directions below within the extracted directory:
<pre>
perl Makefile.PL --bootstrap<br>
make test<br>
make install<br>
</pre>

Alternatively, you can install it using cpanminus.
<pre>
curl -L http://cpanmin.us | perl - local::lib App::cpanminus<br>
</pre>

You should now have a `perl5` directory within your home directory. This will contain your local Perl modules.

Now you just need to set up your environment. This is assuming you're using the BASH shell for your login (a pretty safe assumption for most). Run the following command.
<pre>
echo 'eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)' >> ~/.bashrc<br>
</pre>

If you look at your `.bashrc` file, you should find you've just added the above line to the end of the file. This will take care of setting up environment variables so that everytime you log in, you will use your own Perl libraries and not the system libraries. You should log out and back in for this to take effect. Then run `env` to print out your environment variables and confirm them. You should have a number of Perl related environment variables listed, including `PERL5LIB` and `PERL_LOCAL_LIB_ROOT`. If not, try adding the above line to your `~/.profile` file instead (works for Mac OS X).

## Installing Perl modules ##
The [Comprehensive Perl Archive Network](http://search.cpan.org/) is an extensive repository of Perl modules. If you're faced with a difficult job of coding some project, chances are that someone else has either done it for you, or at least written some code that will make the job easier. There are thousands of Perl modules in CPAN, some of which are just right for you.

There are two ways to install perl modules, including the BioToolBox package: using a simple utility with no configuration required (cpanminus), or a traditional, deluxe method with lots of customization (CPAN). These tools are by no means exclusive; I use both.

### Installing Perl modules using cpanminus ###
You can conveniently install cpanminus using a single command by downloading self-executable file from the internet. What could be easier?

To install it into a local library in your home folder, execute the following command.
<pre>
curl -L http://cpanmin.us | perl - local::lib App::cpanminus<br>
</pre>

If you wish to install it into the system libraries, add a `-S` option. This will prompt it to ask for your `sudo` password when it is time to install.
<pre>
curl -L http://cpanmin.us | perl - --sudo App::cpanminus<br>
</pre>

This will install an executable, `cpanm`, which you will then use to install any other perl module. It should automatically identify and install dependencies as necessary. For example,
<pre>
cpanm Some::Module<br>
cpanm Bio::Root::Version Bio::ToolBox<br>
</pre>
That is pretty much all there is to it. Simple, right?

### Installing Perl modules through CPAN ###
The traditional way to install perl modules from CPAN is to use the CPAN shell. This allows you to control from where the modules are downloaded, set general custom options for building, allow for more complex searching, allow interactive configuration during building, and more. To use the the CPAN Shell, run the following command
<pre>
sudo cpan<br>
</pre>

If you have already configured `local::lib` above, then you can drop the `sudo` prefix and simply run `cpan` by itself to install into your home library.

When you first run CPAN, it will ask to run through a bunch of configuration questions. It’s probably ok to let it do it for you automatically, but everyone should go through those questions once in their life, right? (according to Larry Wall, the original author of the Perl language). There may be things you want to change, such as CPAN mirror sites. Also, set both Make and Build arguments to uninstall previous versions when possible.

CPAN shell will keep its files in one directory, by default `~/.cpan`. I usually set this to `/usr/local/cpan` to put it in a more generic location.

Here is an extremely simplified primer for working with the CPAN Shell. You can also look at the inline help by typing `h` at the CPAN Shell prompt.

You can search for modules by entering this command
<pre>
m /something/<br>
</pre>

You can also search for a distribution.
<pre>
d /something/<br>
</pre>

You can install a module or distribution this way
<pre>
install some::module<br>
</pre>

Or by specifying the exact version file
<pre>
install SOMEBODY/SomeModule-1.0.1.tar.gz<br>
</pre>

CPAN will detect prerequisites for your module. If so, it will attempt to prepend their installation before installing your requested module. Just say yes to those.

If the module was installed properly, you should find something like
<pre>
/usr/bin/make install -- OK<br>
</pre>
somewhere near the end of all the text that goes by. If you see "`NOT OK`", then something went wrong and you will have to trouble shoot by looking back at the error messages. It's usually because something else was missing, or a C library is of the wrong architecture for the version you're using, e.g. 32-bit versus 64-bit, or i386 versus PPC.

### Basic perl modules to install ###
Some basic modules to upgrade or install right away include the following. They will generally make things go smoother later on.
  * `Module::Build`
  * `ExtUtils::MakeMaker`
  * `YAML`

If you are using the CPAN Shell, you may also want to try installing the following too.
  * `readline`
  * `Term::ReadKey`
  * `CPAN`

### Trouble shooting	Perl module installation ###
Despite the ease of package manager for installing Perl modules, things don't always go right. All Perl modules have (or should have) tests which confirm that the module is compiled or set up properly. Sometimes these fail, for various reasons.

Look back through the output for possible clues to the failure. Often times there is a missing prerequisite module (or version) that wasn't caught. Look for an error that complains about not finding XXX in @INC. Install the missing prerequisite and try again.

Sometimes the module needs to compile a small binary executable extension, usually a program written in C, that can dramatically speed up certain functions. Many times these extensions need system or package libraries, which must be found in the environment path. Make sure those are available. For example, the perl module GD.pm needs access to the gd2 libraries, which can be installed (see above).

Sometimes, making or building a Perl module under the CPAN shell just doesn't work quite right, but running it manually from the terminal (Bash prompt) does work. You can try grabbing the source tarball from the CPAN website, or from the source directory within the CPAN directory, and try it. Read the documentation that comes with the package. This has occasionally worked for me, for whatever reason.

Finally, it's possible that there is an error in the test that's preventing the module from installing, but that the module is, in fact, working just fine. You can always try a "`force install`", and then empirically test your program(s). I generally try to avoid this (being cautious), but have [resorted](SetupForMacOSX#Errors_regarding_GD.md) to it successfully.

## Installing BioPerl ##
The BioToolBox package relies heavily on the [BioPerl](http://www.BioPerl.org/wiki/Main_Page) module distribution, which is a set of modules for working with all sorts of biological annotation and information. Fortunately, BioPerl is relatively easy to install through CPAN.

If you have cpanminus installed, you can use that.
<pre>
cpanm Bio::Root::Version<br>
</pre>
Or if you are using the cpan shell
<pre>
> install Bio::Root::Version<br>
</pre>

**Note**: You may encounter issues installing the current version of Bio::Perl, version 1.6.923. The CPAN Testers report is riddled with failures for this version. Instead, install the previous version, [1.6.922](http://search.cpan.org/~cjfields/BioPerl-1.6.922/). The changes are minor, but you will save yourself headaches.

Alternatively, you can always download the source and build it following the instructions within. Depending upon your current setup, there may or may not be a number of dependencies, that should be automatically installed for you.

The build process includes an interactive configuration. It is safe to accept the default answers for all of them. If you wish to keep things simple, you can opt not to install all of the scripts; at the very least, you should install the Bio::DB::SeqFeature::Store scripts, as these are required for BioToolBox.

## Installing BioToolBox ##
You may install BioToolBox using either cpanminus or the CPAN shell. Follow the instructions and examples above.

## Installing database modules ##
If you intend to use a database for storing genome annotation, then a relational database is in order. The BioToolBox programs relies on the [Bio::DB::SeqFeature::Store](http://BioPerl.org/wiki/Module:Bio::DB::SeqFeature::Store) schema. This can be utilized on a SQLite, MySQL, or PostgreSQL database. A memory database is also available, although it's usefulness is quite limited. The SQLite database is a safe, simple alternative without the overhead and complexity. The others will provide much better performance, especially in multi-user environments.

If it's not installed already, most Linux distributions and Mac OS X versions have packages or installers available to install one or more of these database systems on your computer, usually as a system-wide service. You'll have to look elsewhere for help on installing one. Be sure to also install the associated developer files or package, which include the libraries and header files necessary for installing the Perl modules.

Once a database is installed, you can then install the appropriate Perl module drivers. The `DBI` module is required, and the subsequent ones are specific for your chosen database.
  * `DBI`
  * `DBD::SQLite`
  * `DBD::mysql`
  * `DBD::Pg`

If you do not need or want to install a database, that's OK too. Most BioToolBox programs happily take BED style input files with genomic coordinates, rather than retrieving coordinates from genomic annotation stored in the database.

## Installing Graphing Modules ##
There are a few BioToolBox scripts that allow you to generate simple plots or graphs as PNG files. These rely on the [GD](http://search.cpan.org/dist/GD/) Perl module, which, in turn, rely on [GD](http://www.boutell.com/gd/) libraries. These are also required for [GBrowse](http://gmod.org/wiki/GBrowse), if you intend to install that as well.

If the GD libraries are not installed already (most Linux distributions should have them), you can readily obtain them through your package manager. For Mac OS X, you'll have to install from source (good luck), use [Fink](http://www.finkproject.org/), or obtain pre-compiled packages from [here](http://sourceforge.net/projects/gmod/files/Generic%20Genome%20Browser/libgd-MacOSX/). For more information about Mac OS X, see [Installing GD Libraries](SetupForMacOSX#Installing_GD_Libraries.md).

Once the GD libraries are installed, you can then install the GD Perl modules using the CPAN Shell.
  * `GD`
  * `GD::Graph`
  * `GD::Graph::smoothlines`

Note that on Mac OS X using libGD installed through Fink, I generally see test errors when installing the GD Perl module. I have been able to force install (ignoring errors), and everything seems to still work.

## Installing Bam file support ##
To work with next generation sequencing data, you'll need to install [samtools](http://samtools.sourceforge.net) and the corresponding Perl module [Bio-SamTools](http://search.cpan.org/dist/Bio-SamTools/). This will allow you to use the ubiquitous Bam file format in conversions and analysis.

Download the source code for the latest version from the samtools [SourceForge](http://sourceforge.net/projects/samtools/files/samtools/) project, and unpack it in your directory.

**Note** The Bio-SamTools Perl module **only** works with the 0.19 version, even though there is a newer HTSlib 1.0 version available. Most of the functionality we need is present in the older version, however.

Next, compile the program.
<pre>
make<br>
</pre>

The samtools `make` does not include test or install methods. For a system-wide installation, I will copy the `samtools-0.1.x` folder to `\usr\local\`, and generate symlinks to the executables `samtools` and `razip` into `\usr\local\bin\`, as well as symlink the man page `samtools.1` into the appropriate Man page directory. For a local home directory, just place the directory someplace easily accessible where you won't lose it. I'll also create symlinks to the executables in my home `~\bin` directory for quick access.

To install the Bio-SamTools Perl module, you'll need access to the header and library folders in the samtools directory (this is why you need to keep it handy). Install Bio-SamTools using your favorite CPAN install utility; see [Installing Perl Modules](BioToolBoxSetUp#Installing_Perl_Modules.md) above for details. During the installation, the Installer will ask for the location of the samtools headers and libraries. Enter the full path to where you've placed it, and it should compile and install fine.

One error you may or may not encounter is regarding shared libraries, and errors mentioning recompiling with "`-fPIC`". Some combinations of Perl and GCC don't mix well. In this case, go back to the samtools `Makefile`, edit the CFLAGS line and add "`-fPIC`" to the line (make sure there isn't a `#` comment character before it!). Then recompile.
<pre>
make clean<br>
make<br>
</pre>
Repeat the Bio-Samtools installation (you may need to issue the "clean" command from within CPAN Shell). It should work now.

## Installing bigWig and bigBed support ##
The UCSC Genome site developed the [bigWig](http://genome.ucsc.edu/goldenPath/help/bigWig.html) and [bigBed](http://genome.ucsc.edu/goldenPath/help/bigBed.html) file formats for easy sharing and viewing of dense genomic data, such as from next generation sequencing technologies. These are self-contained, compressed, indexed, binary file formats, similar to a Bam file, that can be accessed locally or remotely. Their use, while not required, are highly recommended if you're using large datasets.

You'll first need to compile the libraries used with big files. UCSC has recently changed their distribution method of source code. Earlier instructions (including those in the Bio-BigFile perl module) involve downloading the entire source code package, including browser, and having various other packages installed. Now they have made just the libraries and command-line utilities available, simplifying the installation process.

First, you will need to download the [userApps source](http://hgdownload.soe.ucsc.edu/admin/exe/userApps.src.tgz) file. In the download [directory](http://hgdownload.soe.ucsc.edu/admin/exe/) there are several versions available; I have tested version 310. Next, follow the steps below
<pre>
export MACHTYPE=x86_64<br>
<br>
tar xf userApps.src.tgz<br>
cd userApps/kent/src/<br>
export KENT_SRC=`pwd`<br>
<br>
cd lib/<br>
make<br>
cd ..<br>
</pre>
If the compile works successfully, You should have a `lib/x86_64/jkweb.a` file. Note the two export commands above. The first sets a generic machine type, and the second records the path to the source directory. Both will greatly ease the installation of the Perl module.

Next, install Bio-BigFile using your favorite CPAN utility; see [Installing Perl Modules](BioToolBoxSetUp#Installing_Perl_Modules.md) above for more information. During installation, it will need to know the location of the `kent/src/` directory. It should automatically find it from the environment variables you exported above (both are essential). Note that if you run CPAN Shell under `sudo`, your environment variables may not carry over if you performed the above not as root.

You may encounter the same error as with samtools above regarding "`-fPIC`". In that case, go back and edit the file `kent/src/inc/common.mk`. Find the line beginning with CFLAGS and add "`-fPIC`" to the line. Save, "`make clean`", and "`make`" again.


### Big file utilities ###
There are a number of utilities available for working with bigWig and bigBed files. Some of these are required for converting to the big format. The easiest way to obtain these is to download pre-compiled binaries for your platform from the [UCSC downloads](http://hgdownload.cse.ucsc.edu/admin/exe/) site.

Alternatively, you can compile the utilities yourself, since you have already downloaded the source code above.
Enter the `kent/src/util` directory, where you'll find numerous subdirectories for a number of utility programs. To compile all 200-something utilities, simply enter "`make`" on the command line. Alternatively, enter each one separately, and execute "`make`" in each subdirectory. It will compile the executable. The executable will be copied into "`~/bin/x86_64`". Here is a short list I would recommend.
  * `wigToBigWig`
  * `bedGraphToBigWig`
  * `bedToBigBed`
  * `bigWigInfo`
  * `bigBedInfo`
  * `bigWigToBedGraph`
  * `bigWigToWig`
  * `bigBedToBed`

## Installing support for legacy wig files ##
There are a number of reasons to go with binary bigWig files over the original wiggle implementation, but if you have legacy data, BioToolBox will work with it. The legacy adaptor is [Bio::Graphics::Wiggle](http://search.cpan.org/perldoc?Bio::Graphics::Wiggle), and was developed as part of the [GBrowse](http://gmod.org/wiki/GBrowse) browser. The associated Perl script, [wiggle2gff3.pl](http://search.cpan.org/perldoc?wiggle2gff3.pl), is part of GBrowse and will take as input a text wiggle file (.wig) and generate binary files (.wib) referenced by a GFF3 file. This GFF3 file, in turn, will need to be loaded in a Bio::DB::SeqFeature::Store database.

To install support, you'll need to install from CPAN at least  [Bio-Graphics](http://search.cpan.org/dist/Bio-Graphics/) and the [wiggle2gff3.pl](http://search.cpan.org/perldoc?wiggle2gff3.pl) script (or the complete [GBrowse](http://search.cpan.org/dist/GBrowse/)). These will require a number of other prerequisites, including the GD library.

## Installing the Ensembl Perl API ##
To retrieve genome annotation from Ensembl's public MySQL database using the BioToolBox script [get\_ensembl\_annotation.pl](Pod_get_ensembl_annotation.md), you will need to install Ensembl's Perl API modules. It is not available through CPAN, but you can find installation instructions [here](http://www.ensembl.org/info/docs/api/api_installation.html).

Ensembl is not very explicit about prerequisites, but you will need Perl modules `DBI` and `DBD::mysql` installed, as well as BioPerl. Their recommendation for BioPerl is an old version; the current CPAN or live version should work just as well, and it should be installed from the above instructions.

Rather than following their instructions for setting up your environment, you can simply manually copy their `EnsEMBL/` directory and all its contents (found under `ensembl/modules/Bio/` after extracting their archive) into your `Perl5/lib` directory, or wherever your Perl modules are installed. The `EnsEMBL` directory will go into your `Bio/` directory, along with the rest of BioPerl.

Note that because this is essentially a manual installation; any prerequisites or updates must also be done manually, and some functionality may be broken. With that said, I have not had any issues with at least the BioToolBox script `get_ensembl_annotation.pl`. Be forewarned.

Ensembl publishes a new Core API with each database release. If you are not seeing the latest genome version in the BioToolBox script [get\_ensembl\_annotation.pl](Pod_get_ensembl_annotation.md), you should update your Ensembl Perl API modules.