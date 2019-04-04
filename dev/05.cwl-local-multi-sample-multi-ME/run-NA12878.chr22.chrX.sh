#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

# verbose logging
#$RUNNER --logDebug melt.cwl melt.yml

# coverage test with mosdepth
# real	0m46.997s  (168M BAM/chr22 only)
# real	5m21.681s (15GB NA12878)
# user  0m10.838s
# sys   0m5.940s
#$RUNNER melt-cov-mosdepth.cwl NA12878.chr22.chrX/melt-cov-mosdepth.yml
#exit

# --------------------------------------------
# MELT-Split
# --------------------------------------------

# Preprocess - Coverage ("dummy" coverage - takes user provided coverage estimate)
#$RUNNER melt-split-pre-dummy-cov.cwl NA12878.chr22.chrX/melt-pre-dummy-cov.yml
#exit

# IndivAnalysis
#$RUNNER melt-ind.cwl NA12878.chr22.chrX/melt-ind.yml
#exit

#$RUNNER melt-split-ind-grp-gen-vcf.cwl NA12878.chr22.chrX/melt-split-ind-grp-gen-vcf.yml
#exit

# GroupAnalysis on all
#$RUNNER melt-grp.cwl NA12878.chr22.chrX/melt-grp.yml 
#exit

# Genotyping
#real	0m6.680s
#$RUNNER --retryCount 0 melt-gen.cwl NA12878.chr22/melt-gen.yml 

# MakeVCF
#real	0m4.577s
#$RUNNER melt-vcf.cwl NA12878.chr22/melt-vcf.yml 
#exit

# End-to-end multi-sample, multi-ME workflow with dummy coverage calculation
#
# Chr22,ChrX LINE1,ALU,SVA
#
# real	2m3.407s
# user	4m18.113s
# sys	0m59.762s
#$RUNNER melt-split-multi-dummy-cov.cwl NA12878.chr22.chrX/melt-split-multi-dummy-cov.yml
#exit

# MELT-Single run on chrX only:
#
# real	0m47.929s
# user	1m10.602s
# sys	0m5.109s
#export MELT=../MELTv2.1.5
#export WDIR=2chr-3me-single
#mkdir $WDIR
#java -jar $MELT/MELT.jar Single \
#    -a \
#    -b hs37d5/NC_007605 \
#    -c 7 \
#    -h ../reference/hs37d5.fa \
#    -bamfile ../data/test-2/NA12878.chrX.sorted.bam \
#    -n $MELT/add_bed_files/1KGP_Hg19/hg19.genes.bed \
#    -t mei_list.txt \
#    -w $WDIR >$WDIR.out 2>$WDIR.err
#exit

# End-to-end multi-sample, multi-ME workflow with mosdepth coverage calculation
#
# NA12878
#
# real	16m2.271s
# user	15m51.086s
# sys	3m59.189s
#
#$RUNNER melt-split-multi-mosdepth-cov.cwl NA12878.chr22.chrX/melt-split-multi-NA12878.yml
#exit

# same with dummy coverage
# real	12m44.736s
# user	15m33.865s
# sys	3m50.853s
#$RUNNER melt-split-multi-dummy-cov.cwl NA12878.chr22.chrX/melt-split-multi-dummy-cov-NA12878.yml
#exit

# --------------------------------------------
# MELT-Deletion
# --------------------------------------------

# WF1.
#$RUNNER melt-del-gen.cwl NA12878.chr22.chrX/melt-del-gen-1.yml
#$RUNNER melt-del-gen.cwl NA12878.chr22.chrX/melt-del-gen-2.yml
exit

# WF2.
#$RUNNER melt-del-merge.cwl NA12878.chr22.chrX/melt-del-merge.yml

# End-to-end, multi-sample
#$RUNNER melt-del.cwl NA12878.chr22.chrX/melt-del.yml

# End-to-end, multi-sample, multi-ME
$RUNNER melt-del-multi.cwl NA12878.chr22.chrX/melt-del-multi.yml
