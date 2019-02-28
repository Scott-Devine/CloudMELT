#!/bin/bash

export BAM1=../data/test-2/NA12878.chr22.sorted.bam
export BAM2=../data/test-2/NA12878.chrX.sorted.bam
export BAM_FULL=../data/test-1/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.bam
#export BEDFILE=../MELTv2.1.5/add_bed_files/1KGP_Hg19/LINE1.deletion.bed
export ALUY_BEDFILE=../MELTv2.1.5/add_bed_files/1KGP_Hg19/AluY.deletion.bed
export FILTERED_BEDFILE=./AluY.deletion.filtered.bed
export REF_FASTA=../reference/hs37d5.fa

#mkdir del-tmp

# ---------------------------------------------------
# test w/ original AluY BED file on NA12878/Chr22
# ---------------------------------------------------
#time java -jar ../MELTv2.1.5/MELT.jar Deletion-Genotype -bamfile $BAM1 -bed $ALUY_BEDFILE -h $REF_FASTA -w ./del-tmp
echo 'del-tmp/NA12878.chr22.del.tsv' > del-mergelist.txt
time java -mx4G -jar ../MELTv2.1.5/MELT.jar Deletion-Merge -mergelist del-mergelist.txt -bed $FILTERED_BEDFILE -h $REF_FASTA -d 1000000 -o ./FD_
exit

# ---------------------------------------------------
# test w/ original AluY BED file on NA12878
# ---------------------------------------------------
#time java -jar ../MELTv2.1.5/MELT.jar Deletion-Genotype -bamfile $BAM_FULL -bed $ALUY_BEDFILE -h $REF_FASTA -w ./del-tmp
echo 'del-tmp/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.del.tsv' > del-mergelist.txt
#time java -mx4G -jar ../MELTv2.1.5/MELT.jar Deletion-Merge -mergelist del-mergelist.txt -bed $ALUY_BEDFILE -h $REF_FASTA -o ./
time java -mx4G -jar ../MELTv2.1.5/MELT.jar Deletion-Merge -mergelist del-mergelist.txt -bed $FILTERED_BEDFILE -h $REF_FASTA -o ./
exit

# ---------------------------------------------------
# test w/ filtered AluY BED file
# ---------------------------------------------------

# chr22
time java -jar ../MELTv2.1.5/MELT.jar Deletion-Genotype -bamfile $BAM1 -bed $FILTERED_BEDFILE -h $REF_FASTA -w ./del-tmp
# chrX
time java -jar ../MELTv2.1.5/MELT.jar Deletion-Genotype -bamfile $BAM2 -bed $FILTERED_BEDFILE -h $REF_FASTA -w ./del-tmp
echo 'del-tmp/NA12878.chr22.del.tsv' > del-mergelist.txt
echo 'del-tmp/NA12878.chrX.del.tsv' >> del-mergelist.txt
# merge
time java -mx4G -jar ../MELTv2.1.5/MELT.jar Deletion-Merge -mergelist del-mergelist.txt -bed $FILTERED_BEDFILE -h $REF_FASTA -o ./


