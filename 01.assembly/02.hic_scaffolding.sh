#!/bin/bash

# novoalign
cd novoalign
novoindex genome_hic.hic.p_ctg.fa.ndx  genome_hic.hic.p_ctg.fa -t 110

novoalign -d genome_hic.hic.p_ctg.fa.ndx -f hic_R1.fq.gz -c 110 -r A 10 -o BAM > hic_1.bam
novoalign -d genome_hic.hic.p_ctg.fa.ndx -f hic_R2.fq.gz -c 110 -r A 10 -o BAM > hic_2.bam

source activate HiC-Pro
/software/HiC-Pro_3.1.0/bin/utils/digest_genome.py -r ^GATC -o genome_mbol.bed genome_hic.hic.p_ctg.fa
bedtools intersect -abam hic_1.bam -b genome_mbol.bed > genome_1.REduced.bam
bedtools intersect -abam hic_2.bam -b genome_mbol.bed > genome_2.REduced.bam

python extractuniq.py genome_1.REduced.bam genome_1.REduced.uniq.bam
python extractuniq.py genome_2.REduced.bam genome_2.REduced.uniq.bam

python extractpair.py genome_1.REduced.uniq.bam genome_2.REduced.uniq.bam paired_readname.list
sed 's/$/\/1/' paired_readname.list > paired_readname1.list
sed 's/$/\/2/' paired_readname.list > paired_readname2.list
java -Xms256G -Xmx256G -jar /software/picard/picard.jar FilterSamReads \
        I=genome_1.REduced.uniq.bam \
        O=genome_1.REduced.uniq.pair.bam \
        READ_LIST_FILE=paired_readname1.list \
        FILTER=includeReadList \
        VALIDATION_STRINGENCY=LENIENT

java -Xms256G -Xmx256G -jar /software/picard/picard.jar FilterSamReads \
        I=genome_2.REduced.uniq.bam \
        O=genome_2.REduced.uniq.pair.bam \
        READ_LIST_FILE=paired_readname2.list \
        FILTER=includeReadList \
        VALIDATION_STRINGENCY=LENIENT

samtools sort -@110 -n -o  genome_1.REduced.uniq.pair.sort.bam genome_1.REduced.uniq.pair.bam
samtools sort -@110 -n -o  genome_2.REduced.uniq.pair.sort.bam genome_2.REduced.uniq.pair.bam

samtools view -@110 -h genome_1.REduced.uniq.pair.sort.bam > genome_1.REduced.uniq.pair.sort.sam
samtools view -@110 -h genome_2.REduced.uniq.pair.sort.bam > genome_2.REduced.uniq.pair.sort.sam

python remove_slash_one.py genome_1.REduced.uniq.pair.sort.sam genome_1.REduced.uniq.pair.sort.rm.sam 
python remove_slash_one2.py genome_2.REduced.uniq.pair.sort.sam genome_2.REduced.uniq.pair.sort.rm.sam

samtools view -@110 -b genome_1.REduced.uniq.pair.sort.rm.sam > genome_1.REduced.uniq.pair.sort.rm.bam
samtools view -@110 -b genome_2.REduced.uniq.pair.sort.rm.sam > genome_2.REduced.uniq.pair.sort.rm.bam

mergeSAM.py -f genome_1.REduced.uniq.pair.sort.rm.bam -r genome_2.REduced.uniq.pair.sort.rm.bam -o genome.REduced.uniq.pair.sort.rm.bam -q 0 -t -v

# samblaster
samtools view -h genome.REduced.uniq.pair.sort.rm.bam|samblaster | samtools view - -@ 110 -S -h -b -F 3340 -o genome.REduced.uniq.pair.sort.rm.filter.bam

filter_bam genome.REduced.uniq.pair.sort.rm.filter.bam 1 --nm 3 --threads 110 | samtools view - -b -@ 110 -o genome.REduced.uniq.pair.sort.rm.filter.final.bam

haphic pipeline  --correct_nrounds 2 --max_inflation 5 --bin_size 500 genome_hic.hic.p_ctg.fa genome.REduced.uniq.pair.sort.rm.filter.final.bam 20

