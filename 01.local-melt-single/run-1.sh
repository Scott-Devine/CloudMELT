#!/bin/bash

export MELT=./MELTv2.1.5
export WDIR=test-1-run-1-wd

echo "melt=$MELT/MELT.jar" 
echo "wdir=$WDIR"

#cd scratch_dir
mkdir -p $WDIR

time java -jar $MELT/MELT.jar Single \
    -a \
    -b hs37d5/NC_007605 \
    -c 8 \
    -h reference/hs37d5.fa \
    -bamfile data/test-1/NA12878.mapped.ILLUMINA.bwa.CEU.low_coverage.20121211.bam \
    -n $MELT/add_bed_files/1KGP_Hg19/hg19.genes.bed \
    -t mei_list.txt \
    -w $WDIR >$WDIR.out 2>$WDIR.err


