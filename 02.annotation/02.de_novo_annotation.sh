#!/bin/bash

# genemark
gmes_petap.pl --sequence genome.fa.masked \
  --ET braker/genemark_hintsfile.gff \
  --et_score 4 --cores 16

# augustus
gff2gbSmallDNA.pl transcripts.singlecopy.gff3 genome.fa.masked 1000 genes.raw.gb

etraining --species=generic --stopCodonExcludedFromCDS=false genes.raw.gb 2> train.err

cat train.err | perl -pe 's/.*in sequence (\S+): .*/$1/' >badgenes.lst
filterGenes.pl badgenes.lst genes.raw.gb > genes.gb

grep '/gene' genes.gb |sort |uniq  |sed 's/\/gene=//g' |sed 's/\"//g' |awk '{print $1}' >geneSet.lst
python extract_pep.py geneSet.lst sample_genome/sample_pep_v1.fa

makeblastdb -in geneSet.lst.fa -dbtype prot -parse_seqids -out geneSet.lst.fa
blastp -db geneSet.lst.fa -query geneSet.lst.fa -out geneSet.lst.fa.blastp -evalue 1e-5 -outfmt 6 -num_threads 8
python delete_high_identity_gene.py geneSet.lst.fa.blastp sample_genome/sample_gene_v1.gff3

gff2gbSmallDNA.pl  gene_filter.gff3  ./sample_genome/sample_genome_v1.fa 1000 genes.gb.filter

randomSplit.pl genes.gb.filter 100

new_species.pl --species=sample
etraining --species=sample genes.gb.filter.train

augustus --species=sample genes.gb.filter.test | tee firsttest.out
augustus --species=arabidopsis genes.gb.filter.test | tee firsttest_ara.out

optimize_augustus.pl --species=sample genes.gb.filter.train

etraining --species=sample genes.gb.filter.train
augustus --species=sample genes.gb.filter.test | tee secondtest.out





