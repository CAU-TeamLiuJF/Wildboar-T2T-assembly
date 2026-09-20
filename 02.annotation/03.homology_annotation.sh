#!/bin/bash

# gemoma
java -Xms256G -Xmx256G -jar GeMoMa-1.9.jar \
  CLI GeMoMaPipeline \
  threads=110 \
  outdir=gemoma_out \
  GeMoMa.Score=ReAlign \
  AnnotationFinalizer.r=NO \
  o=true \
  t=genome.fa \
  \
  s=own i=sheep a=sheep.gff g=sheep.fa \
  s=own i=human a=human.gff g=human.fa \
  s=own i=mouse a=mouse.gff g=mouse.fa \
  s=own i=pig   a=pig.gff   g=pig.fa \
  s=own i=cow   a=cow.gff   g=cow.fa \
  \
  r=MAPPED \
  ERE.s=FR_UNSTRANDED \
  ERE.m=rnaseq.bam \
  ERE.c=true

# miniprot
miniprot -t 16 --gff genome.fa proteins.fa > miniprot.gff3
miniprot_GFF_2_EVM_GFF3.py miniprot.gff3 > miniprot.evm.gff3