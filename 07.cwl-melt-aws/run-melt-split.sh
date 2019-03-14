#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

# chr22 subset only, LINE1
#$RUNNER melt-split-multi-mosdepth-cov.cwl config/melt-split-multi-NA12878.chr22.yml

# chr22 and chrX, all 3 MEs
$RUNNER --logLevel DEBUG --logFile melts-split.log melt-split-multi-mosdepth-cov.cwl config/melt-split-multi-NA12878.chr22.chrX.all.yml


