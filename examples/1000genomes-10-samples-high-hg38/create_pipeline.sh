#!/bin/bash

# set to location of CloudMELT source code
export CLOUD_MELT_HOME=~/MELT

# create pipeline for 10 high-coverage 1000 Genomes samples
#  -edit toil_jobstore to reflect the desired AWS zone
$CLOUD_MELT_HOME/bin/create_pipeline.pl --sample_uri_list=sample_uris.txt \
 --config_dir=./config.in \
 --workflow_dir=./melt-workflow \
 --docker_image_uri='205226202704.dkr.ecr.us-east-1.amazonaws.com/umigs/melt:hg38-latest' \
 --sample_regex='([^/]+)\.final\.cram' \
 --coverage_method=user \
 --run_melt_deletion \
 --toil_jobstore='aws:us-east-1:jc-tj2'
