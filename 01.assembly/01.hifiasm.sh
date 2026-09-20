#!/bin/bash

# hifi + hic
for k in 45 47 49 51 53 55 57 59 61 63
do
	mkdir -p ${k}mer
	cd /WORKDIR/${k}mer
	hifiasm -k ${k} -w ${k} -o genome_k${k}w${k}_hic -t 100 --h1 hic_R1.fq.gz --h2 hic_R2.fq.gz --telo-m CCCTAA hifi.fasta.gz
done

# hifi + ont + hic
for k in 45 47 49 51 53 55 57 59 61 63
do
	mkdir -p ${k}mer
	cd /WORKDIR/${k}mer
	hifiasm -k ${k} -w ${k} -o genome_k${k}w${k}_hic -t 120 --h1 hic_R1.fq.gz --h2 hic_R2.fq.gz --telo-m CCCTAA  --ul ont.fastq.gz hifi.fasta.gz
done
