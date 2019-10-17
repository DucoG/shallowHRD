# shallowHRD

This method uses shallow Whole Genome Sequencing (sWGS ~ 1x) and the segmentation of a tumor genomic profile (adapted here for [ControlFREEC](http://boevalab.inf.ethz.ch/FREEC/tutorial.html)) to infer the Homologous Recombination status of a tumor based on the number of Large-scale State Transtions (LSTs).

## Introduction

*shallowHRD* is a R script that can be launched from the command line. It relies on a ratio file characterizing a normalized read counts of shallow Whole Genome Sequencing (0.5-2x) in sliding windows along the genome and its segmentation. It was developped on the [ControlFREEC](http://boevalab.inf.ethz.ch/FREEC/tutorial.html)'s output (Boeva,V. et al., 2011) but is adapted for other softwarz aswell (see run shallowHRD and Nota Bene). 

ControlFREEC counts reads in overlapping windows and corrects the read count for GCcontent, removing low mappability windows and segmenting the profile. Based a inferred cut-off representing a one copy difference, the segmentation is then smoothed in a step wise manner, using first large segments, reintegrating small segments afterwards and then filtering small interstitial CNAs. The HR status is estimated based on the number of Large-scale State Transitions (LSTs) along the genome.

## Requirements

* R installed (tested with v.3.5.1)
* The following packages installed : 
  * ggpubr (tested with v.0.2.3)
  * gridExtra (tested with v.2.3)
  * DescTools (tested with v.0.99.28)

Tested on Linux and Mac.

## Prerequisities

First, FASTQ files should be aligned to the hg19 reference genome (using [BWA-MEM](https://github.com/lh3/bwa) for instance) and supplementary & duplicate reads removed from the BAM files, using [Samtools](http://www.htslib.org/doc/samtools.html) and [PicardTools' MarkDuplicates](https://broadinstitute.github.io/picard/command-line-overview.html#MarkDuplicates), respectively.

Then, the BAM file should then be processed by ControlFREEC. The recommended options are indicated in a config file example in the repository (*controlfreec_config_file_example*). Briefly, depending on the coverage of the BAM files (0.5-2x), the window size was fixed at 20kb for the analysis. It can however be increased to 60kb, with a step size half its length (the lower the coverage, the larger the window).

Finally, the file *cytoBand_adapted_fr_hg19.csv* (available in the repository) has to be downloaded. 

The R packages can be installed with the script *install_packages.R* (available in repository) and the command line :

```
Rscript install.packages.R
```

## Run *shallowHRD*

To run *shallowHRD* only one ratio file is needed (formated for ControlFREEC's output).

The name of the table should be in this format : *SAMPLE_NAME.bam_ratio.txt*. <br/>

*shallowHRD* will rely on the *first four columns* of the input table (tabulated and Chromosome in number) : <br/>
Chromosome &nbsp; Start &nbsp; Ratio &nbsp; RatioMedian <br/>
1 &nbsp;&nbsp; 1 &nbsp;&nbsp; -1 &nbsp;&nbsp; -1 <br/>
. &nbsp;&nbsp; . &nbsp;&nbsp; . &nbsp;&nbsp; . <br/>
. &nbsp;&nbsp; . &nbsp;&nbsp; . &nbsp;&nbsp; . <br/>
. &nbsp;&nbsp; . &nbsp;&nbsp; . &nbsp;&nbsp; . <br/>

Create a directory named after your sample (SAMPLE_NAME in the format example) and put the ratio file inside. 

The command line to launch *shallowHRD* is (**absolute** paths) :

```
/path/to/Rscript /path/to/script/shallowHRD.R SAMPLE_NAME /absolute/path/to/created/directory /absolute/path/to/file/cytoBand_adapted_fr_hg19.csv
```

One file named *example.bam_ratio.txt* is downloadable in the repository to try *shallowHRD*.

## Outputs

All the figures and files created by the script will be available in the created directory SAMPLE_NAME. 

The summary plot figure recapitulating all the information will look like this :

![alt text](https://github.com/aeeckhou/shallowHRD/blob/master/summary_plot_example.jpeg)

A : Genomic profile with LSTs in green (the entire processed segmentation is represented in red if there are no LST) <br/>
B : Density used to fix the difference between a copy level <br/>
C : Graphe representing the value of each final segment (small blue circles) - <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the segmentation is good, the different copy number should appear clearly with disctinct steps <br/>
D : Table recapitulating different data and the final diagnostic for the HR status

## Nota Bene

1. The overall pipeline works also on WGS with a higher coverage

2. *shallowHRD* can be adapted to other segmentation outputs ([QDNAseq](https://github.com/ccagc/QDNAseq) for instance) <br/>

## Contact

Don't hesitate to contact us for any questions, problems or adaptation of the method !

alexandre.eeckhoutte@curie.fr <br/>
tatiana.popova@curie.fr <br/>
marc-henri.stern@curie.fr


## Publication

Submitted to __________.

"shallowHRD : a cheap and fast automatized method to evaluate Homologous Recombination Deficiency using shallow Whole Genome Sequencing" A. Eeckhoutte et al., 2019
