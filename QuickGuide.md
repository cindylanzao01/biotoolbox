# Quick Setup Guide for BioToolBox #

This guide is a quick set up guide for BioToolBox. If you wish look at a more detailed guide, see the BioToolBox [general guide](BioToolBoxSetUp.md) or a [Mac OS X specific](SetupForMacOSX.md) version.

BioToolBox is available on the [CPAN archive](http://search.cpan.org/perldoc?Bio::ToolBox) for convenient distribution and installation.

## Experienced users ##
Experienced users who are familiar with Perl and [CPAN](http://www.cpan.org) can get started right away using their favorite method to download and install BioToolBox.

## Less experienced users ##

### Before you begin ###
  * Make sure that you have a linux or Mac OS X workstation. I have not tried Windows; it may be possible to install within a unix-like environment within Windows.
  * Make sure Perl is installed. Version 5.12 or later is recommended but not required. It should work with at least version 5.10; version 5.8 requires so many module updates that it is difficult to get up to speed. Type "`perl -v`" in a command prompt to find out.
  * Make sure you have C compiler (GCC or equivalent and `make`). While in theory it is not absolutely required, you will not get far without it. Linux users can install it through their package manager; Mac OS X users should install XCode from the App Store and enable "Command Line Tools" in the preferences.

### Super easy install ###
To install BioToolBox in your home folder, using the default system-installed Perl, copy and paste the following command in a terminal.
<pre>
curl -L http://cpanmin.us | perl - local::lib App::cpanminus Bio::Root::Version Bio::ToolBox<br>
</pre>

This may or may not fail, depending on the number of dependencies that must be installed. Repeat two or thee times as necessary until it installs correctly. Or follow the steps below or consult the guides listed above.

### Step by step easy install ###
This will install a local Perl library in your home folder. It will also install a convenient CPAN package manager, cpanminus, that does not require configuration. It uses a command line utility, `cpanm`, for installation. Paste the following line into a terminal to get started.
<pre>
curl -L http://cpanmin.us | perl - local::lib App::cpanminus<br>
</pre>

The following command will make sure that the local Perl environment is loaded every time you start a new terminal session.
<pre>
echo 'eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)' >> ~/.bashrc<br>
</pre>
Mac OS X users may prefer to write to `~/.profile` instead, as `~/.bashrc` is not present by default.

The following modules are not required to be installed, but they will likely increase your success rate. They may or may not be updated automatically anyway.
<pre>
cpanm ExtUtils::MakeMaker Module::Build<br>
</pre>

I find installing BioPerl separately helps to confront potential issues up front, but this step is not required, as it would be installed anyway as a dependency for BioToolBox.
<pre>
cpanm Bio::Root::Version<br>
</pre>

**Note**: You may encounter issues installing the current version of Bio::Perl, version 1.6.923. The CPAN Testers report is riddled with failures for this version. Instead, install the previous version, [1.6.922](http://search.cpan.org/~cjfields/BioPerl-1.6.922/). The changes are minor, but you will save yourself headaches.

Now you can install BioToolBox.
<pre>
cpanm Bio::ToolBox<br>
</pre>

The BioToolBox scripts will be installed in `~/perl5/bin`. If you appended the command to `.bashrc` as described above, they should be available through your `$PATH` without having to provide a full path.

### Additional modules ###
If you use any of the included BioToolBox scripts, you will find that they may require additional Perl modules. Most of the scripts should fail gently if you are missing a required module.

In most cases, you can use `cpanm` again to install the missing module. For example,
<pre>
cpanm DBI::SQLite<br>
cpanm Algorithm::Cluster<br>
cpanm Parallel::ForkManager<br>
</pre>

For modules that require external dependencies, for example the `Bio::DB::Sam` and `Bio::DB::BigFile` modules for working with Bam files and BigWig files, you should read the BioToolBox [Setup Guide](BioToolBoxSetUp.md), as these are more involved.

### Troubleshooting ###
If a `cpanm` command fails, it will list the modules that failed to install, usually preceded with an exclamation point. Try installing those individually.

Did you try updating `ExtUtils::MakeMaker` and `Module::Build`? Many (but not all) times this will fix the problem of installing.

Try the original command again. Sometimes a prerequisite gets built out of order, and by re-issuing the command it will succeed the second (third?) time. It also helps to install missing requirements one at time before you go back and install the original package.

If all else fails, employ your favorite search engine.

