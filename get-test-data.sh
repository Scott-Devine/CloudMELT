#!/bin/bash

export ASCP=/usr/local/bin/ascp
export ASCP_DSA=~/.aspera/connect/etc/asperaweb_id_dsa.openssh

# Reference genome FASTA
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz.fai
gunzip hs37d5.fa.gz
mv hs37d5.fa.gz.fai hs37d5.fa.fai
mkdir -p reference 
mv hs37d5* reference/

# Download sample .bam and .bai from NCBI
$ASCP -i $ASCP_DSA -Tr -k1 -l300M anonftp@ftp-trace.ncbi.nlm.nih.gov:/1000genomes/ftp/phase3/data/NA12878/alignment/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.bam.bai ./
$ASCP -i $ASCP_DSA -Tr -k1 -l300M anonftp@ftp-trace.ncbi.nlm.nih.gov:/1000genomes/ftp/phase3/data/NA12878/alignment/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.bam ./
mkdir -p data/test-1
mv NA12878*.bam* data/test-1



