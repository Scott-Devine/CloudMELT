#!/bin/bash

# test Preprocess subflow
#toil-cwl-runner melt-pre.cwl melt-pre-test.yml 

# test IndivAnalyis subflow
#toil-cwl-runner melt-ind.cwl melt-ind-test.yml 

# test workflow wrapping a command
toil-cwl-runner melt-split-pre-ind-cov.cwl melt-wf-test.yml

# verbose logging
#toil-cwl-runner --logDebug melt.cwl melt.yml
