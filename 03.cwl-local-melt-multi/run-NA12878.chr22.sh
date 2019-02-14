#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'

# verbose logging
#$RUNNER --logDebug melt.cwl melt.yml

# Preprocess
#$RUNNER melt-pre.cwl melt-pre-test.yml 

# IndivAnalyis
#$RUNNER melt-ind.cwl melt-ind-test.yml 

# WF1. Preprocess - IndivAnalysis
# TODO - add Coverage
$RUNNER melt-split-pre-ind-cov.cwl melt-pre-ind-cov-test.yml

# WF2. GroupAnalysis
$RUNNER melt-grp.cwl melt-grp-test.yml 

# WF3. Genotyping
$RUNNER --retryCount 0 melt-gen.cwl melt-gen-test.yml 

# WF4. MakeVCF
$RUNNER melt-vcf.cwl melt-vcf-test.yml 
