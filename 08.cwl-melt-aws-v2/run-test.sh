#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'
# Mac OS X - specific workaround for Docker tasks
export TMPDIR="/private${TMPDIR}"

$RUNNER melt-split-pre-mosdepth-cov-ind.cwl config/melt-split-pre-mosdepth-cov-ind-NA12878.chr22.LINE1.yml
