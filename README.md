# Estimations-genomovars
Predictions of the number of genomovars within a natural microbial population

## Required tools: Eveomics scripts collection and Blast tool

Enveomics scripts collection can be downloaded from http://enve-omics.ce.gatech.edu/enveomics/download
```
git clone git://github.com/lmrodriguezr/enveomics.git enveomics 
```

Blast tool can be installed with a conda environment:
```
conda create -n blast
conda activate blast
conda install -c bioconda blast
```

## Map metagenomic reads to reference genomes

1- Concatenate all reference genomes in a single file

```
cat *.fna > All_genomes.fna
```

2- Make blast database

```
makeblastdb -in All_Genomes.fna -out All_Genomes.db -dbtype nucl
```

3- Run blast tool

```
blastn -query {metagenome}.CoupledReads.fa -db All_Genomes.db -out {metagenome}.blast -num_threads 18 -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen"
```

4- Filter the output blast table by best hit and 95% sequence identity and 70% of fraction covered by the metagenomic read

```
sort {metagenome}.blast | BlastTab.best_hit_sorted.pl > BH_{metagenome}.blast

awk '{if ($3>=95 && ($4/$13)>=0.7) print $0}' BH_{metagenome}.blast > 95_70_BH_{metagenome}.blast

```

## Calculate rarefaction curves of genomovar diversity 

1- The script first select for all matches with identity ≥99.3%. Then, the mapping file remove one target genome at a time (randomly selected) while recording the number of unique reads mapping at each step. This process is repeated 100 times to reduce the impact of randomization on the estimates obtained. 

```
./RUNME.bash
```

2- Merge the subsampling files for each metagenome in a single file

```
./merge.bash
```

3- Create the projection graph: The number of reads are expressed as the fraction of the maximum number of reads from the target microbial species by dividing the observed counts by the total number of reads mapping to any reference genome with identity ≥ 95%. The logarithm of the number of total (dereplicated) genomes used is expressed as a function of the fraction of reads captured by the genomes. The linear regression is determined by unweighted least squares and evaluated using Pearson correlation for the region between 20 and 100 genomes. The trendline is extrapolated to 100% coverage of the genomovar diversity to provide an estimate of the number of genomovars represented in the total sequenced fraction.

```
./project.bash
```


Example of projection graph:

![figure](/rarefaction/projection.png)

4- The number of estimated genomovar predicted will be given in the projection.tsv file.




