#!/bin/bash

# RepeatModeler + RepeatMasker

BuildDatabase -name genome genome.fa
RepeatModeler -database genome -threads 110

seqkit grep -nrp Unknown consensi.fa.classified > Modelerunknown.lib
seqkit grep -vnrp Unknown consensi.fa.classified >  ModelerID.lib
 
TEclassTest.pl Modelerunknown.lib

less Modelerunknown.lib.lib|sed 's/, Localized to 24 out of 25 contigs//g' > Modelerunknown.lib.lib2
cat Modelerunknown.lib.lib2| awk '/^>/ {split($16,a,"|");split($1,b,"#");print b[1]"#"a[1];next}{print $0}' >  Modelerunknown.lib.lib3
sed 's/unclear/Unknown/g' Modelerunknown.lib.lib3 > Modelerunknown.lib.lib4

cat ModelerID.lib Modelerunknown.lib.lib4 repbase.lib > genome.modeler.fa

RepeatMasker -e ncbi -pa 110 \
  -lib genome.modeler.fa \
  -dir repeatmask_custom \
  -gff -no_is -xsmall genome.fa

RepeatMasker -pa 110 -e ncbi \
  -species pig \
  -dir repeatmask_sp2 \
  -gff -no_is -xsmall genome.fa
