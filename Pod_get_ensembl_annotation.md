_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
get\_ensembl\_annotation.pl

A script to retrieve Ensembl annotation and write it out as GFF3.

## SYNOPSIS ##
get\_ensembl\_annotation.pl `[`--options...`]` --species <text>

```
  Options:
  --species <text>
  --out <filename>
  --(no)chromo
  --(no)protein
  --(no)rna
  --(no)miscrna
  --(no)snrna
  --(no)snorna
  --(no)mirna
  --(no)rrna
  --(no)trna
  --(no)cds
  --(no)utr
  --codon
  --ucsc
  --group <text>
  --host <host.address>
  --port <integer>
  --user <text>
  --pass <text>
  --printdb
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--species <text>


> Enter the species name for the database to connect to. Common aliases,  e.g. human, may be acceptable. This is typically provided in the format  as "genus\_species", e.g. "homo\_sapiens". Check the EnsEMBL website for  the species databases available, or print the list using the --printdb  option below.

> 
--out <filename>


> Specify the output filename. By default, it uses the species name. An  extension will be added if necessary.

> 
--(no)chromo


> Boolean flag to indicate whether to write (or not) features for  the toplevel chromosomes/scaffolds/contigs/sequences in the database.  The default is true.

> 
--no(protein)


> Boolean flag to indicate whether or not to collect protein-coding genes  from the database. The default is true.

> 
--(no)rna


> Boolean flag to indicate whether or not to collect all non-coding RNA  genes, including misc\_RNA, snRNA, snoRNA, rRNA, tRNA, miRNA, and piRNA,  from the database. This option may be superseded by setting the  individual RNA options. For example, setting both --rna and --notrna  will collect all RNA types except tRNAs. The default is true.

> 
--(no)miscrna


> Boolean flag to indicate whether or not to collect miscellenaeous  noncoding RNA genes. The default is true.

> 
--(no)snrna


> Boolean flag to indicate whether or not to collect small nuclear  RNA (snRNA) genes. The default is true.

> 
--(no)snorna


> Boolean flag to indicate whether or not to collect small nucleolar  RNA (snoRNA) genes. The default is true.

> 
--(no)mirna


> Boolean flag to indicate whether or not to collect micro  RNA (miRNA) genes. The default is true.

> 
--(no)rrna


> Boolean flag to indicate whether or not to collect ribosomal RNA  (rRNA) genes. The default is true.

> 
--(no)trna


> Boolean flag to indicate whether or not to collect transfer RNA    (tRNA) genes. The default is true.

> 
--(no)cds


> Boolean flag to indicate whether or not to include CDS information for  mRNA transcripts and genes. Default is true.

> 
--(no)utr


> Boolean flag to indicate whether or not to include UTR features for  mRNA transcripts and genes. Default is true.

> 
--codon


> Boolean flag to indicate whether or not to include start and stop codons  for mRNA transcripts and genes. Default is false.

> 
--ucsc


> Boolean flag to prefix chromosome names with 'chr' in the style of  UCSC genome annotation. Only coordinate systems of type 'chromosome'  are changed, not scaffolds, contigs, etc. Default is false.

> 
--group <text>


> Specify the name of the database group with which to connect. The default  value is 'core'. See EnsEMBL documentation for more information.

> 
--host <host.address>


> Specify the Internet address of the EnsEMBL public MySQL database host.  The default value is 'ensembldb.ensembl.org'.

> 
--port <integer>


> Specify the IP port address for the MySQL server. Default is 5306.

> 
--user <text>


> Specify the user name with which to connect to the EnsEMBL public database.  The default value is 'anonymous'.

> 
--pass <text>


> Specify the password to use when connecting to the database. The default  value is none.

> 
--printdb


> Print all of the available database names, species, and groups from the  connected EnsEMBL database. The program will exit after printing the list.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program will connect to the public EnsEMBL MySQL database and  retrieve the latest genome annotation for a given species. It will  generate a GFF3 annotation file suitable for loading into a Bio::DB  database or genome browser. The GFF3 features generated are  multi-level nested gene->mRNA->CDS features. It will optionally  generate features for the top-level sequences (chromosomes, contigs,  scaffolds, etc.) and non-coding RNA genes (snRNA, tRNA, rRNA, etc.).

Note that EnsEMBL releases new Perl API modules with each database  release. If you do not see the latest genome version (compared to what  is available on the web), you should update your EnsEMBL Perl modules.  The API version should be printed at the beginning of execution.

## REQUIREMENTS ##
This program requires EnsEMBL's Perl API modules to connect to their public  MySQL servers. It is not available through CPAN, unfortunately, but you can  find installation instructions at  <http://www.ensembl.org/info/docs/api/api_installation.html>.

## DATABASE ACCESS ##
If you having difficulties connecting, check the server and port numbers  at <http://www.ensembl.org/info/data/mysql.html>.

To connect to the Ensembl Genomes public mysql server rather than the  default, please specify the host as "mysql.ebi.ac.uk" and port 4157.  See <http://www.ensemblgenomes.org/info/data_access> for up to date  information.

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
