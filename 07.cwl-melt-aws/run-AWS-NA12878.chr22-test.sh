#!/bin/bash

# Test MELT pipeline steps on AWS/Toil

export RUNNER='toil-cwl-runner --retryCount 0'

# --------------------------------------------
# melt-del-multi.cwl
# --------------------------------------------

$RUNNER --clean never --cleanWorkDir never \
 --jobStore aws:us-east-1:toil-tjs1 \
 --logLevel DEBUG \
 --logFile melt-del-multi.log \
 --batchSystem mesos \
 melt-del-multi.cwl config/melt-del-multi-NA12878.chr22.yml

# manually clean aws job store
#toil clean aws:us-east-1:toil-tjs1

# --------------------------------------------
# melt-pre.cwl
# --------------------------------------------

# TODO
