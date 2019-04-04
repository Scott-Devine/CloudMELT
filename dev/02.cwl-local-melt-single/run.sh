#!/bin/bash

#cp ../01.local-melt-single/mei_list.txt ./
toil-cwl-runner melt.cwl melt.yml

# verbose logging
#toil-cwl-runner --logDebug melt.cwl melt.yml
