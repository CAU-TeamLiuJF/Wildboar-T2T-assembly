#!/bin/bash

# RNA-seq
hisat2-build -p 16 genome.fa genome

hisat2 --dta -p 16 -x genome \
  -1 sample/sample_1.clean.fq.gz \
  -2 sample/sample_2.clean.fq.gz \
  | samtools sort -@ 16 -o sample.bam

samtools merge -@ 16 merged.bam sample1.bam sample2.bam sample3.bam

stringtie -p 16 -o merged.gtf merged.bam

gffcompare merged.gtf Iso.gtf -o transcripts.gtf

Trinity --seqType fq \
  --left trans_R1.fq.gz \
  --right trans_R2.fq.gz \
  --CPU 16 --max_memory 100G \
  --output trinity_out

Trinity --genome_guided_bam merged.bam \
  --max_memory 490G \
  --genome_guided_max_intron 10000 \
  --CPU 110 \
  --output trinity.gg

# Iso-Seq
ccs sample.subreads.bam sample.ccs.bam \
  -j 16 --minPasses 1 --min-rq 0.9

lima sample.ccs.bam primers.fa sample.lima.bam \
  --isoseq --peek-guess -j 16

isoseq3 refine sample.lima.primer_5p--primer_3p.bam \
  primers.fa sample.flnc.bam -j 16

bamtools convert -format fasta -in sample.flnc.bam > sample.flnc.fa

python tama_flnc_polya_cleanup.py \
  -f sample.flnc.fa \
  -p sample.rmploya

minimap2 -ax splice -t 16 -uf --secondary=no -C5 \
  genome.fa sample.rmploya.fa > sample.rmploya.sam
sort -k 3,3 -k 4,4n sample.rmploya.sam > sample.rmploya.sort.sam

collapse_isoforms_by_sam.py \
  --input sample.rmploya.fa \
  -s sample.rmploya.sort.sam \
  -c 0.95 -i 0.99 \
  --dun-merge-5-shorter \
  -o cupcake

cat Trinity_no_ref.fasta trinity_gg.fasta Iso.fasta > transcripts.fasta

# pasa
accession_extractor.pl transcripts.fasta > tdn.accs
seqclean transcripts.fasta -v /path/to/UniVec
Launch_PASA_pipeline.pl \
  -c alignAssembly.config \
  --trans_gtf transcripts.gtf \
  --TDN tdn.accs \
  -C -R \
  -g genome.fa \
  -t transcripts.fasta.clean \
  -T -u transcripts.fasta \
  --ALIGNERS blat \
  --CPU 8

pasa_asmbls_to_training_set.dbi \
  --pasa_transcripts_fasta pasa.sqlite.assemblies.fasta \
  --pasa_transcripts_gff3 pasa.sqlite.pasa_assemblies.gff3