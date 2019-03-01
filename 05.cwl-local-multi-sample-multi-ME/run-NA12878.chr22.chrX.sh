#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

# verbose logging
#$RUNNER --logDebug melt.cwl melt.yml

# coverage test with mosdepth
# real	0m46.997s  (168M BAM/chr22 only)
#ntime $RUNNER melt-cov.cwl melt-cov.yml

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

# End-to-end multi-sample, multi-ME workflow
$RUNNER melt-split-multi.cwl NA12878.chr22.chrX/melt-split-multi.yml
exit

# --------------------------------------------
# MELT-Deletion
# --------------------------------------------

# WF1.
#$RUNNER melt-del-gen.cwl NA12878.chr22.chrX/melt-del-gen-1.yml
#$RUNNER melt-del-gen.cwl NA12878.chr22.chrX/melt-del-gen-2.yml

# WF2.
#$RUNNER melt-del-merge.cwl NA12878.chr22.chrX/melt-del-merge.yml

# End-to-end, multi-sample
#$RUNNER melt-del.cwl NA12878.chr22.chrX/melt-del.yml

# End-to-end, multi-sample, multi-ME
$RUNNER melt-del-multi.cwl NA12878.chr22.chrX/melt-del-multi.yml
