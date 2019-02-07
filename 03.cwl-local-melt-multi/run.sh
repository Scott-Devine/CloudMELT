#!/bin/bash

# preprocess subflow
toil-cwl-runner melt-pre.cwl melt-pre-test.yml 

# verbose logging
#toil-cwl-runner --logDebug melt.cwl melt.yml
