# HOWTO: Mapping unidentified mutations by whole genome sequencing #

Whole genome sequencing has now enabled a (relatively) easy and straight forward approach to mapping sequence variants and unknown mutations. This is particularly useful, for example, in sequencing lab strains (yeast, fly, etc.) with novel, unknown mutations. What used to take months to more than a year can now be done in a couple weeks!

This HOWTO should help in this process. Don't forget, you may still need to verify your mutant by complementation and linkage as appropriate.

## Starting ##
Sequence your strain's genome. This usually involves submitting high-quality genomic DNA, which is sheared, prepped into a library, and sequenced with next generation sequence technologies. You should aim for 10-50X average coverage to reliably call sequence variants; more is generally better, but at a cost. Talk to you local sequencing facility for more specifics.

You may want to consider sequencing the parent strain to determine the background level of sequence variants that exist between your laboratory strain and the published reference genome. Alternatively, sequence multiple unknown strains, and assume that all the common sequence variants are background.

## Sequence alignments ##
There are numerous sequence aligners that may be used to align the raw sequence reads to the reference genome. Two popular aligners that I am familar with is [Bowtie](http://bowtie-bio.sourceforge.net/index.shtml) and [Novoalign](http://novocraft.com/main/index.php), but many more exist; some are faster but at a cost of accuracy, some align gaps and others do not, and so on.

The specifics of aligning the data is beyond the scope of this tutorial, but in general for SNP discovery you want slower, more accurate aligners that allow for gaps (InDels, or Insertion/Deletions).

The aligned sequences are usually converted into a near de-facto standard format, the [BAM](http://samtools.sourceforge.net/SAM1.pdf) format, which allows for rapid, random access through a compressed, indexed, binary file format. See either [Samtools](http://samtools.sourceforge.net) or [Picard](http://picard.sourceforge.net/index.shtml) for converting, sorting, and indexing the Bam file.

For those using Novoalign (I'm not necessarily advocating, but it works quite well for our purposes), I have written a [wrapper tool](Pod_novo_wrapper.md) for simplifying alignment and subsequent conversion to Bam file. A custom Bash script could accomplish the same thing.

## Finding the sequence variants ##
Again, there are many different SNP callers for identifying the sequence variants. For simplicity, I am illustrating with the Samtools SNP caller. Some more advanced SNP callers include [GATK](http://www.broadinstitute.org/gsa/wiki/index.php/Home_Page) and [VAAST](http://www.yandell-lab.org/software/vaast.html), but they assume you are working with human samples rather than simpler model organisms. There are many more SNP callers out there, but determining which SNP caller is the best is left as an exercise to the reader.

For these purposes, I assume that one Bam sequencing file `=` one strain. It is possible to combine multiple samples into one Bam file, but that quickly gets quite complicated. If you have multiple Bam files for one strain (perhaps you have more than one lane of sequencing), they can be combined into one Bam file for simplicity.

### Running samtools mpileup ###
The Samtools site [describes](http://samtools.sourceforge.net/mpileup.shtml) using the `mpileup` function to generate the sequence variants. The tool writes files in the [VCF](http://vcftools.sourceforge.net/specs.html) format. Here, I'm combining multiple steps into one. Again, we're using one strain per sequence file at a time.

I am assuming the tools are in your environment path; if not, you will need to provide the full paths to the executables.

You will also need to have an indexed fasta file for the reference genome. To index the fasta file, use `samtools`.
<pre>
samtools faidx reference.fasta<br>
</pre>

Now, we run the `mpileup` command. Carefully note the pipe `|` and lone dash `-` characters. This command is all one line.
<pre>
samtools mpileup -uf reference.fasta strain1.bam | bcftools view -cgv - | vcfutils.pl varFilter > strain1.vcf<br>
</pre>
We are running three distinct utilities, `samtools`, `bcftools`, and `vcfutils.pl`, all piped together, with the final output redirected to a new text file, `strain1.vcf`. Each utility has it's own set of options, we're just using the minimal options. Feel free to add additional options; one such one to look at is minimum and maximum read depth.

The first utility, `samtools`, generates a stream of all of the sequenced bases from the alignments at each position in the genome.

The second utility, `bcftools`, determines whether all sequences are the same or a variation occurs, and performs some fancy statistical calculations as to the liklihood of the variation.

The third utility, `vcfutils.pl`, further filters the sequence variants.

Repeat the above command for each strain that you have sequenced.

## Finding unique and common sequence variants ##
Assuming you have sequenced two or more strains, you can now intersect those two lists to find the sequence variants that are unique (representing potential novel mutations) and common (representing strain background polymorphisms). The **BioToolBox** script [intersect\_SNPs.pl](Pod_intersect_SNPs.md) can generate these lists of common and unique sequence variants.
<pre>
intersect_SNPs.pl strain1.vcf strain2.vcf ...<br>
</pre>

For two input files, you should get three output files: `strain1_unique.vcf`, `strain2_unique.vcf`, and `strain1_strain2_common.vcf`. The unique files should be considerably shorter, hopefully.

## Identifying novel mutations ##
Now comes the fun part of identifying which sequence variants overlap which genomic annotations (genes) and, if so, alter coding potential. The **BioToolBox** script [locate\_SNPs.pl](Pod_locate_SNPs.md) will do this.

You will need a Bio::DB::SeqFeature::Store formatted database containing the reference genome annotation. See [Working with Databases](WorkingWithDatabases.md) for more information. For small genomes, it is possible to load the annotation GFF3 file into an in-memory database.

Run the [locate\_SNPs.pl](Pod_locate_SNPs.md) script on each of your strain's unique VCF files. Multiple input files may be specified at once.
<pre>
locate_SNPs.pl --db annotation strain1_unique.vcf strain2_unique.vcf<br>
</pre>

You should obtain a simple, tab-delimited text file for each input file. Each row represents one sequence variant, and columns describe the overlapping feature(s), any potential codon change(s), and the number of supporting reads.

One key column to note, if present, is the number of supporting reads. For a haploid organism, such as _S. cerevisiae_, you might expect all of the reads to have the same alternate sequence variant. For diploid organisms, you may or may not expect 100% supporting reads, depending on the zygosity of the mutant allele.

Once you have a list of candidates, you should inspect the Bam sequence alignments in a genome viewer. False positives might be expected for sequence variants near a sequence gap or in poor quality base calls at the end of the sequence reads.