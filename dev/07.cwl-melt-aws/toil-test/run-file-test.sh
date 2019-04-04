#!/bin/bash

# Trivial TOIL test - checks support for S3 URIs in YAML File entries.

export RUNNER='toil-cwl-runner --retryCount 0'

# Mac OS X - specific workaround for Docker tasks
#export TMPDIR="/private${TMPDIR}"

# --------------------------------------------
# file-test.cwl
# --------------------------------------------

# run with AWS job store, statically allocated cluster
$RUNNER --clean never --cleanWorkDir never \
 --jobStore aws:us-east-1:toil-js1 \
 --logLevel DEBUG \
 --logFile hostname-test.log \
 --batchSystem mesos \
 file-test.cwl config/file-test.yml

# clean aws job store
#toil clean aws:us-east-1:toil-js1
