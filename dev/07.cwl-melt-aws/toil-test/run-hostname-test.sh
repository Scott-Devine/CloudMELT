#!/bin/bash

# Trivial TOIL test - runs 'hostname' on worker node with sufficient RAM/disk.

export RUNNER='toil-cwl-runner --retryCount 0'

# Mac OS X - specific workaround for Docker tasks
#export TMPDIR="/private${TMPDIR}"

# --------------------------------------------
# hostname-test.cwl
# --------------------------------------------

# run with AWS job store, dynamically allocated  cluster
#$RUNNER --clean never --cleanWorkDir never \
# --jobStore aws:us-east-1:toil-js1 \
# --provisioner aws --maxNodes 1 --nodeTypes t2.medium \
# --logLevel DEBUG \
# --logFile hostname-test.log \
# --batchSystem mesos \
# hostname-test.cwl config/hostname-test.yml

# run with AWS job store, statically allocated cluster
$RUNNER --clean never --cleanWorkDir never \
 --jobStore aws:us-east-1:toil-js1 \
 --logLevel DEBUG \
 --logFile hostname-test.log \
 --batchSystem mesos \
 hostname-test.cwl config/hostname-test.yml

# clean aws job store
#toil clean aws:us-east-1:toil-js1
