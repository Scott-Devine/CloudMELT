#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'

# verbose logging
#$RUNNER --logDebug melt.cwl NA12878/melt.yml

# Preprocess
#$RUNNER melt-pre.cwl NA12878/melt-pre.yml 

# IndivAnalyis
#$RUNNER melt-ind.cwl NA12878/melt-ind.yml 

# WF1. Preprocess - IndivAnalysis
# TODO - add Coverage
$RUNNER melt-split-pre-ind-cov.cwl NA12878/melt-pre-ind-cov.yml

# WF2. GroupAnalysis
$RUNNER melt-grp.cwl NA12878/melt-grp.yml 

# WF3. Genotyping
$RUNNER --retryCount 0 melt-gen.cwl NA12878/melt-gen.yml 

# WF4. MakeVCF
$RUNNER melt-vcf.cwl NA12878/melt-vcf.yml
