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





