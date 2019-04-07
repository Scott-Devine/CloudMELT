#!/bin/bash

# set to location of CloudMELT source code
export CLOUD_MELT_HOME=~/MELT

# create pipeline for 10 low-coverage 1000 Genomes samples
#  -edit toil_jobstore to reflect the desired AWS zone
../../bin/create_pipeline.pl --sample_uri_list=sample_uris.txt \
 --config_dir=./config.in \
 --workflow_dir=./melt-workflow \
 --toil_jobstore='aws:us-east-1:tj1'
