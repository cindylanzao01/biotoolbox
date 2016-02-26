_This page was generated from POD using [pod2gcw](http://code.google.com/p/pod2gcw) and is not intended for editing._

## NAME ##
run\_cluster.pl

A script to run the k-means cluster analysis.

## SYNOPSIS ##
run\_cluster.pl `[`--options...`]` <filename>

```
  Options:
  --in <filename>
  --out <jobname> 
  --num <integer>               (6)
  --run <integer>               (200)
  --method [a|m]                (m)
  --dist [c|a|u|x|s|k|e|b]      (e)
  --version
  --help
```
## OPTIONS ##
The command line flags and descriptions:

--in <filename>


> Specify the input file. The file should be a simple tab-delimited text  file, genes (features) as rows, experimental data (microarray or sequencing  data) should be columns. The first column contains unique gene identifiers.  A column header row is expected. Standard biotoolbox data text files with  metadata lines should be exported to a compatible format using the treeview  function in the _manipulate\_datasets.pl_ script. A .cdt file generated  from this may also be used.

> 
--out <jobname>


> Specify the output jobname, which will be the basename of the output files.  By default it uses the input base filename.

> 
--num <integer>


> Specify the number of clusters to identify. Default value is 6.

> 
--run <integer>


> Enter the number of iterations to run the cluster algorithm to find an  optimal solution. The default value is 500.

> 
--method `[`a|m`]`


> Specify the method of finding the center of a cluster. Two values are  allowed, arithmetic mean (a) and median (m). Default is mean.

> 
--dist `[`c|a|u|x|s|k|e|b`]`


> Specify the distance function to be used. Several options are available.

> 
```
	c  correlation
	a  absolute value of the correlation
	u  uncentered correlation
	x  absolute uncentered correlation
	s  Spearman's rank correlation
	k  Kendall's tau
	e  Euclidean distance
	b  City-block distance
```
> The default value is 'e', Euclidean distance.

> 
--version


> Print the version number.

> 
--help


> Display this POD documentation.

> 
## DESCRIPTION ##
This program is a wrapper around the Cluster 3.0 C library, which identifies  clusters between genes. Currently the program performs the k-means or  k-medians functions, although other functions could be implemented if  requested.

Please refer to the Cluster 3 documentation for more detailed information  regarding the implementation and detailed methods. Documentation may be  found at <http://bonsai.hgc.jp/~mdehoon/software/cluster/>.

Select the desired number of clusters that are appropriate for your dataset  and an appropriate number of iterations. The default values are fine to  start with, but should be customized for your dataset. In general, empirically  test a range of cluster numbers, e.g. 2 to 12, to find the optimal cluster  number that is both informative and manageable. Increasing the number of  iterations will increase confidence at the expense of compute time. The goal   is to find an optimal solution more than once; the more times a solution  has been found, the higher the confidence. Note that noisy or very large  datasets may never yield more than 1 solution.

The resulting CDT files may be visualized using the Java Treeview program,  found at <http://jtreeview.sourceforge.net>.

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
