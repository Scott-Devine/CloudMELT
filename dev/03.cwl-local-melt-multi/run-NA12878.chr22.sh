#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

# verbose logging
#$RUNNER --logDebug melt.cwl melt.yml

# coverage test with mosdepth
# real	0m46.997s  (168M BAM/chr22 only)
#ntime $RUNNER melt-cov.cwl melt-cov.yml

# WF1 - WF4

# WF1. Preprocess - IndivAnalysis
#real	0m18.900s (without coverage)
#real   1m4.081s  (with coverage) 
#$RUNNER melt-split-pre-ind-cov.cwl NA12878.chr22/melt-pre-ind-cov.yml
#exit

# WF2. GroupAnalysis
#real	0m7.698s
#$RUNNER melt-grp.cwl NA12878.chr22/melt-grp.yml 

# WF3. Genotyping
#real	0m6.680s
#$RUNNER --retryCount 0 melt-gen.cwl NA12878.chr22/melt-gen.yml 

# WF4. MakeVCF
#real	0m4.577s
#$RUNNER melt-vcf.cwl NA12878.chr22/melt-vcf.yml 
#exit

# End-to-end workflow
$RUNNER melt-split.cwl NA12878.chr22/melt-split.yml
