#!/bin/bash

# verkko
verkko -d asm \
  --hifi hifi.fastq.gz \
  --nano ont.fastq.gz \
  --hic1 hic_R1.fastq.gz \
  --hic2 hic_R2.fastq.gz

# ragtag
ragtag.py patch target.fa query.fa

