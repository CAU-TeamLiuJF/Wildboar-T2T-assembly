# Wildboar-T2T-assembly
Wild boars are widely distributed mammals, yet high-quality genomic resources for wild populations remain scarce. Here we present two telomere-to-telomere (T2T) genomes for southern and northern Chinese wild boars, enabling dissection of previously inaccessible genomic regions. 

## 📌 Overview

This repository provides analysis pipelines for pig multi-omics integration, including genome assembly, annotation, pangenome construction, structural variation (SV) detection, and downstream genetic analyses.



## ⚠️ Note

Some scripts were adapted based on the configuration of the High-Performance Computing (HPC) platform at China Agricultural University.

Please modify:
- file paths  
- software environments (e.g., module load / conda)  
- computational resources  

before running the pipelines on your system.



## 📁 Directory Structure
- **01.assembly/**  
  Genome assembly: HiFi assembly, Hi-C scaffolding, gap filling, polishing.

- **02.annotation/**  
  Genome annotation: TE prediction, gene annotation, EvidenceModeler integration.

- **03.chipseq/**  
  ChIP-seq processing: alignment, deduplication, peak calling.
