#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'

# verbose logging
#$RUNNER --logDebug melt.cwl melt.yml

# WF1. Preprocess - IndivAnalysis
# TODO - add Coverage
#real	0m18.900s
#$RUNNER melt-split-pre-ind-cov.cwl NA12878.chr22/melt-pre-ind-cov.yml

# WF2. GroupAnalysis
#real	0m7.698s
#$RUNNER melt-grp.cwl NA12878.chr22/melt-grp.yml 

# WF3. Genotyping
#real	0m6.680s
#$RUNNER --retryCount 0 melt-gen.cwl NA12878.chr22/melt-gen.yml 

# WF4. MakeVCF
$RUNNER melt-vcf.cwl NA12878.chr22/melt-vcf.yml 
exit
