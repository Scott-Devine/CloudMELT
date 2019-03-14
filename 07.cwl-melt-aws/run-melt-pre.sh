#!/bin/bash

export RUNNER='toil-cwl-runner --retryCount 0'

# --------------------------------------------
# melt-pre
# --------------------------------------------

# local run
#export TMPDIR="/private${TMPDIR}"
#$RUNNER melt-pre.cwl NA12878.chr22.chrX/melt-pre.yml
#exit

# AWS run with AWS job store, dynamic allocation
$RUNNER --clean never --cleanWorkDir never \
 --jobStore aws:us-east-1:melt-pre-js1 \
 --provisioner aws --maxNodes 1 --nodeTypes t2.medium \
 --logLevel DEBUG \
 --logFile melt-pre.log \
 --batchSystem mesos \
 melt-pre.cwl NA12878.chr22.chrX/melt-pre.yml

# clean aws job store
#toil clean aws:us-east-1:melt-pre-js1
