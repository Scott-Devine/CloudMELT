#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

# chr22 subset only, LINE1
#$RUNNER melt-del-multi.cwl config/melt-del-multi-NA12878.chr22.yml

# chr22 and chrX subsets, LINE1
#$RUNNER melt-del-multi.cwl config/melt-del-multi-NA12878.chr22.chrX.yml

# chr22 and chrX subsets, LINE1 + AluY
$RUNNER melt-del-multi.cwl config/melt-del-multi-NA12878.chr22.chrX.both.yml
